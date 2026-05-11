import 'dart:io';
import 'package:encrypt/encrypt.dart'; // libreria de para cifrado
import 'package:pointycastle/asymmetric/api.dart';
// La clave pública (.pem) cifra los datos y solo la clave privada (.pem) puede descifrarlos.

class CryptoService {
  Future<void> encryptFile({
    required String inputFilePath, // archivo a cifrar
    required String publicKeyPath, // ruta key .pem public
    required String outputFilePath, // ruta de donde se guardara el cifrado
  }) async {
    final inputFile = File(inputFilePath); // lectura en bytes y key en texto
    final publicKeyFile = File(publicKeyPath);

    final inputBytes = await inputFile.readAsBytes();
    final publicKeyString = await publicKeyFile.readAsString();

    final parsed = RSAKeyParser().parse(publicKeyString);
    if (parsed is! RSAPublicKey)
      throw Exception(
        'El archivo seleccionado no es una clave pública RSA',
      ); // validacion de clave publica
    final publicKey = parsed;

    // se crea cifrado gracias a libreria zz
    final encrypter = Encrypter(RSA(publicKey: publicKey));

    // cofrado en bytes
    final encrypted = encrypter.encryptBytes(inputBytes);

    // escribir en en archivo bla bla
    final outputFile = File(outputFilePath);
    await outputFile.writeAsBytes(encrypted.bytes);
  }

  // descifra usando una key privada pemmm
  Future<void> decryptFile({
    required String inputFilePath,
    required String privateKeyPath,
    required String outputFilePath,
  }) async {
    // Leemos el archivo cifrado como bytes y la clave privada como texto PEM
    final inputFile = File(inputFilePath);
    final privateKeyFile = File(privateKeyPath);

    final encryptedBytes = await inputFile.readAsBytes();
    final privateKeyString = await privateKeyFile.readAsString();

    // RSAKeyParser interpreta el texto PEM; validamos que sea una clave privada
    final parsed = RSAKeyParser().parse(privateKeyString);
    if (parsed is! RSAPrivateKey)
      throw Exception('El archivo seleccionado no es una clave privada RSA');
    final privateKey = parsed;

    // funciones de libreria encrypt para descifrar
    final encrypter = Encrypter(RSA(privateKey: privateKey));
    final decrypted = encrypter.decryptBytes(Encrypted(encryptedBytes));

    // bytes descifrados en el archivo de salida
    final outputFile = File(outputFilePath);
    await outputFile.writeAsBytes(decrypted);
  }
}
