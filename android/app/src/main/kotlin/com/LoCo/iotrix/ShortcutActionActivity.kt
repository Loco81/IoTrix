package com.LoCo.iotrix

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import kotlinx.coroutines.*
import java.net.DatagramPacket
import java.net.DatagramSocket
import java.net.InetAddress
import org.eclipse.paho.client.mqttv3.*

class ShortcutActionActivity : Activity() {

    private val activityScope = CoroutineScope(Dispatchers.Main)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val brokerUrl = intent.getStringExtra("brokerUrl") ?: ""
        val userName = intent.getStringExtra("userName") ?: ""
        val password = intent.getStringExtra("password") ?: ""
        val topic = intent.getStringExtra("topic") ?: ""
        val message = intent.getStringExtra("message") ?: ""

        val localIp = intent.getStringExtra("localIp") ?: ""
        val localPort = intent.getStringExtra("localPort") ?: ""
        val mode = intent.getStringExtra("mode") ?: "online"

        // Run in background
        activityScope.launch {
            performAction(mode, brokerUrl, userName, password, topic, message, localIp, localPort)
            finish()
        }
    }

    private suspend fun performAction(
        mode: String,
        brokerUrl: String,
        userName: String,
        password: String,
        topic: String,
        message: String,
        localIp: String,
        localPort: String
    ) = withContext(Dispatchers.IO) {
        try {
            if (mode == "local") {
                // -----------------------------
                // UDP SEND — BACKGROUND THREAD
                // -----------------------------
                val port = localPort.toIntOrNull() ?: return@withContext
                val socket = DatagramSocket()
                val addr = InetAddress.getByName(localIp)
                val data = message.toByteArray(Charsets.UTF_8)
                val packet = DatagramPacket(data, data.size, addr, port)

                socket.send(packet)
                socket.close()

                Log.d("ShortcutAction", "UDP sent to $localIp:$port -> $message")
            } else {
                // -----------------------------
                // MQTT SEND — BACKGROUND THREAD
                // -----------------------------
                val client = MqttClient(brokerUrl, "IoTrix", null)

                val options = MqttConnectOptions().apply {
                    isCleanSession = true
                    this.userName = userName
                    this.password = password?.toCharArray()
                }

                client.connect(options)

                val mqttMessage = MqttMessage(message.toByteArray()).apply {
                    qos = 1
                }

                client.publish(topic, mqttMessage)
                client.disconnect()

                Log.d("ShortcutAction", "MQTT publish -> $topic : $message")
            }

            // Do haptic on main thread
            withContext(Dispatchers.Main) {
                HapticUtils.doHaptic(this@ShortcutActionActivity)
                Toast.makeText(
                    this@ShortcutActionActivity,
                    "Done (${mode.replaceFirstChar { it.uppercase() }})",
                    Toast.LENGTH_SHORT
                ).show()
            }

        } catch (e: Exception) {
            Log.e("ShortcutAction", "performAction error: ${e.message}", e)

            withContext(Dispatchers.Main) {
                Toast.makeText(
                    this@ShortcutActionActivity,
                    "Error: ${e.message}",
                    Toast.LENGTH_SHORT
                ).show()
            }
        }
    }
}
