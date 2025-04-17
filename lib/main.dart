import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(WiFiConfigApp());

class WiFiConfigApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 WiFi Config',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WiFiConfigPage(),
    );
  }
}

class WiFiConfigPage extends StatefulWidget {
  @override
  _WiFiConfigPageState createState() => _WiFiConfigPageState();
}

class _WiFiConfigPageState extends State<WiFiConfigPage> {
  final TextEditingController ssidController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String statusMessage = "Ready";

  // Fixed portion of the Flutter app (specifically the sendConfig function)

  Future<void> sendConfig(String ssid, String password) async {
    print('SSID: $ssid, Password: $password');
    if (ssid.isEmpty || password.isEmpty) {
      showMessage('Please enter both SSID and password');
      return;
    }

    setState(() {
      isLoading = true;
      statusMessage = "Sending configuration...";
    });

    try {
      // Simplified approach - use a single POST request with correct headers
      updateStatus("Connecting to ESP32...");

      final response = await http.post(
        Uri.parse('http://192.168.4.1/config'),
        body: {'ssid': ssid, 'password': password},
      ).timeout(Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        showMessage('Configuration Sent Successfully! ESP32 is rebooting...');
      } else {
        throw Exception("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      print('Error details: $e');
      showMessage(
          'Connection Error: Cannot reach ESP32. Ensure you are connected to the ESP32_Config WiFi network.');
      updateStatus("Connection failed. Please check your WiFi connection.");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void updateStatus(String message) {
    setState(() {
      statusMessage = message;
    });
    print(message);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32 WiFi Config'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection Steps:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                      '1. Connect to WiFi network "ESP32_Config" (password: 12345678)'),
                  Text('2. Enter your home WiFi details below'),
                  Text('3. Tap Connect and wait for confirmation'),
                ],
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: ssidController,
              decoration: InputDecoration(
                labelText: 'WiFi SSID',
                border: OutlineInputBorder(),
                hintText: 'Enter your home WiFi name',
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'WiFi Password',
                border: OutlineInputBorder(),
                hintText: 'Enter your home WiFi password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Text(
              'Status: $statusMessage',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () => sendConfig(
                        ssidController.text,
                        passwordController.text,
                      ),
              child: isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Connecting...'),
                      ],
                    )
                  : Text('Connect'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
