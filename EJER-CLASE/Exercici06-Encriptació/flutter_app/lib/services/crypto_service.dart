import 'dart:io';
import 'dart:math';
import 'dart:typed_data'; // libreria para cifrado AES
import 'package:encrypt/encrypt.dart'; // libreria que encripta y desencripta
import 'package:pointycastle/asymmetric/api.dart';

class CryptoService {
  Future<void> encryptFile({
    required String inputFilePath,
    required String publicKeyPath,
    required String outputFilePath,
  }) async {
    // lectura en bytes y la public key como PEM
    final inputBytes = await File(inputFilePath).readAsBytes();
    final publicKeyString = await File(publicKeyPath).readAsString();

    // valid public keyyyy
    final parsed = RSAKeyParser().parse(publicKeyString);
    if (parsed is! RSAPublicKey)
      throw Exception('El archivo seleccionado no es una clave pública RSA');

    final random = Random.secure();

    // contraseña secreta AES (funciona como candado)
    final aesKeyBytes = Uint8List.fromList(
      List.generate(32, (_) => random.nextInt(256)),
    );

    // aqui el ivbytes genera cifrado unico
    final ivBytes = Uint8List.fromList(
      List.generate(16, (_) => random.nextInt(256)),
    );

    // se cifra utilizando la clave aes (sobre sellado)
    final aesKey = Key(aesKeyBytes);
    final iv = IV(ivBytes);
    final aesEncrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
    final encryptedData = aesEncrypter.encryptBytes(inputBytes, iv: iv);

    // se cifra clave aes con la key
    final rsaEncrypter = Encrypter(RSA(publicKey: parsed));
    final encryptedAesKey = rsaEncrypter.encryptBytes(aesKeyBytes);

    // se construye el archivo de salida
    final keyLength = encryptedAesKey.bytes.length;
    final output = BytesBuilder();
    output.add(
      Uint8List(4)..buffer.asByteData().setInt32(0, keyLength, Endian.big),
    );
    output.add(encryptedAesKey.bytes);
    output.add(ivBytes);
    output.add(encryptedData.bytes);

    print('[CryptoService] Archivo cifrado guardado en: $outputFilePath');
    await File(outputFilePath).writeAsBytes(output.toBytes());
  }

  //tengo mi archivo, le doy una clave aes para cifrarlo, despues con mi public key cifro esa clave aes y empaqueto para obtener mi .enc

  Future<void> decryptFile({
    required String inputFilePath,
    required String privateKeyPath,
    required String outputFilePath,
  }) async {
    final inputBytes = await File(inputFilePath).readAsBytes();
    final privateKeyString = await File(privateKeyPath).readAsString();

    final parsed = RSAKeyParser().parse(privateKeyString);
    if (parsed is! RSAPrivateKey)
      throw Exception('El archivo seleccionado no es una clave privada RSA');

    // lectura clave AES
    final keyLength = ByteData.sublistView(
      inputBytes,
      0,
      4,
    ).getInt32(0, Endian.big);

    // se extrae seccion del archivo, prim 4 tamaño detecta longitud clave aes
    final encryptedAesKey = inputBytes.sublist(4, 4 + keyLength);
    final ivBytes = inputBytes.sublist(4 + keyLength, 4 + keyLength + 16);
    final encryptedData = inputBytes.sublist(4 + keyLength + 16);
    //desencripta con aes + key

    // se descifra clave aes con private_key
    final rsaEncrypter = Encrypter(RSA(privateKey: parsed));
    final aesKeyBytes = rsaEncrypter.decryptBytes(Encrypted(encryptedAesKey));

    // se descifra el archivo y se recupera
    final aesKey = Key(Uint8List.fromList(aesKeyBytes));
    final iv = IV(Uint8List.fromList(ivBytes));
    final aesEncrypter = Encrypter(AES(aesKey, mode: AESMode.cbc));
    final decrypted = aesEncrypter.decryptBytes(
      Encrypted(encryptedData),
      iv: iv,
    );

    await File(outputFilePath).writeAsBytes(decrypted);
  }
}
