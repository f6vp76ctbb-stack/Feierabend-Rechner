package com.thinkube.feierabendrechner

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Home-Screen-Widget (siehe FeierabendWidget.kt / widget_backend.dart).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FeierabendWidget.CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "update" -> {
                        val args = call.arguments as? Map<*, *>
                        if (args != null) FeierabendWidget.save(applicationContext, args)
                        result.success(args != null)
                    }
                    "requestPin" -> result.success(FeierabendWidget.requestPin(this))
                    else -> result.notImplemented()
                }
            }
    }
}
