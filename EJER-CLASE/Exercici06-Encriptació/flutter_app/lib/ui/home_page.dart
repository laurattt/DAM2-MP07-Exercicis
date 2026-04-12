import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../services/file_service.dart';
import '../services/crypto_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Expanded(child: EncryptPanel()),
            SizedBox(width: 16),
            Expanded(child: DecryptPanel()),
          ],
        ),
      ),
    );
  }
}

class EncryptPanel extends StatefulWidget {
  const EncryptPanel({super.key});

  @override
  State<StatefulWidget> createState() => _EncryptPanelState();
}

class _EncryptPanelState extends State<EncryptPanel> {
  final fileService = FileService();
  final cryptoService = CryptoService();

  String? publicKeyPath;
  String? fileToEncryptPath;

  final publicKeyController = TextEditingController();
  final fileController = TextEditingController();

  Future<void> selectPublicKey() async {

    final path = await fileService.pickFile();

    if (path == null) return;

    setState(() {
      publicKeyPath = path;
      publicKeyController.text = p.basename(path);
    });
  }

  Future<void> selectFileToEncrypt() async {

    final path = await fileService.pickFile();

    if (path == null) return;

    setState(() {
      fileToEncryptPath = path;
      fileController.text = p.basename(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Encriptar",
                style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 20),

            const Text("Clave pública (RSA):"),

            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: publicKeyController,
                    readOnly: true,
                  ),
                ),

                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed: selectPublicKey,
                  child: const Text("Selecciona..."),
                )
              ],
            ),

            const SizedBox(height: 16),

            const Text("Archivo a encriptar:"),

            Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: fileController,
                    readOnly: true,
                  ),
                ),

                const SizedBox(width: 8),

                ElevatedButton(
                  onPressed: selectFileToEncrypt,
                  child: const Text("Navega..."),
                )
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (publicKeyPath == null || fileToEncryptPath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Selecciona todos los archivos primero")),
                    );
                    return;
                  }

                  //ruta definida, archivo.txt -> archivo.txt.enc
                  final outputFilePath = '$fileToEncryptPath.enc';

                  try {
                    // indicador carga - ejecutar
                    await cryptoService.encryptFile(
                      inputFilePath: fileToEncryptPath!,
                      publicKeyPath: publicKeyPath!,
                      outputFilePath: outputFilePath,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("¡Archivo encriptado en: ${p.basename(outputFilePath)}!")),
                      );
                    }
                  } catch (e) {
                    print(e);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: const Text("Encripta Archivo"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DecryptPanel extends StatefulWidget {
  const DecryptPanel({super.key});

  @override
  State<DecryptPanel> createState() => _DecryptPanelState();
}

class _DecryptPanelState extends State<DecryptPanel> {
  final fileService = FileService();
  final cryptoService = CryptoService();

  // rutas 
  String? privateKeyPath = "/home/super/.ssh/id_rsa";
  String? fileToDecryptPath;
  String? outputFilePath;

  // nombres archivos zzzz
  final privateKeyController = TextEditingController();
  final encryptedFileController = TextEditingController();
  final outputFileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    privateKeyController.text = p.basename(privateKeyPath!);
  }

  Future<void> selectPrivateKey() async {
    final path = await fileService.pickFile();
    if (path == null) return;
    setState(() {
      privateKeyPath = path;
      privateKeyController.text = p.basename(path);
    });
  }

  Future<void> selectFileToDecrypt() async {
    final path = await fileService.pickFile();
    if (path == null) return;
    setState(() {
      fileToDecryptPath = path;
      encryptedFileController.text = p.basename(path);
    });
  }

  Future<void> selectOutputPath() async {
    // pickfile para destino
    final path = await fileService.pickFile();
    if (path == null) return;
    setState(() {
      outputFilePath = path;
      outputFileController.text = p.basename(path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Desencriptar",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            // rsa
            const Text("Clave privada (RSA):"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: privateKeyController,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: selectPrivateKey,
                  child: const Text("Selecciona..."),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // arciv encrip
            const Text("Archivo encriptado:"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: encryptedFileController,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: selectFileToDecrypt,
                  child: const Text("Selecciona..."),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // archivo de salida
            const Text("Archivo desencriptado (Destino):"),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: outputFileController,
                    readOnly: true,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: selectOutputPath,
                  child: const Text("Selecciona"),
                ),
              ],
            ),

            const Spacer(),

            // accion button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (privateKeyPath == null || fileToDecryptPath == null || outputFilePath == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Por favor, selecciona los tres archivos necesarios")),
                    );
                    return;
                  }

                  try {
                    await cryptoService.decryptFile(
                      inputFilePath: fileToDecryptPath!,
                      privateKeyPath: privateKeyPath!,
                      outputFilePath: outputFilePath!,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("¡Archivo desencriptado con éxito!")),
                      );
                    }
                  } catch (e) {
                    print(e);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al desencriptar: $e"), backgroundColor: Colors.red),
                      );
                    }
                  }
                },
                child: const Text("Desencriptar Archivo"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}