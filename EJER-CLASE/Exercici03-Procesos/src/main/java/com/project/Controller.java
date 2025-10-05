package com.project;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpRequest.BodyPublishers;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.Base64;
import java.util.ResourceBundle;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;

import org.json.JSONArray;
import org.json.JSONObject;

import javafx.application.Platform;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.scene.Node;
import javafx.scene.control.TextField;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.VBox;
import javafx.scene.shape.Rectangle;
import javafx.scene.control.ScrollPane;

import javafx.stage.FileChooser;

public class Controller implements Initializable {

    // modelos
    private static final String TEXT_MODEL   = "gemma3:1b";
    private static final String VISION_MODEL = "llava-phi3";

    // fxml
    @FXML private VBox responseBox;
    @FXML private ScrollPane scrollPane;
    @FXML private TextField textPrompt;
    @FXML private ImageView btnAddImage, btnSubmitPrompt;
    @FXML private Rectangle btnStopResponse;

    // variables internas
    private final HttpClient httpClient = HttpClient.newHttpClient();
    private CompletableFuture<HttpResponse<InputStream>> streamRequest;
    private CompletableFuture<HttpResponse<String>> completeRequest;
    private final AtomicBoolean isCancelled = new AtomicBoolean(false);
    private InputStream currentInputStream;
    private final ExecutorService executorService = Executors.newSingleThreadExecutor();
    private Future<?> streamReadingTask;

    private String selectedImageBase64 = null;
    private String currentUserMessage = "";
    
    private Image aiIcon;
    private Image userIcon;

    // referencia al último mensaje de la IA (para actualizarlo en streaming)
    private ChatController lastAIMessage;


    @Override
    public void initialize(java.net.URL url, ResourceBundle rb) {
        try {
            aiIcon = new Image(getClass().getResourceAsStream("/images/ai_icon.png"));
            userIcon = new Image(getClass().getResourceAsStream("/images/user_icon.png"));
            btnAddImage.setImage(new Image(getClass().getResourceAsStream("/images/upload.jpg")));
            btnSubmitPrompt.setImage(new Image(getClass().getResourceAsStream("/images/send.jpg")));
            btnStopResponse.setVisible(true);

        } catch (Exception e) { 
            System.out.println("No se pudo cargar imagen"); }
    }

    // metodos chat
    @FXML
    private void processCall() {
        String userMessage = textPrompt.getText();
        if (userMessage == null || userMessage.trim().isEmpty()) {
            showSimpleMessage("Escribe un mensaje antes de enviar.");
            return;
        }

        currentUserMessage = userMessage;
        displayUserMessage(currentUserMessage);

        isCancelled.set(false);
        Platform.runLater(() -> btnStopResponse.setDisable(false)); // <-- Se puede cancelar ahora

        if (selectedImageBase64 != null) {
            appendAIMessage("Thinking...", false);
            ensureModelLoaded(VISION_MODEL).whenComplete((v, err) -> {
                if (err != null) { Platform.runLater(() -> { updateAIMessage("Error cargando modelo visión."); resetUI(); }); return; }
                executeImageRequest(VISION_MODEL, userMessage, selectedImageBase64);
            });
        } else {
            appendAIMessage("", true);
            ensureModelLoaded(TEXT_MODEL).whenComplete((v, err) -> {
                if (err != null) { Platform.runLater(() -> { updateAIMessage("Error cargando modelo texto."); resetUI(); }); return; }
                executeTextRequest(TEXT_MODEL, userMessage, true);
            });
        }
        textPrompt.clear();
    }


    @FXML
    private void addImage() {
        FileChooser fc = new FileChooser();
        fc.setTitle("Selecciona una imagen");
        fc.getExtensionFilters().addAll(
            new FileChooser.ExtensionFilter("Imágenes", "*.png", "*.jpg", "*.jpeg", "*.webp", "*.bmp", "*.gif")
        );
        File file = fc.showOpenDialog(responseBox.getScene().getWindow());
        if (file == null) { showSimpleMessage("No seleccionaste ningún archivo."); return; }

        try {
            byte[] bytes = Files.readAllBytes(file.toPath());
            selectedImageBase64 = Base64.getEncoder().encodeToString(bytes);
            showSimpleMessage("Imagen cargada: " + file.getName());
        } catch (Exception e) { e.printStackTrace(); showSimpleMessage("Error leyendo la imagen."); selectedImageBase64 = null; }
    }

    @FXML
    private void cancelCall() {
        isCancelled.set(true);
        if (streamRequest != null && !streamRequest.isDone()) streamRequest.cancel(true);
        if (completeRequest != null && !completeRequest.isDone()) completeRequest.cancel(true);
        if (currentInputStream != null) 
        try { currentInputStream.close(); } catch (Exception ignore) {}
        if (streamReadingTask != null && !streamReadingTask.isDone()) streamReadingTask.cancel(true);

        Platform.runLater(() -> { updateAIMessage("Petición cancelada."); resetUI(); });
    }

    // === Requests ===
    private void executeTextRequest(String model, String prompt, boolean stream) {
        JSONObject body = new JSONObject().put("model", model).put("prompt", prompt).put("stream", stream).put("keep_alive", "10m");

        HttpRequest request = HttpRequest.newBuilder() .uri(URI.create("http://localhost:11434/api/generate")).header("Content-Type", "application/json").POST(BodyPublishers.ofString(body.toString())).build();

        if (stream) {
            streamRequest = httpClient.sendAsync(request, HttpResponse.BodyHandlers.ofInputStream())
                .thenApply(resp -> {
                    currentInputStream = resp.body();
                    streamReadingTask = executorService.submit(this::handleStreamResponse);
                    return resp;
                }).exceptionally(e -> { if (!isCancelled.get()) e.printStackTrace(); Platform.runLater(this::resetUI); return null; });
        }
    }

