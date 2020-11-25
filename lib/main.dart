import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';


BluetoothDevice device;
BluetoothCharacteristic c;

const characteristicUuid = "0000ffe1-0000-1000-8000-00805f9b34fb";
const serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";

void connect() async {

  FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));

  // Listen to scan results
  var subscription = FlutterBlue.instance.scanResults.listen((results) {
    // do something with scan results
    for (ScanResult r in results) {
//      print('${r.device.name} found! rssi: ${r.rssi}');
      if (r.device.name == 'DSD TECH') {
        print('Found the bluetooth module. Connecting.');
        device = r.device;
      }
    }
  });
  await device.connect();
  discoverServices();

//  cancelling subscription breaks things for some reason
  FlutterBlue.instance.stopScan();
}
void discoverServices() async {
  List<BluetoothService> services = await device.discoverServices();
  //checking each services provided by device
  services.forEach((service) {
    if (service.uuid.toString() == serviceUuid) {
      service.characteristics.forEach((characteristic) {
        if (characteristic.uuid.toString() == characteristicUuid) {
          //Updating characteristic to perform write operation.
          c = characteristic;
          print("Characteristic Set!");
        }
      });
    }
  });
}

void main() {
  runApp(MyApp());

  connect();
  discoverServices();

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'VerteChair Control'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _sendMessage(String msg) async {
    print("Attemping to send" + msg);

    List<int> data = utf8.encode(msg + "\n");
    await c.write(data);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          TextButton(
              child: Text('Connect to Chair'),
              onPressed: () {
                connect();
              }
          ),
          TextButton(
              child: Text('Send "A"'),
              onPressed: () {
                _sendMessage('A');
              }
          ),

          TextButton(
              child: Text('Send "B"'),
              onPressed: () {
                _sendMessage('B');
              }
          ),
          TextButton(
              child: Text('Send "C"'),
              onPressed: () {
                _sendMessage('C');
              }
          ),
        ],
      ),
    );
  }
}
