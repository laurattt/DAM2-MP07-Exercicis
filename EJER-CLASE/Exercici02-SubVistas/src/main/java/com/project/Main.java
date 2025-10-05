package com.project;

import javafx.application.Application;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;

public class Main extends Application {

    final int MIN_WIDTH = 300;
    final int MIN_HEIGHT = 500;
    final int WINDOW_WIDTH = 300; // 800 
    final int WINDOW_HEIGHT = 400;

 
    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage stage) throws Exception {

        UtilsViews.parentContainer.setStyle("-fx-font: 14 arial;");
        UtilsViews.addView(getClass(), "Mobile", "/assets/layoutMobile.fxml");
        UtilsViews.addView(getClass(), "Desktop", "/assets/layoutDesktop.fxml");


        Scene scene = new Scene(UtilsViews.parentContainer);

        // Listen to window width changes
        scene.widthProperty().addListener((ChangeListener<? super Number>) new ChangeListener<Number>() {
            @Override
            public void changed(ObservableValue<? extends Number> observable, Number oldWidth, Number newWidth) {
                setLayout(newWidth.intValue());
            }
        });

        stage.setScene(scene);
        stage.setTitle("NintendoDB Laura Toro");
        stage.setMinWidth(MIN_WIDTH);
        stage.setWidth(WINDOW_WIDTH);
        stage.setMinHeight(MIN_HEIGHT);
        stage.setHeight(WINDOW_HEIGHT);
    
        setLayout(500);
        stage.show();
   
        // Add icon only if not Mac
        if (!System.getProperty("os.name").contains("Mac")) {
            Image icon = new Image("file:/icons/icon.png");
            stage.getIcons().add(icon);
        }
    }

    private void setLayout(int width) {
        if (width < 600) {
            UtilsViews.setView("Mobile");
        } else {
            UtilsViews.setView("Desktop");
        }
    }
}