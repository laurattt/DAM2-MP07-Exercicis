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

    @FXML
    private void toView1(ActionEvent event) {

        String name = textFieldName.getText();
        Main.name = name;

        String age = textFieldAge.getText();
        Main.age = age;

        Controller1 controller1 = (Controller1) UtilsViews.getController("View1");
        controller1.updateTextOutput();

        UtilsViews.setViewAnimating("View1");
    }

    @FXML
    private void initialize() {

        buttonNextView.setDisable(true);

        // Vincular un listener a cada textField para gestionar la habilitación de buttonNextView
        textFieldName.textProperty().addListener(ignore -> updateButton());
        textFieldAge.textProperty().addListener(ignore -> updateButton());
    }

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
