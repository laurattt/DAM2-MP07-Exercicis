package com.project;


import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;

public class Main extends Application {

    final int WINDOW_WIDTH = 300; //aqui falta ver la vista para desktop 
    final int WINDOW_HEIGHT = 400;

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage stage) throws Exception {

        UtilsViews.parentContainer.setStyle("-fx-font: 14 arial;");
        UtilsViews.addView(getClass(), "ViewMain", "/assets/viewMain.fxml"); // check
        UtilsViews.addView(getClass(), "ViewCharacters", "/assets/viewCharacters.fxml");
        UtilsViews.addView(getClass(), "ViewGames", "/assets/viewGames.fxml");
        UtilsViews.addView(getClass(), "ViewConsoles", "/assets/viewConsoles.fxml");

        UtilsViews.addView(getClass(), "ViewCharacter", "/assets/viewCharacter.fxml");
        UtilsViews.addView(getClass(), "ViewGame", "/assets/viewGame.fxml");
        UtilsViews.addView(getClass(), "ViewConsole", "/assets/viewConsole.fxml");

        Scene scene = new Scene(UtilsViews.parentContainer);

        stage.setScene(scene);
        stage.setTitle("Nintendo DB");
        stage.setWidth(WINDOW_WIDTH);
        stage.setHeight(WINDOW_HEIGHT);
        stage.show();

        // Afegeix una icona només si no és un Mac
        if (!System.getProperty("os.name").contains("Mac")) {
            Image icon = new Image("file:icons/icon.png");
            stage.getIcons().add(icon);
        }
    }
}



// En el main solo agregamos las vistas 


// ./run.ps1 com.project.Main