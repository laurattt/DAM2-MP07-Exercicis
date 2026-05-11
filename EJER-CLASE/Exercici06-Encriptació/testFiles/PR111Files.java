package com.project;

import java.nio.file.Files;
import java.nio.file.Path;

public class PR111Files {

    public static void main(String[] args) {
        String camiFitxer = System.getProperty("user.dir") + "/data/pr111";
        gestionarArxius(camiFitxer);
    }

   public static void gestionarArxius(String camiFitxer) {
        Path directory = Path.of(camiFitxer);
        try {
            // aqui crea direct si no existe
            Files.createDirectories(directory);

            // crea subcarpeta --> "myFiles" dentro del directorio
            Path carpeta = directory.resolve("myFiles");
            Files.createDirectories(carpeta);

            // crea archivos --> file1.txt y file2.txt dentro de "myFiles"
            Path file1 = carpeta.resolve("file1.txt");
            Path file2 = carpeta.resolve("file2.txt");
            Files.createFile(file1);
            Files.createFile(file2);

            // renombra file2.txt a renamedFile.txt
            Path renamedFile = carpeta.resolve("renamedFile.txt");
            Files.move(file2, renamedFile);

            // borra file1.txt
            Files.deleteIfExists(file1);

            // al final solo queda renamedFile.txt en la carpeta
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
