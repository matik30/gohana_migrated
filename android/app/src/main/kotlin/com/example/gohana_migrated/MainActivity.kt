package com.example.gohana_migrated

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "gohana/intent"
    private val CONTENT_CHANNEL = "gohana/content_uri"
    private var pendingImportUri: String? = null
    private var flutterReady = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        if (intent == null) return
        val action = intent.action
        val data = intent.data
        if (Intent.ACTION_VIEW == action && data != null) {
            if (flutterReady && flutterEngine != null) {
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                    .invokeMethod("importGohanaFile", data.toString())
            } else {
                pendingImportUri = data.toString()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, _ ->
            if (call.method == "flutterReady") {
                flutterReady = true
                pendingImportUri?.let {
                    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                        .invokeMethod("importGohanaFile", it)
                    pendingImportUri = null
                }
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CONTENT_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getFileFromContentUri") {
                val uriString = call.argument<String>("uri")
                if (uriString != null) {
                    val uri = android.net.Uri.parse(uriString)
                    try {
                        val inputStream: InputStream? = contentResolver.openInputStream(uri)
                        if (inputStream != null) {
                            val tempFile = File.createTempFile("gohana_import", ".gohana", cacheDir)
                            val outputStream = FileOutputStream(tempFile)
                            inputStream.copyTo(outputStream)
                            inputStream.close()
                            outputStream.close()
                            result.success(tempFile.absolutePath)
                        } else {
                            result.error("NO_INPUT_STREAM", "Cannot open input stream for URI", null)
                        }
                    } catch (e: Exception) {
                        result.error("CONTENT_URI_ERROR", e.message, null)
                    }
                } else {
                    result.error("NO_URI", "No URI provided", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
