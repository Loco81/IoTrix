package com.LoCo.iotrix

import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SHORTCUT_CHANNEL = "com.LoCo.iotrix/shortcuts"
    private val DEEPLINK_CHANNEL = "com.LoCo.iotrix/deeplink"

    private var pendingLink: String? = null   // ✅ To wait until flutter runs

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ✅ QuickTiles channel
        QuickTileMethodChannel(this, flutterEngine)

        // ✅ Shortcuts channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SHORTCUT_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "createShortcut" -> {
                        val id = call.argument<String>("id") ?: ""
                        val name = call.argument<String>("name") ?: "Unnamed"
                        val icon = call.argument<String>("icon") ?: "ic_shortcut"

                        val brokerUrl = call.argument<String>("brokerUrl") ?: ""
                        val userName = call.argument<String>("userName") ?: ""
                        val password = call.argument<String>("password") ?: ""
                        val topic = call.argument<String>("topic") ?: ""
                        val message = call.argument<String>("message") ?: ""

                        val localIp = call.argument<String>("localIp") ?: ""
                        val localPort = call.argument<String>("localPort") ?: ""
                        val mode = call.argument<String>("mode") ?: "online"

                        createShortcut(
                            id, name, icon,
                            brokerUrl, userName, password, topic, message,
                            localIp, localPort, mode
                        )
                        result.success("Shortcut created")
                    }

                    "removeShortcut" -> {
                        val id = call.argument<String>("id") ?: ""
                        removeShortcut(id)
                        result.success("Shortcut removed")
                    }

                    else -> result.notImplemented()
                }
            }

        // ✅ If the link loaded before flutter, send it to flutter
        pendingLink?.let { link ->
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEEPLINK_CHANNEL)
                .invokeMethod("onDeepLink", link)
            pendingLink = null
        }
    }

    private fun createShortcut(
        id: String,
        name: String,
        icon: String,
        brokerUrl: String,
        userName: String,
        password: String,
        topic: String,
        message: String,
        localIp: String,
        localPort: String,
        mode: String
    ) {
        val shortcutManager = getSystemService(ShortcutManager::class.java) ?: return

        val intent = Intent(this, ShortcutActionActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            putExtra("brokerUrl", brokerUrl)
            putExtra("userName", userName)
            putExtra("password", password)
            putExtra("topic", topic)
            putExtra("message", message)
            putExtra("localIp", localIp)
            putExtra("localPort", localPort)
            putExtra("mode", mode)
        }

        val iconRes = resources.getIdentifier(icon, "drawable", packageName)
        val shortcutIcon = if (iconRes != 0)
            Icon.createWithResource(this, iconRes)
        else
            Icon.createWithResource(this, R.drawable.ic_shortcut)

        val shortcut = ShortcutInfo.Builder(this, id)
            .setShortLabel(name)
            .setLongLabel("Run $name")
            .setIcon(shortcutIcon)
            .setIntent(intent)
            .build()

        shortcutManager.addDynamicShortcuts(listOf(shortcut))
    }

    private fun removeShortcut(id: String) {
        val shortcutManager = getSystemService(ShortcutManager::class.java) ?: return
        shortcutManager.removeDynamicShortcuts(listOf(id))
    }

    // DeepLink handling (unchanged)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // When the app restarted, payload sends from here
        val extraPayload = intent.getStringExtra("deeplink_payload")
        if (extraPayload != null) {
            sendToFlutter(extraPayload)
            return
        }

        handleDeepLink(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }

    private fun handleDeepLink(intent: Intent?) {
        val dataUri = intent?.data ?: return
        val uriStr = dataUri.toString()

        var payloadToSend = ""

        when {
            uriStr.startsWith("iotrix://") -> {
                // Read link content
                payloadToSend = uriStr
            }

            uriStr.endsWith(".iotrix") || uriStr.contains(".iotrix") -> {
                // Read file content
                val content = try {
                    val inputStream = contentResolver.openInputStream(dataUri)
                    if (inputStream != null) {
                        inputStream.bufferedReader().use { it.readText() }
                    } else {
                        "Error: Cannot open stream for $uriStr"
                    }
                } catch (e: Exception) {
                    "Error reading file: ${e.message}"
                }

                payloadToSend = content
            }

            else -> {
                payloadToSend = "Unhandled intent: $uriStr"
            }
        }

        // payloadToSend variable contains the content of link or file
        restartAppWithDeepLinkPayload(payloadToSend)
    }

    private fun restartAppWithDeepLinkPayload(payload: String) {
        // Close all activities
        finishAffinity()

        // Create a new Intent for each opening
        val restartIntent = Intent(this, MainActivity::class.java).apply {
            action = Intent.ACTION_VIEW
            putExtra("deeplink_payload", payload)

            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TASK or
                    Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED)
        }

        startActivity(restartIntent)
    }

    private fun sendToFlutter(data: String) {
        val engine = flutterEngine
        if (engine == null) {
            // If flutter is not ready, hold on
            pendingLink = data
        } else {
            MethodChannel(engine.dartExecutor.binaryMessenger, DEEPLINK_CHANNEL)
                .invokeMethod("onDeepLink", data)
        }
    }
}
