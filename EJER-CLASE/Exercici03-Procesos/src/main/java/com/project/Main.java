package com.project;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;

public class Main extends Application {

    final int WINDOW_WIDTH = 600;
    final int WINDOW_HEIGHT = 500;

    @Override
    public void start(Stage stage) throws Exception {
        // Carga el FXML desde /assets/layout.fxml
        Parent root = FXMLLoader.load(getClass().getResource("/assets/layout.fxml"));
        Scene scene = new Scene(root);

        stage.setScene(scene);
        stage.setTitle("IETI Chat");
        stage.setWidth(WINDOW_WIDTH);
        stage.setHeight(WINDOW_HEIGHT);

        // Agregar icono solo en Windows/Linux
        if (!System.getProperty("os.name").contains("Mac")) {
            try {
                Image icon = new Image(getClass().getResourceAsStream("/images/logo.png"));
                stage.getIcons().add(icon);
            } catch (Exception e) {
                System.out.println("No se pudo cargar el icono.");
            }
        }

        stage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