    private void executeImageRequest(String model, String prompt, String base64Image) {
        JSONObject body = new JSONObject().put("model", model).put("prompt", prompt).put("images", new JSONArray().put(base64Image)).put("stream", false);

        HttpRequest request = HttpRequest.newBuilder().uri(URI.create("http://localhost:11434/api/generate")).header("Content-Type", "application/json").POST(BodyPublishers.ofString(body.toString())).build();

        completeRequest = httpClient.sendAsync(request, HttpResponse.BodyHandlers.ofString()).thenApply(resp -> {
                String msg = tryParseAnyMessage(resp.body());
                if (msg == null || msg.isBlank()) msg = "(respuesta vacía)";
                final String toShow = msg;
                Platform.runLater(() -> { updateAIMessage(toShow); resetUI(); });
                return resp;
            }).exceptionally(e -> { if (!isCancelled.get()) e.printStackTrace(); Platform.runLater(() -> { updateAIMessage("Error en la petición."); resetUI(); }); return null; });
    }

    private void handleStreamResponse() {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(currentInputStream, StandardCharsets.UTF_8))) {
            String line;
            StringBuilder aiResponse = new StringBuilder();
            while ((line = reader.readLine()) != null) {
                if (isCancelled.get() || Thread.currentThread().isInterrupted()) break;
                if (line.isBlank()) continue;
                JSONObject jsonResponse = new JSONObject(line);
                String chunk = jsonResponse.optString("response", "");
                if (chunk.isEmpty()) continue;
                aiResponse.append(chunk);
                final String currentResponse = aiResponse.toString();
                Platform.runLater(() -> updateAIMessage(currentResponse));
            }
        } catch (Exception e) { if (!isCancelled.get()) e.printStackTrace(); Platform.runLater(() -> updateAIMessage("Error durante streaming.")); }
        finally { resetUI(); }
    }

    // === UI Helpers ===
    private void displayUserMessage(String message) {
        Platform.runLater(() -> {
            try {
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/assets/chat.fxml"));
                Node node = loader.load();
                ChatController chatCtrl = loader.getController();
                chatCtrl.setData("You", message, userIcon);
                responseBox.getChildren().add(node);
                scrollPane.setVvalue(1.0);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    // flujo chat
    private void appendAIMessage(String message, boolean streaming) {
        Platform.runLater(() -> {
            try {
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/assets/chat.fxml"));
                Node node = loader.load();
                ChatController chatCtrl = loader.getController();
                chatCtrl.setData("IETI", message, aiIcon);
                responseBox.getChildren().add(node);
                scrollPane.setVvalue(1.0);
                lastAIMessage = chatCtrl; // Guardamos referencia al último mensaje AI
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    private void updateAIMessage(String message) {
        Platform.runLater(() -> {
            if (lastAIMessage != null) {
                lastAIMessage.setData("IETI", message, aiIcon);
            }
            scrollPane.setVvalue(1.0);
        });
    }

    private void showSimpleMessage(String message) {
        Platform.runLater(() -> {
            try {
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/assets/chat.fxml"));
                Node node = loader.load();
                ChatController chatCtrl = loader.getController();
                chatCtrl.setData("System", message, null); // Mensaje de sistema sin icono
                responseBox.getChildren().add(node);
                scrollPane.setVvalue(1.0);
            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    private void resetUI() {
        Platform.runLater(() -> btnStopResponse.setDisable(true)); // Desactiva el botón al terminar
        streamRequest = null;
        completeRequest = null;
        selectedImageBase64 = null;
    }


    private String tryParseAnyMessage(String bodyStr) {
        try {
            JSONObject o = new JSONObject(bodyStr);
            if (o.has("response")) return o.optString("response", "");
            if (o.has("message"))  return o.optString("message", "");
            if (o.has("error"))    return "Error: " + o.optString("error", "");
        } catch (Exception ignore) {}
        return null;
    }

    private CompletableFuture<Void> ensureModelLoaded(String modelName) {
        HttpRequest req = HttpRequest.newBuilder().uri(URI.create("http://localhost:11434/api/ps")).GET().build();

        return httpClient.sendAsync(req, HttpResponse.BodyHandlers.ofString()).thenCompose(resp -> {
                boolean loaded = false;
                try {
                    JSONObject o = new JSONObject(resp.body());
                    JSONArray models = o.optJSONArray("models");
                    if (models != null) {
                        for (int i = 0; i < models.length(); i++) {
                            if (models.getJSONObject(i).optString("name", "").startsWith(modelName)) {
                                loaded = true; break;
                            }
                        }
                    }
                } catch (Exception ignore) {}
                if (loaded) return CompletableFuture.completedFuture(null);
                JSONObject preload = new JSONObject().put("model", modelName).put("stream", false).put("keep_alive", "10m");
                HttpRequest preloadReq = HttpRequest.newBuilder().uri(URI.create("http://localhost:11434/api/generate")).header("Content-Type", "application/json").POST(BodyPublishers.ofString(preload.toString())).build();
                return httpClient.sendAsync(preloadReq, HttpResponse.BodyHandlers.ofString()).thenAccept(r -> {});
            });
    }
}
