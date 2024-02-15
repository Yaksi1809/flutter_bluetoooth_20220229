import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context)
  {
    return const MaterialApp(
      home: BluetoothApp(),
    );
  }
}

class BluetoothApp extends StatefulWidget
{
  const BluetoothApp({super.key});

  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp>
{
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devicesList = [];

  @override
  void initState()
  {
    super.initState();
    _startScanning();
  }


  void _startScanning()
  {
    flutterBlue.startScan(timeout: const Duration(seconds: 4));

    flutterBlue.scanResults.listen((results)
    {
      for (ScanResult r in results)
      {
        if (!devicesList.contains(r.device))
        {
          setState(() {
            devicesList.add(r.device);
          });
        }
      }
    });

    flutterBlue.isScanning.listen((isScanning) {
      print("Scanning: $isScanning");
    });
  }

  void _connectToDevice(BluetoothDevice device) async
  {
    try 
    {
      await device.connect(timeout: const Duration(seconds: 4));
      print("Connected to ${device.name}");
    } catch (e) {
      print("Error connecting to ${device.name}: $e");
    }
  }

  void _disconnectDevice(BluetoothDevice device)
  {
    device.disconnect();
    print("Disconnected from ${device.name}");
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Devices'),
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index){
          BluetoothDevice device = devicesList[index];
          return ListTile(
            title: Text(device.name ?? "Unknown Device"),
            subtitle: Text(device.id.toString()),
            trailing: ElevatedButton(
              onPressed: () => _connectToDevice(device),
              child: const Text('Connect'),
            ),
            onLongPress: () => _disconnectDevice(device),
          );
        }
      ),
    );
  }
}