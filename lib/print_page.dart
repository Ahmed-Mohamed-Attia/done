import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';


class PrintPage extends StatefulWidget {
  final List<String> userInputs;

  const PrintPage(this.userInputs, {Key? key}) : super(key: key);

  @override
  _PrintPageState createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? _selectedDevice;
  List<BluetoothDevice> devices = [];
  List<Map<String, String>> _formatReceiptItems(List<String> userInputs) {
    List<Map<String, String>> items = [];
    int index = 0;

    // Skip header information (وزارة الداخليه, etc.)
    index += 6;

    // Violation number
    items.add({
      'label': 'رقم المخالفه:',
      'value': userInputs[index++],
    });

    // Violator name
    items.add({
      'label': 'اسم المخالف:',
      'value': userInputs[index++],
    });

    // Vehicle number
    items.add({
      'label': 'رقم المركبه:',
      'value': userInputs[index++] + "-" + userInputs[index++],
    });

    // License
    items.add({
      'label': 'رخصه:',
      'value': userInputs[index++],
    });

    // Violations
    items.add({
      'label': 'المخالفات:',
      'value': userInputs[index++],
    });

    // Validity period
    items.add({
      'label': 'مده الصلاحيه:',
      'value': userInputs[index++] + ' ايام',
    });

    // Date
    items.add({
      'label': 'التاريخ:',
      'value': userInputs[index++],
    });

    // Time
    items.add({
      'label': 'الوقت:',
      'value': userInputs[index++],
    });

    // Issuing officer
    items.add({
      'label': 'محرر المخالفه:',
      'value': userInputs[index++],
    });

    // Issuing officer's department
    items.add({
      'label': 'جهه محرر المخالفه:',
      'value': userInputs[index++],
    });

    // Violation location
    items.add({
      'label': 'مكان المخالفه:',
      'value': userInputs[index++],
    });

    // Traffic department
    items.add({
      'label': 'اداره مرور:',
      'value': 'الاداره العامه القاهره',
    });

    return items;
  }
  void _scanForDevices() {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        print('${result.device.name} found! rssi: ${result.rssi}');
        if (!devices.contains(result.device)) {
          setState(() {
            devices.add(result.device);
          });
        }
      }
    });


    flutterBlue.stopScan();
  }

  Future<void> _print() async {
    if (_selectedDevice == null) {
      // Handle case where no device is selected
      return;
    }

    try {
      // Connect to the selected device
      await _selectedDevice!.connect();
    } catch (e) {
      // Handle connection errors
      print('Error connecting to device: $e');
      return;
    }

    // Discover all services
    List<BluetoothService> services = [];
    try {
      services = await _selectedDevice!.discoverServices();
    } catch (e) {
      // Handle service discovery errors
      print('Error discovering services: $e');
      return;
    }

    List<Map<String, String>> items = _formatReceiptItems(widget.userInputs);
    double total = 0.0; // Assuming no total price in this receipt

    String receipt = "";
    receipt += "**وزاره الداخليه**\n";
    receipt += "قطاع المرور\n";
    receipt += "الاداره العامه\n";
    receipt += "T.I.T\n";
    receipt += "\n";
    receipt += "**ايصال سحب رخصه**\n";
    receipt += "\n";

    for (var item in items) {
      receipt += "${item['label']}: ${item['value']}\n";
    }

    receipt += "\n";
    receipt += "**المخالفات**\n";
    receipt += "\n";

    // Add more lines for displaying violations if needed

    receipt += "\n";
    receipt += "**التوقيع:** .................\n";
    receipt += "\n";

    // Find the correct service for your printer (replace with actual service UUID)
    BluetoothService service = services.firstWhere((service) => service.uuid == Guid('00001800-0000-1000-8000-00805f9b34fb'));

    // Find the correct characteristic for your printer (replace with actual characteristic UUID)
    BluetoothCharacteristic characteristic = service.characteristics.firstWhere((characteristic) => characteristic.uuid == Guid('00002a00-0000-1000-8000-00805f9b34fb'));

    // Write data to the characteristic
    for (String input in widget.userInputs) {
      List<int> data = input.codeUnits;
      try {
      await characteristic.write(data);
    } catch (e) {
      // Handle write errors
      print('Error writing to characteristic: $e');
      return;
    }
    }

    // Disconnect from the device
    try {
      await _selectedDevice!.disconnect();
    } catch (e) {
      // Handle disconnection errors
      print('Error disconnecting from device: $e');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print'),
      ),
      body: Center(
        child: Column(
          children: [
            // Display UI for selecting Bluetooth device (if needed)
            DropdownButton<BluetoothDevice>(
              items: devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device.name),
                );
              }).toList(),
              onChanged: (device) => setState(() => _selectedDevice = device),
              hint: const Text('Select Device'),
            ),
            ElevatedButton(
              onPressed: _scanForDevices, // Call the scan function
              child: const Text('Scan for Devices'),
            ),
            ElevatedButton(
              onPressed: _print, // Call the print function
              child: const Text('Print'),
            ),
          ],
        ),
      ),
    );
  }
}
