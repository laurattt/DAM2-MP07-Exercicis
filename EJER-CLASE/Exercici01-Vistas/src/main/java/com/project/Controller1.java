package com.project;

import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.text.Text;

public class Controller1 {

    @FXML
    private Button buttonPreviousView; // regresamos a view0
    @FXML
    private Text textOutput; // este Text es donde aparecera nuestro output 

    @FXML
    private void toView0(ActionEvent event) {
        UtilsViews.setViewAnimating("View0");
    }

    @FXML
    protected void updateTextOutput() {
        String output = "Hola " + Main.name + ", tienes " + Main.age + " años";
        textOutput.setText(output);
    }
}
