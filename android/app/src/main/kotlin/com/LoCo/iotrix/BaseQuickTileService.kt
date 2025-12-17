package com.LoCo.iotrix

import android.content.Context
import android.content.SharedPreferences
import android.graphics.drawable.Icon
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log
import android.os.Handler
import android.os.Looper
import android.widget.Toast
import org.eclipse.paho.client.mqttv3.*

abstract class BaseQuickTileService : TileService() {
    private val PREFS = "quick_tile_prefs"

    private fun prefs(): SharedPreferences =
        applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    // Each child service should return tile number (1 to 6)
    abstract fun tileNumber(): Int

    override fun onStartListening() {
        super.onStartListening()
        try {
            val n = tileNumber()
            val p = prefs()
            val title = p.getString("tile_${n}_title", "IoTrix " + n.toString()) ?: "IoTrix " + n.toString()
            val iconName = p.getString("tile_${n}_icon", "ic_tile") ?: "ic_tile"
            val resId = resources.getIdentifier(iconName, "drawable", packageName)
            val qs = qsTile
            qs?.let {
                it.label = title
                if (resId != 0) {
                    it.icon = Icon.createWithResource(this, resId)
                } else {
                    it.icon = Icon.createWithResource(this, R.drawable.ic_shortcut)
                }
                it.state = Tile.STATE_INACTIVE
                it.updateTile()
            }
        } catch (ex: Exception) {
            Log.e("BaseQuickTileService", "onStartListening error: ${ex.message}")
        }
    }

    override fun onTileAdded() {
        super.onTileAdded()
        // optional: called when user adds the tile
    }

    override fun onTileRemoved() {
        super.onTileRemoved()
        // optional: called when user removes the tile
    }

    override fun onClick() {
        super.onClick()
        val n = tileNumber()
        val p = prefs()
        // Read args from sharedPrefrences
        val brokerUrl = p.getString("tile_${n}_brokerUrl", null)
        val userName = p.getString("tile_${n}_userName", null)
        val password = p.getString("tile_${n}_password", null)
        val topic = p.getString("tile_${n}_topic", null)
        val message = p.getString("tile_${n}_message", null)

        val localIp = p.getString("tile_${n}_localIp", null)
        val localPort = p.getString("tile_${n}_localPort", null)
        val mode = p.getString("tile_${n}_mode", "online") ?: "online"

        performAction(mode, brokerUrl, userName, password, topic, message, localIp, localPort)

        // Optionally change tile state briefly
        try {
            qsTile?.let {
                it.state = Tile.STATE_ACTIVE
                it.updateTile()
            }
        } catch (e: Exception) { /* ignore */ }
    }

    private fun performAction(
        mode: String?,
        brokerUrl: String?,
        userName: String?,
        password: String?,
        topic: String?,
        message: String?,
        localIp: String?,
        localPort: String?
    ) {
        try {
            if (mode == "local") {

                val ip = localIp ?: return
                val port = localPort?.toIntOrNull() ?: return

                val socket = java.net.DatagramSocket()
                val addr = java.net.InetAddress.getByName(ip)
                val data = (message ?: "").toByteArray(Charsets.UTF_8)
                val packet = java.net.DatagramPacket(data, data.size, addr, port)

                // Run UDP on a thread
                Thread {
                    try {
                        socket.send(packet)
                        socket.close()
                        Log.d("BaseQuickTileService", "UDP sent to $ip:$port -> ${message ?: ""}")

                        // Haptic and Toast should be on UI thread
                        Handler(Looper.getMainLooper()).post {
                            HapticUtils.doHaptic(this)
                            Toast.makeText(
                                this,
                                "Done (${mode?.replaceFirstChar { it.uppercase() }})",
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                    } catch (e: Exception) {
                        Log.e("BaseQuickTileService", "UDP error: ${e.message}", e)
                    }
                }.start()

            } else {
                // Run MQTT on a thread
                Thread {
                    try {
                        val client = MqttClient(brokerUrl, "IoTrix", null)

                        val options = MqttConnectOptions().apply {
                            isCleanSession = true
                            this.userName = userName
                            this.password = password?.toCharArray()
                        }

                        client.connect(options)

                        val mqttMessage = MqttMessage(message?.toByteArray())
                        mqttMessage.qos = 1
                        client.publish(topic, mqttMessage)
                        client.disconnect()

                        Log.d("BaseQuickTileService", "MQTT publish to $topic -> ${message ?: ""}")

                        Handler(Looper.getMainLooper()).post {
                            HapticUtils.doHaptic(this)
                            Toast.makeText(
                                this,
                                "Done (${mode?.replaceFirstChar { it.uppercase() }})",
                                Toast.LENGTH_SHORT
                            ).show()
                        }
                    } catch (e: Exception) {
                        Log.e("BaseQuickTileService", "MQTT error: ${e.message}", e)
                    }
                }.start()
            }
        }
        catch (e: Exception) {
            Log.e("BaseQuickTileService", "performAction error: ${e.message}", e)
        }
    }


    companion object {
        // Helper for Triggering onStartListening from outside
        fun requestTileListening(context: Context, serviceClass: Class<out TileService>) {
            try {
                val comp = android.content.ComponentName(context, serviceClass)
                TileService.requestListeningState(context, comp)
            } catch (e: Exception) { /* ignore */ }
        }
    }
}
