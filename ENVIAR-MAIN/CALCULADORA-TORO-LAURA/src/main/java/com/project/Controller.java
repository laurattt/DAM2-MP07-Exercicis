package com.project;

import javafx.fxml.FXML;
import javafx.scene.control.Button;
import javafx.scene.control.TextField;
import javafx.event.ActionEvent;

public class Controller {

    // VARIABLES 
    @FXML
    private TextField textField;

    private double num1 = 0;
    private String operador = "";
    private boolean start = true;


    // Método que recupera el contenido que hay dentro del botón, en este caso los NUMEROS
    @FXML
    private void numberAction(ActionEvent event) {
        String value = ((Button) event.getSource()).getText();
        //System.out.println(value);
        if (start) {
            textField.setText("");
            start = false; 
        // Si start es true, elimina lo que había dentro del textField --> cambia en los botones "=" y "CLEAR"
        // Si start es false, se van agregando los numeros con su operador --> btnNums y operadores           
    
        }
        textField.setText(textField.getText() + value);
    }


    // Método que recupera el contenido que hay dentro del botón, en este caso los OPERADORES
    @FXML
    private void operatorAction(ActionEvent event) {
        String value = ((Button) event.getSource()).getText();
        //System.out.println(value);

        if (!textField.getText().isEmpty()) {
            num1 = Double.parseDouble(textField.getText());
            operador = value;
            textField.setText(textField.getText() + value); // No borra, añade el operador
            start = false;
        }
    }

    // Este método limpia el textField e inicializa variables
    @FXML
    private void clearAction(ActionEvent event) {
        textField.setText("");
        operador = "";
        num1 = 0;
        start = true;
    }

    // Este método se encarga de dar los resultados cada que se presione el "="
    @FXML
    private void equalAction(ActionEvent event) {

        // Si esta vacío, devuelve vacío 
        if (operador.isEmpty() || textField.getText().isEmpty()) {
            return;
        }

        String text = textField.getText(); //guarda el texto del textField
        int opIndex = text.indexOf(operador); //busca el operador en la cadena
        if (opIndex == -1 || opIndex == text.length() - 1) {
            return; // este if detecta si hay segundo num 
        }

        String num2Str = text.substring(opIndex + 1); // extrae lo que está después del operador
        double num2;
        try {
            num2 = Double.parseDouble(num2Str); // aqui intenta convertir el num extraido en double, si no es válido el valor salta excepción 
        } catch (NumberFormatException e) {
            textField.setText("Error");
            operador = "";
            start = true;
            return;
        }

        // lógica calculadora
        double result = 0;
        switch (operador) { // este parametro de operador queda guardado con el listener "operatorAction", asi lo detecta en los case
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
                    textField.setText("Error");
                    operador = "";
                    start = true;
                    return;
                }
                break;
        }

        // Al final salta el resultado y se inicializan las variables 
        textField.setText(String.valueOf(result));
        operador = "";
        start = true;
    }
}