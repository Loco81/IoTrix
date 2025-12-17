import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:flutter_highlight/themes/atom-one-light.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import '/Utils/classes.dart';




class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  TextEditingController nodemcuLink = TextEditingController(text: 'http://arduino.esp8266.com/stable/package_esp8266com_index.json');
  final controller = CodeController(
    text: '''
#include <ESP8266WiFi.h>
#include <PubSubClient.h>
#include <WiFiUdp.h>
#include <Ticker.h>

// -----------------------------
// WiFi Config
// -----------------------------

const char* ssid = "WiFi-Name";
const char* password = "WiFi-Password";

// -----------------------------
// MQTT Broker Config
// -----------------------------

const char* mqtt_server = "Broker-URL";
const int mqtt_port = 1883;
const char* mqtt_user = "Broker-Username";
const char* mqtt_pass = "Broker-Password";
const char* mqtt_topic = "home/room";

WiFiClient espClient;
PubSubClient client(espClient);

// -----------------------------
// UDP Server
// -----------------------------

WiFiUDP udp;
unsigned int udpPort = 8181;

// -----------------------------
// Pins
// -----------------------------

struct RelayPin {
  String name;
  int pin;
  bool state;
};

RelayPin relays[] = {
  {"d1", D1, true},   // For active-low relay (sets inactive on boot)
  {"d2", D2, true},
  {"d5", D5, true},
  {"d6", D6, true},
  {"d7", D7, false}   // For active-high relay (sets inactive on boot)
};

int relayCount = sizeof(relays) / sizeof(relays[0]);

// -----------------------------
// Ticker for non-blocking UDP
// -----------------------------

Ticker udpTicker;

// -----------------------------
// Execute command
// -----------------------------

void executeCommand(String cmd, IPAddress remoteIP = IPAddress(), unsigned int remotePort = 0) {
  cmd.trim();
  if (cmd.length() == 0) return;

  Serial.println("Received Command: " + cmd);

  // ---- Handle localip ----
  if (cmd.startsWith("localip")) {
    String ipStr = WiFi.localIP().toString();
    Serial.println("Sending local IP: " + ipStr);

    // MQTT
    if(client.connected()) {
      client.publish(mqtt_topic, ipStr.c_str());
    }

    // Check if remote IP and port specified
    int slash = cmd.indexOf('/');
    if(slash >= 0) {
      String ipPort = cmd.substring(slash + 1);
      int colon = ipPort.indexOf(':');
      if(colon > 0) {
        String ipPart = ipPort.substring(0, colon);
        String portPart = ipPort.substring(colon + 1);
        IPAddress targetIP;
        targetIP.fromString(ipPart);
        unsigned int targetPort = portPart.toInt();

        udp.beginPacket(targetIP, targetPort);
        udp.print(ipStr); // Send local IP
        udp.endPacket();

        Serial.println("Sent local IP via UDP to " + ipPart + ":" + portPart);
      }
    }
    return;
  }

  // ---- toggle / press commands ----
  int p1 = cmd.indexOf('/');
  if (p1 < 0) return;

  String pinName = cmd.substring(0, p1);
  cmd = cmd.substring(p1 + 1);

  int p2 = cmd.indexOf('/');
  String action = (p2 >= 0) ? cmd.substring(0, p2) : cmd;
  String value  = (p2 >= 0) ? cmd.substring(p2 + 1) : "";

  int index = -1;
  for (int i = 0; i < relayCount; i++) {
    if (relays[i].name.equalsIgnoreCase(pinName)) {
      index = i;
      break;
    }
  }
  if (index == -1) {
    Serial.println("Unknown PIN!");
    return;
  }


  if (action == "toggle") {
    relays[index].state = !relays[index].state;
    digitalWrite(relays[index].pin, relays[index].state ? HIGH : LOW);
    Serial.println("Toggled " + pinName);
  }
  else if (action == "press") {
    int duration = value.toInt();
    Serial.println("Press " + pinName + " for " + String(duration));
    digitalWrite(relays[index].pin, relays[index].state ? LOW : HIGH);
    delay(duration);
    digitalWrite(relays[index].pin, relays[index].state ? HIGH : LOW);
    Serial.println("Released " + pinName);
  }
}

// -----------------------------
// MQTT callback
// -----------------------------

void callback(char* topic, byte* payload, unsigned int length) {
  String msg;
  for (unsigned int i = 0; i < length; i++) msg += (char)payload[i];
  executeCommand(msg);
}

// -----------------------------
// MQTT reconnect
// -----------------------------

void reconnect() {
  if (client.connected()) return;

  Serial.print("Attempting MQTT connection...");
  if (client.connect("ESP8266Client", mqtt_user, mqtt_pass)) {
    Serial.println("connected");
    client.subscribe(mqtt_topic);
  } else {
    Serial.print("Failed, rc=");
    Serial.print(client.state());
    Serial.println(" retrying later");
  }
}

// -----------------------------
// UDP check function for Ticker
// -----------------------------

void handleUDP() {
  int packetSize = udp.parsePacket();
  if (packetSize) {
    char buffer[256];
    int len = udp.read(buffer, 255);
    if (len > 0) buffer[len] = '\\0';
    String msg = String(buffer);
    executeCommand(msg, udp.remoteIP(), udp.remotePort());
  }
}

// -----------------------------
// SETUP
// -----------------------------

void setup() {
  Serial.begin(115200);

  // Setup pins
  for (int i = 0; i < relayCount; i++) {
    pinMode(relays[i].pin, OUTPUT);
    digitalWrite(relays[i].pin, relays[i].state ? HIGH : LOW);  // For relays to be inactive during first boot
  }

  // WiFi connect
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\\nWiFi Connected. IP:");
  Serial.println(WiFi.localIP());

  // MQTT
  client.setServer(mqtt_server, mqtt_port);
  client.setCallback(callback);

  // UDP
  udp.begin(udpPort);
  Serial.print("UDP Server started on port ");
  Serial.println(udpPort);

  // Ticker every 500ms to check UDP
  udpTicker.attach_ms(500, handleUDP);
}

// -----------------------------
// LOOP
// -----------------------------

void loop() {
  reconnect();
  client.loop(); // MQTT handling
  // UDP handled asynchronously by Ticker
}''',
    language: cpp,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50.sp,),
            SizedBox(
              width: 0.9.sw,
              child: Text(sentences.GUIDE_TEXT1, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 54.sp),),
            ),
            SizedBox(height: 50.sp,),
            Divider(),
            SizedBox(height: 50.sp,),
            SizedBox(
              width: 0.9.sw,
              child: Text(sentences.GUIDE_TEXT2, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 54.sp),),
            ),
            SizedBox(height: 50.sp,),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 0.8.sw,
                  child: TextField(
                    controller: nodemcuLink,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueAccent, fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: sentences.ITEM_URL_HINT,
                      label: Text(sentences.LINK),
                      labelStyle: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 52.sp),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
                SizedBox(width: 40.w,),
                GestureDetector(
                  onTap: () async {
                    HapticFeedback.mediumImpact();
                    await Clipboard.setData(ClipboardData(text: nodemcuLink.text));
                  },
                  child: Icon(Icons.copy, size: 80.sp, color: Theme.of(context).colorScheme.primary.withAlpha(230),),
                ),
              ]
            ),
            SizedBox(height: 80.sp,),
            SizedBox(
              width: 0.9.sw,
              child: Text(sentences.GUIDE_TEXT3, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 54.sp),),
            ),
            SizedBox(height: 50.sp,),
            SizedBox(
              height: 1800.sp,
              child: CodeTheme(
                data: CodeThemeData(styles: Theme.of(context).cardColor.r>0.5 ? atomOneLightTheme : atomOneDarkTheme),
                child: SingleChildScrollView(
                  child: CodeField(
                    controller: controller,
                    readOnly: true,
                    textStyle: TextStyle(fontFamily: 'AveriaLibre', fontSize: 46.sp),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50.sp,),
            SizedBox(
              width: 0.9.sw,
              child: Text(sentences.GUIDE_TEXT4, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 54.sp),),
            ),
            SizedBox(height: 50.sp,),
            Container(
              width: 0.9.sw,
              height: 860.w,
              decoration: ShapeDecoration(
                image: DecorationImage(image: AssetImage('assets/Diagram.jpg'), fit: BoxFit.fitWidth,),
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(220.sp),
                ),
                shadows: [
                  BoxShadow(
                    color: const Color.fromARGB(184, 131, 131, 131),
                    blurRadius: 50.sp
                  )
                ]
              ),
            ),
            SizedBox(height: 50.sp,),
            SizedBox(
              width: 0.9.sw,
              child: Text(sentences.GUIDE_TEXT5, textDirection: sentences.direction, style: TextStyle(fontFamily: sentences.FONTFAMILY_DESCRIPTION, fontSize: 54.sp),),
            ),
            SizedBox(height: 50.sp,),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(sentences.GUIDE, style: TextStyle(fontFamily: sentences.FONTFAMILY_SUBJECT, fontWeight: FontWeight.bold, fontSize: 78.sp),),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(80.sp)),
        ),
        shadowColor: Theme.of(context).colorScheme.primary.withAlpha(80),
        elevation: 36.sp,
        toolbarHeight: 200.sp,
        leading: IconButton(
          padding: EdgeInsets.all(40.sp),
          icon: Icon(Icons.close_rounded, size: 100.sp,),
          onPressed: ()=> Navigator.pop(context),
        ),
      )
    );
  }
}