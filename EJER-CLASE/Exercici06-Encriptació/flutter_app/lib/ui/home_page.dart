import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../services/file_service.dart';
import '../services/crypto_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1117),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1117),
          title: const Row(
            children: [
              Icon(Icons.lock_outline, color: Color(0xFF7C6AF7)),
              SizedBox(width: 8),
              Text('RSA Tool', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFF7C6AF7),
            labelColor: Color(0xFF7C6AF7),
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(icon: Icon(Icons.lock), text: 'Encriptar'),
              Tab(icon: Icon(Icons.lock_open), text: 'Desencriptar'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [EncryptPanel(), DecryptPanel()],
        ),
      ),
    );
  }
}

class _FilePicker extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? selectedPath;
  final VoidCallback onTap;

  const _FilePicker({
    required this.label,
    required this.icon,
    required this.selectedPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = selectedPath != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E1B3A) : const Color(0xFF2C2F3E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF7C6AF7) : Colors.white38,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF7C6AF7) : Colors.white60, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    selected ? p.basename(selectedPath!) : 'Toca para seleccionar...',
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.white54,
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.chevron_right,
              color: selected ? const Color(0xFF7C6AF7) : Colors.white54,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class EncryptPanel extends StatefulWidget {
  const EncryptPanel({super.key});

  @override
  State<EncryptPanel> createState() => _EncryptPanelState();
}

class _EncryptPanelState extends State<EncryptPanel> {
  final fileService = FileService();
  final cryptoService = CryptoService();

  String? publicKeyPath;
  String? fileToEncryptPath;
  bool _loading = false;

  Future<void> _pick(void Function(String) onPicked) async {
    final path = await fileService.pickFile();
    if (path != null) setState(() => onPicked(path));
  }

  Future<void> _encrypt() async {
    if (publicKeyPath == null || fileToEncryptPath == null) {
      _snack('Selecciona los dos archivos primero', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final out = '$fileToEncryptPath.enc';
      await cryptoService.encryptFile(
        inputFilePath: fileToEncryptPath!,
        publicKeyPath: publicKeyPath!,
        outputFilePath: out,
      );
      _snack('Guardado como ${p.basename(out)}');
    } catch (e) {
      _snack('$e', error: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red[800] : const Color(0xFF7C6AF7),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Archivos necesarios',
              style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 12),
          _FilePicker(
            label: 'Clave pública (.pem)',
            icon: Icons.vpn_key_outlined,
            selectedPath: publicKeyPath,
            onTap: () => _pick((v) => publicKeyPath = v),
          ),
          const SizedBox(height: 10),
          _FilePicker(
            label: 'Archivo a encriptar',
            icon: Icons.insert_drive_file_outlined,
            selectedPath: fileToEncryptPath,
            onTap: () => _pick((v) => fileToEncryptPath = v),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C6AF7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loading ? null : _encrypt,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.lock),
              label: Text(_loading ? 'Encriptando...' : 'Encriptar archivo'),
            ),
          ),
        ],
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

  String? privateKeyPath;
  String? fileToDecryptPath;
  String? outputFilePath;
  bool _loading = false;

  Future<void> _pick(void Function(String) onPicked) async {
    final path = await fileService.pickFile();
    if (path != null) setState(() => onPicked(path));
  }

  Future<void> _decrypt() async {
    if (privateKeyPath == null || fileToDecryptPath == null || outputFilePath == null) {
      _snack('Selecciona los tres archivos primero', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await cryptoService.decryptFile(
        inputFilePath: fileToDecryptPath!,
        privateKeyPath: privateKeyPath!,
        outputFilePath: outputFilePath!,
      );
      _snack('¡Desencriptado con éxito!');
    } catch (e) {
      _snack('$e', error: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red[800] : Colors.green[700],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Archivos necesarios',
              style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 12),
          _FilePicker(
            label: 'Clave privada (.pem)',
            icon: Icons.vpn_key,
            selectedPath: privateKeyPath,
            onTap: () => _pick((v) => privateKeyPath = v),
          ),
          const SizedBox(height: 10),
          _FilePicker(
            label: 'Archivo encriptado (.enc)',
            icon: Icons.lock_outline,
            selectedPath: fileToDecryptPath,
            onTap: () => _pick((v) => fileToDecryptPath = v),
          ),
          const SizedBox(height: 10),
          _FilePicker(
            label: 'Destino (archivo de salida)',
            icon: Icons.save_alt_outlined,
            selectedPath: outputFilePath,
            onTap: () => _pick((v) => outputFilePath = v),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loading ? null : _decrypt,
              icon: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.lock_open),
              label: Text(_loading ? 'Desencriptando...' : 'Desencriptar archivo'),
            ),
          ),
        ],
      ),
    );
  }
}
