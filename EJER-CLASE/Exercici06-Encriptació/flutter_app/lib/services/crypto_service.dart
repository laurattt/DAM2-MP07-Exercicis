import 'dart:io';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class CryptoService {

  Future<void> encryptFile({
    required String inputFilePath,
    required String publicKeyPath,
    required String outputFilePath,
  }) async {

    final inputFile = File(inputFilePath);
    final publicKeyFile = File(publicKeyPath);

    final inputBytes = await inputFile.readAsBytes();
    final publicKeyString = await publicKeyFile.readAsString();

    final publicKey = RSAKeyParser().parse(publicKeyString) as RSAPublicKey;

    final encrypter = Encrypter(RSA(publicKey: publicKey));

    final encrypted = encrypter.encryptBytes(inputBytes);

    final outputFile = File(outputFilePath);
    await outputFile.writeAsBytes(encrypted.bytes);
  }

  Future<void> decryptFile({
    required String inputFilePath,
    required String privateKeyPath,
    required String outputFilePath,
  }) async {

    final inputFile = File(inputFilePath);
    final privateKeyFile = File(privateKeyPath);

    final encryptedBytes = await inputFile.readAsBytes();
    final privateKeyString = await privateKeyFile.readAsString();

    final privateKey = RSAKeyParser().parse(privateKeyString) as RSAPrivateKey;

    final encrypter = Encrypter(RSA(privateKey: privateKey));

    final decrypted = encrypter.decryptBytes(
      Encrypted(encryptedBytes),
    );

    final outputFile = File(outputFilePath);
    await outputFile.writeAsBytes(decrypted);
  }
}