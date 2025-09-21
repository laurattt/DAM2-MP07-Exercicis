package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.event.ActionEvent;

public class Controller {

    @FXML
    private TextField display;

    private double num1 = 0;
    private String operador = "";
    private boolean start = true;

    @FXML
    private void handleNumber(ActionEvent event) {
        String value = ((Button) event.getSource()).getText();
        if (start) {
            display.setText("");
            start = false;
        }
        display.setText(display.getText() + value);
    }

    @FXML
    private void handleOperator(ActionEvent event) {
        String value = ((Button) event.getSource()).getText();
        if (!display.getText().isEmpty()) {
            num1 = Double.parseDouble(display.getText());
            operador = value;
            display.setText(display.getText() + value); // No borra, añade el operador
            start = false;
        }
    }
    @FXML
    private void handleClear(ActionEvent event) {
        display.setText("");
        operador = "";
        num1 = 0;
        start = true;
    }

    @FXML
    private void handleEqual(ActionEvent event) {
        if (operador.isEmpty() || display.getText().isEmpty()) {
            return;
        }
        String text = display.getText();
        int opIndex = text.indexOf(operador);
        if (opIndex == -1 || opIndex == text.length() - 1) {
            return; // No hay segundo número
        }
        String num2Str = text.substring(opIndex + 1);
        double num2;
        try {
            num2 = Double.parseDouble(num2Str);
        } catch (NumberFormatException e) {
            display.setText("Error");
            operador = "";
            start = true;
            return;
        }
        double result = 0;
        switch (operador) {
            case "+":
                result = num1 + num2;
                break;
                
            case "-":
                result = num1 - num2;
                break;

            case "*":
                result = num1 * num2;
                break;

            case "/":
                if (num2 != 0) {
                    result = num1 / num2;
                } else {
                    display.setText("Error");
                    operador = "";
                    start = true;
                    return;
                }
                break;
        }
        display.setText(String.valueOf(result));
        operador = "";
        start = true;
    }
}