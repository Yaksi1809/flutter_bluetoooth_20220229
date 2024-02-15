import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bluetooth',
      home: Bluetooth(),
    );
  }
}

class Bluetooth extends StatefulWidget {
  const Bluetooth({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BluetoothState createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {
  FlutterBluePlus flutterBluePlus = FlutterBluePlus();
  List<ScanResult> dispositivo = [];
  bool scanning = false;
  BluetoothDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  _startScan() {
    setState(() {
      scanning = true;
    });
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        dispositivo = results;
      });
    });
  }

  _connectToDevice(BluetoothDevice device)  async {
    // ignore: deprecated_member_use
    if (connectedDevice != null && connectedDevice!.id == device.id) {
      await connectedDevice!.disconnect();
      setState(() {
        connectedDevice = null;
      });
    } else {
      try {
        await device.connect();
        setState(() {
          connectedDevice = device;
        });
      } catch (error) {
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              // ignore: deprecated_member_use
              title: const Text('Connection error'),
              content: const Text(
                  'Could not connect to the device. Please try again later.'),
              actions: <Widget>[
                TextButton(
                  child:const Text('Accept'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Device'),
      ),
      body: 
        ListView.builder(
          itemCount: dispositivo.length,
            itemBuilder: (context, index) {
              return ListTile(
                // ignore: deprecated_member_use
                title: Text(dispositivo[index].device.name),
                // ignore: deprecated_member_use
                subtitle: Text(dispositivo[index].device.id.toString()),                
                trailing: ElevatedButton(
                onPressed: () =>
                   _connectToDevice(dispositivo[index].device),
                    // ignore: deprecated_member_use
                    child: connectedDevice != null && connectedDevice!.id == dispositivo[index].device.id
                        ? const Text('Disconnect')
                        : const Text('Connect'),
                  ),
                );
              },
            ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _startScan(),
        child: const Icon(Icons.bluetooth_searching),
      ),
    );
  }
}