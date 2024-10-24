import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(MaterialApp(home: QRCodeApp()));
}

class QRCodeApp extends StatefulWidget {
  @override
  _QRCodeAppState createState() => _QRCodeAppState();
}

class _QRCodeAppState extends State<QRCodeApp> {
  List<TextEditingController> controllers = [];
  List<String> fieldLabels = [];
  TextEditingController fieldNameController = TextEditingController();
  String qrData = '';
  bool isScanning = false;

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    fieldNameController.dispose();
    super.dispose();
  }

  void addField() {
    if (fieldNameController.text.isNotEmpty) {
      setState(() {
        controllers.add(TextEditingController());
        fieldLabels.add(fieldNameController.text);
        fieldNameController.clear();
      });
    }
  }

  void generateQRData() {
    String qrContent = '';
    for (int i = 0; i < controllers.length; i++) {
      qrContent += '${fieldLabels[i]}: ${controllers[i].text}\n';
    }
    setState(() {
      qrData = qrContent;
    });
  }

  void scanQR() {
    setState(() {
      isScanning = true;
    });
    MobileScanner(
      onDetect: (barcode, args) {
        if (barcode.rawValue != null) {
          setState(() {
            qrData = barcode.rawValue!;
            isScanning = false;
          });
          parseQRData(qrData);
        }
      },
    );
  }

  void parseQRData(String data) {
    List<String> lines = data.split('\n');
    for (String line in lines) {
      if (line.isNotEmpty) {
        List<String> parts = line.split(': ');
        if (parts.length == 2) {
          setState(() {
            fieldLabels.add(parts[0]);
            controllers.add(TextEditingController(text: parts[1]));
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Générateur de Code QR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: fieldNameController,
              decoration: InputDecoration(labelText: 'Nom du nouveau champ'),
            ),
            ElevatedButton(
              onPressed: addField,
              child: Text('Ajouter un champ'),
            ),
            SizedBox(height: 16),
            ...List.generate(controllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: controllers[index],
                  decoration: InputDecoration(labelText: fieldLabels[index]),
                ),
              );
            }),
            Spacer(),
            ElevatedButton(
              onPressed: generateQRData,
              child: Text('Générer le QR code'),
            ),
            if (qrData.isNotEmpty)
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200,
              ),
            ElevatedButton(
              onPressed: scanQR,
              child: Text('Scanner un QR code'),
            ),
            if (isScanning)
              Expanded(
                child: MobileScanner(
                  onDetect: (barcode, args) {
                    if (barcode.rawValue != null) {
                      setState(() {
                        qrData = barcode.rawValue!;
                        isScanning = false;
                      });
                      parseQRData(qrData);
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
