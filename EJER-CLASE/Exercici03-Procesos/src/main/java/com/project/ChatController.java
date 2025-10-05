package com.project;

import javafx.fxml.FXML;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.text.Text;

public class ChatController {

    @FXML private ImageView icon;
    @FXML private Text name;
    @FXML private Text message;

    // metodo para configurar el contenido del mensaje
    public void setData(String senderName, String msg, Image iconImage) {
        name.setText(senderName);
        message.setText(msg);
        if (iconImage != null) {
            icon.setImage(iconImage);
        }
    }
}
