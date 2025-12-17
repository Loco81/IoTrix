package com.LoCo.iotrix

import android.content.Context
import android.content.SharedPreferences
import android.service.quicksettings.TileService
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class QuickTileMethodChannel(private val context: Context, engine: FlutterEngine) : MethodChannel.MethodCallHandler {
    private val channel = MethodChannel(engine.dartExecutor.binaryMessenger, "com.LoCo.iotrix/quicktile")
    private val PREFS = "quick_tile_prefs"

    init {
        channel.setMethodCallHandler(this)
    }

    private fun prefs(): SharedPreferences =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "addOrUpdateTile" -> {
                    val args = call.arguments as? Map<*, *>
                    if (args == null) {
                        result.error("bad_args", "arguments null or wrong type", null)
                        return
                    }
                    val tileNumber = (args["tileNumber"] as Number).toInt()
                    val title = args["title"] as? String ?: "IoTrix "+tileNumber.toString()
                    val icon = args["icon"] as? String ?: "ic_tile"
                    val brokerUrl = args["brokerUrl"] as? String
                    val userName = args["userName"] as? String
                    val password = args["password"] as? String
                    val topic = args["topic"] as? String
                    val message = args["message"] as? String

                    val localIp = args["localIp"] as? String
                    val localPort = args["localPort"] as? String
                    val mode = args["mode"] as? String ?: "online"

                    val p = prefs().edit()
                    p.putString("tile_${tileNumber}_title", title)
                    p.putString("tile_${tileNumber}_icon", icon)
                    p.putString("tile_${tileNumber}_brokerUrl", brokerUrl)
                    p.putString("tile_${tileNumber}_userName", userName)
                    p.putString("tile_${tileNumber}_password", password)
                    p.putString("tile_${tileNumber}_topic", topic)
                    p.putString("tile_${tileNumber}_message", message)

                    p.putString("tile_${tileNumber}_localIp", localIp)
                    p.putString("tile_${tileNumber}_localPort", localPort)
                    p.putString("tile_${tileNumber}_mode", mode)

                    p.apply()

                    // trigger tile update by requesting listening state
                    val svcClass = serviceClassForTile(tileNumber)
                    svcClass?.let { BaseQuickTileService.requestTileListening(context, it) }

                    result.success(null)
                }
                "removeTile" -> {
                    val args = call.arguments as? Map<*, *>
                    val tileNumber = (args?.get("tileNumber") as? Number)?.toInt() ?: run {
                        result.error("bad_args", "tileNumber missing", null); return
                    }
                    // reset to default values
                    val p = prefs().edit()
                    p.putString("tile_${tileNumber}_title", "IoTrix "+tileNumber.toString())
                    p.putString("tile_${tileNumber}_icon", "ic_tile")
                    p.remove("tile_${tileNumber}_brokerUrl")
                    p.remove("tile_${tileNumber}_userName")
                    p.remove("tile_${tileNumber}_password")
                    p.remove("tile_${tileNumber}_topic")
                    p.remove("tile_${tileNumber}_message")

                    p.remove("tile_${tileNumber}_localIp")
                    p.remove("tile_${tileNumber}_localPort")
                    p.remove("tile_${tileNumber}_mode")

                    p.apply()

                    val svcClass = serviceClassForTile(tileNumber)
                    svcClass?.let { BaseQuickTileService.requestTileListening(context, it) }

                    result.success(null)
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            Log.e("QuickTileMethodChannel", "method call error", e)
            result.error("exception", e.message, null)
        }
    }

    private fun serviceClassForTile(number: Int): Class<out TileService>? {
        return when (number) {
            1 -> QuickTileService1::class.java
            2 -> QuickTileService2::class.java
            3 -> QuickTileService3::class.java
            4 -> QuickTileService4::class.java
            5 -> QuickTileService5::class.java
            6 -> QuickTileService6::class.java
            else -> null
        }
    }
}
