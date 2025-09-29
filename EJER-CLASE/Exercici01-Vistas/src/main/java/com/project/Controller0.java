package com.project;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;

public class Controller0 {

    @FXML
    private Button buttonNextView;
    
    @FXML
    private TextField textFieldName;
    @FXML
    private TextField textFieldAge;

    @FXML // Este método pasa a la siguiente vista 
    private void toView1(ActionEvent event) {

        String name = textFieldName.getText();
        Main.name = name; // obtiene el nombre y lo guarda en la variable del main 

        String age = textFieldAge.getText();
        Main.age = age; // lo mismo que con el nombre

        // obtiene controlador y actualiza texto 
        Controller1 controller1 = (Controller1) UtilsViews.getController("View1");
        controller1.updateTextOutput();

        UtilsViews.setViewAnimating("View1"); // animación zz
    }

    @FXML
    private void initialize() { //al iniciar se activa está función 

        buttonNextView.setDisable(true); //aqui el boton no está activado, aún hay valores vacios

        // Añade listeners a los campos de texto para habilitar el botón solo si ambos tienen texto
        textFieldName.textProperty().addListener(ignore -> updateButton());
        textFieldAge.textProperty().addListener(ignore -> updateButton());
    }

    // Método para habilitar o deshabilitar el botón según si ambos campos tienen texto
    @FXML
    private void updateButton() {
        boolean thereIsName = textFieldName.getText().length() > 0;
        boolean thereIsAge = textFieldAge.getText().length() > 0;
        if (thereIsName && thereIsAge) {
            buttonNextView.setDisable(false);
        } else {
            buttonNextView.setDisable(true);
        }
    }
}
