package com.project;

import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.fxml.Initializable;
import javafx.geometry.Pos;
import javafx.scene.Parent;
import javafx.scene.control.Label;
import javafx.scene.control.ScrollPane;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.Region;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;
import javafx.scene.text.Text;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ResourceBundle;

public class ControllerMobile implements Initializable {

    @FXML private Text headerTitle;
    @FXML private ImageView backArrow;
    @FXML private ScrollPane scrollPane;
    @FXML private VBox mainContent;

    private ViewState currentState;
    private String currentCategory;
    private JSONArray currentData;

    private enum ViewState { MAIN_MENU, CATEGORY_LIST, ITEM_DETAIL }

    @Override
    public void initialize(URL url, ResourceBundle resourceBundle) {
        // Configurar flecha de regreso
        backArrow.setImage(new Image(getClass().getResourceAsStream("/assets/images/arrow-back.png")));
        backArrow.setOnMouseClicked(e -> goBack());

        scrollPane.setFitToWidth(true);
        scrollPane.setFitToHeight(true);

        loadMainMenu();
    }

    private void loadMainMenu() {
        currentState = ViewState.MAIN_MENU;
        headerTitle.setText("Nintendo DB");
        backArrow.setVisible(false);
        mainContent.getChildren().clear();

        String[] options = {"Characters", "Games", "Consoles"};

        for (String option : options) {
            Label label = new Label(option);
            label.setStyle("-fx-font-size: 18px; -fx-padding: 16px; -fx-background-color: #3498db; -fx-background-radius: 8; -fx-text-fill: white;");
            label.setMaxWidth(Double.MAX_VALUE);
            label.setAlignment(Pos.CENTER);
            label.setOnMouseClicked(e -> loadCategory(option));
            mainContent.getChildren().add(label);
        }
    }

    private void loadCategory(String category) {
        currentState = ViewState.CATEGORY_LIST;
        currentCategory = category;
        headerTitle.setText(category);
        backArrow.setVisible(true);
        mainContent.getChildren().clear();

        try {
            URL url = getClass().getResource("/assets/data/" + category.toLowerCase() + ".json");
            if (url == null) {
                throw new IOException("No se encuentra el recurso: " + category);
            }

            Path path = Paths.get(url.toURI());
            String content = Files.readString(path, StandardCharsets.UTF_8);
            currentData = new JSONArray(content);

        } catch (Exception e) {
            try {
                java.io.InputStream is = getClass().getResourceAsStream("/assets/data/" + category.toLowerCase() + ".json");
                if (is == null) {
                    throw new IOException("No se pudo leer el recurso como Stream.");
                }
                byte[] bytes = is.readAllBytes();
                String content = new String(bytes, StandardCharsets.UTF_8);
                currentData = new JSONArray(content);
            } catch (Exception ex) {
                System.err.println("Error al cargar la categoría: " + category);
                ex.printStackTrace();
                return;
            }
        }

        for (int i = 0; i < currentData.length(); i++) {
            try {
                JSONObject obj = currentData.getJSONObject(i);
                FXMLLoader loader = new FXMLLoader(getClass().getResource("/assets/listItem.fxml"));
                Parent listItem = loader.load();

                ControllerListItem itemController = loader.getController();
                itemController.setTitle(obj.optString("name", "No Name"));
                itemController.setImatge("/assets/images/" + obj.optString("image", ""));

                int index = i;
                listItem.setOnMouseClicked(e -> loadDetail(currentData.getJSONObject(index)));

                mainContent.getChildren().add(listItem);

            } catch (IOException e) {
                System.err.println("Error al cargar un item de la categoría: " + category);
                e.printStackTrace();
            }
        }
    }

    private void loadDetail(JSONObject obj) {
        currentState = ViewState.ITEM_DETAIL;
        headerTitle.setText(obj.optString("name", "No Name"));
        mainContent.getChildren().clear();

        VBox detailBox = new VBox(15);
        detailBox.setAlignment(Pos.CENTER);

        // Imagen
        String imageFile = obj.optString("image", null);
        if (imageFile != null) {
            try {
                Image image = new Image(getClass().getResourceAsStream("/assets/images/" + imageFile));
                ImageView imageView = new ImageView(image);
                imageView.setFitWidth(180);
                imageView.setFitHeight(180);
                imageView.setPreserveRatio(true);
                detailBox.getChildren().add(imageView);
            } catch (Exception e) {
                System.err.println("No se pudo cargar la imagen: " + imageFile);
            }
        }

        // Espacio
        Region spacer1 = new Region();
        spacer1.setPrefHeight(20);
        detailBox.getChildren().add(spacer1);

        // Color
        String colorKey = null;
        String colorValue = null;
        for (String key : obj.keySet()) {
            if ((key.equalsIgnoreCase("color") || key.toLowerCase().endsWith("_color")) && isColor(obj.optString(key))) {
                colorKey = key;
                colorValue = obj.optString(key);
                break;
            }
        }

        if (colorValue != null) {
            Circle circle = new Circle(15);
            try {
                circle.setFill(Color.web(colorValue));
            } catch (Exception e) {
                circle.setFill(Color.GRAY);
            }
            Label colorLabel = new Label(capitalize(colorKey.replace("_", " ")));
            colorLabel.setStyle("-fx-font-weight: bold; -fx-font-size: 16px;");
            VBox colorBox = new VBox(5);
            colorBox.setAlignment(Pos.CENTER);
            colorBox.getChildren().add(circle);
            colorBox.getChildren().add(colorLabel);
            detailBox.getChildren().add(colorBox);
        }

        // Espacio antes de detalles de texto
        Region spacer2 = new Region();
        spacer2.setPrefHeight(10);
        detailBox.getChildren().add(spacer2);

        // Detalles de texto
        for (String key : obj.keySet()) {
            if (key.equals("name") || key.equals("image") || key.equals(colorKey)) {
                continue;
            }

            String value = obj.optString(key);
            String formattedKey = capitalize(key.replace("_", " "));
            Label label = new Label(formattedKey + ": " + value);
            label.setWrapText(true);
            label.setMaxWidth(350);
            label.setAlignment(Pos.CENTER);

            if (key.equalsIgnoreCase("game") || key.equalsIgnoreCase("juego") || formattedKey.contains("Game")) {
                label.setStyle("-fx-font-size: 18px; -fx-font-weight: bold; -fx-text-fill: #000000ff;");
            } else {
                label.setStyle("-fx-font-size: 14px; -fx-text-fill: #000000ff;");
            }

            detailBox.getChildren().add(label);
        }

        mainContent.getChildren().add(detailBox);
    }

    private void goBack() {
        if (currentState == ViewState.CATEGORY_LIST) {
            loadMainMenu();
        } else if (currentState == ViewState.ITEM_DETAIL) {
            loadCategory(currentCategory);
        }
    }

    private boolean isColor(String value) {
        if (value == null || value.isEmpty()) {
            return false;
        }
        try {
            Color.web(value);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private String capitalize(String text) {
        if (text == null || text.isEmpty()) {
            return "";
        }
        String first = text.substring(0, 1).toUpperCase();
        String rest = text.substring(1);
        return first + rest;
    }
}
