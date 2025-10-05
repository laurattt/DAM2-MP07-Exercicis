package com.project;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.geometry.Pos;
import javafx.scene.Parent;
import javafx.scene.control.ChoiceBox;
import javafx.scene.control.Label;
import javafx.scene.control.ScrollPane;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ResourceBundle;

public class ControllerDesktop implements Initializable {

    @FXML
    private ChoiceBox<String> choiceBox;

    @FXML
    private ScrollPane scrollPane;

    @FXML
    private VBox detailVBox;

    private VBox contentVBox = new VBox(5);

    @Override
    public void initialize(URL url, ResourceBundle rb) {
        // Fondo general
        contentVBox.setStyle("-fx-background-color: #f0f4f8;");
        detailVBox.setStyle("-fx-background-color: #f0f4f8;");

        // ScrollPane para la lista de items
        scrollPane.setContent(contentVBox);
        scrollPane.setFitToWidth(true);

        // ChoiceBox siempre arriba
        choiceBox.getItems().add("Games");
        choiceBox.getItems().add("Consoles");
        choiceBox.getItems().add("Characters");
        choiceBox.setValue("Games");

        // Cargar primera categoría
        loadAndShow("Games");

        // Listener para cambio de selección
        choiceBox.getSelectionModel().selectedItemProperty().addListener((obs, oldVal, newVal) -> {
            loadAndShow(newVal);
        });
    }

    private void loadAndShow(String type) {
        contentVBox.getChildren().clear();
        detailVBox.getChildren().clear();

        JSONArray jsonData = null;
        try {
            jsonData = loadJSONArray("/assets/data/" + type.toLowerCase() + ".json");
        } catch (Exception e) {
            System.err.println("Error cargando JSON: " + type);
            e.printStackTrace();
            return;
        }

        for (int i = 0; i < jsonData.length(); i++) {
            JSONObject obj = jsonData.getJSONObject(i);

            String name = "No Name";
            String imagePath = null;
            try { name = obj.getString("name"); } catch (Exception ignored) {}
            try { imagePath = "/assets/images/" + obj.getString("image"); } catch (Exception ignored) {}

            try { addListItem(name, imagePath, obj); } catch (Exception e) {
                System.err.println("Error creando item: " + name);
                e.printStackTrace();
            }
        }

        if (jsonData.length() > 0) {
            try { showDetail(jsonData.getJSONObject(0)); } catch (Exception e) {
                System.err.println("Error mostrando detalle inicial");
                e.printStackTrace();
            }
        }
    }

    private void addListItem(String title, String imagePath, JSONObject jsonItem) throws IOException {
        URL resource = getClass().getResource("/assets/listItem.fxml");
        FXMLLoader loader = new FXMLLoader(resource);
        Parent item = loader.load();

        ControllerListItem itemController = loader.getController();
        itemController.setTitle(title);
        itemController.setImatge(imagePath);

        item.setOnMouseClicked(e -> showDetail(jsonItem));

        contentVBox.getChildren().add(item);
    }

    private void showDetail(JSONObject obj) {
        detailVBox.getChildren().clear();
        detailVBox.setAlignment(Pos.CENTER);
        detailVBox.setSpacing(10);

        // Contenedor blanco para los textos
        VBox textContainer = new VBox(10);
        textContainer.setStyle("-fx-background-color: white; -fx-padding: 15px; -fx-border-radius: 10px; -fx-background-radius: 10px;");
        textContainer.setAlignment(Pos.CENTER);

        // Título grande
        Label titleLabel = new Label();
        try { titleLabel.setText(obj.optString("name", "No Name")); } catch (Exception e) { titleLabel.setText("No Name"); }
        titleLabel.setStyle("-fx-font-size: 24px; -fx-font-weight: bold;");
        titleLabel.setWrapText(true);
        titleLabel.setAlignment(Pos.CENTER);
        titleLabel.setMaxWidth(350);

        // Imagen grande
        Image image = null;
        String imageFile = null;
        try {
            imageFile = obj.optString("image", null);
            if (imageFile != null) image = new Image(getClass().getResourceAsStream("/assets/images/" + imageFile));
        } catch (Exception e) { image = null; }

        ImageView imageView = new ImageView();
        imageView.setPreserveRatio(true);
        imageView.setFitWidth(200);
        imageView.setFitHeight(200);
        imageView.setSmooth(true);
        if (image != null) imageView.setImage(image);

        textContainer.getChildren().add(titleLabel);

        // Campos del JSON
        for (String key : obj.keySet()) {
            if (key.equals("name") || key.equals("image")) continue;

            String value = "N/A";
            try { value = obj.optString(key, "N/A"); } catch (Exception ignored) {}

            String formattedKey = capitalize(key.replace("_", " "));
            boolean isColorField = key.equalsIgnoreCase("color") || key.toLowerCase().endsWith("_color");

            if (isColorField && isColor(value)) {
                Label label = new Label(formattedKey + ":");
                label.setStyle("-fx-font-weight: bold;");
                label.setAlignment(Pos.CENTER);

                Circle colorCircle = new Circle(10);
                try { colorCircle.setFill(Color.web(value)); } catch (Exception e) { colorCircle.setFill(Color.GRAY); }

                VBox colorBox = new VBox(5, label, colorCircle);
                colorBox.setAlignment(Pos.CENTER);
                textContainer.getChildren().add(colorBox);
            } else {
                Label label = new Label(formattedKey + ": " + value);
                label.setWrapText(true);
                label.setMaxWidth(350);
                label.setAlignment(Pos.CENTER);
                textContainer.getChildren().add(label);
            }
        }

        detailVBox.getChildren().addAll(imageView, textContainer);
    }

    private String capitalize(String text) {
        if (text == null || text.isEmpty()) return "";
        return text.substring(0, 1).toUpperCase() + text.substring(1);
    }

    private boolean isColor(String value) {
        try { Color.web(value); return true; } catch (Exception e) { return false; }
    }

    private JSONArray loadJSONArray(String resourcePath) throws Exception {
        URL url = getClass().getResource(resourcePath);
        if (url == null) throw new IOException("No se encuentra el recurso: " + resourcePath);
        Path path = Paths.get(url.toURI());
        String content = Files.readString(path, StandardCharsets.UTF_8);
        return new JSONArray(content);
    }
}
