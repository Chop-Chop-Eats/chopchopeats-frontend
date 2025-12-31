package com.example.chop_user

import android.os.Bundle
import com.stripe.android.PaymentConfiguration
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "stripe_config"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 设置 MethodChannel 以接收 Flutter 端的 Stripe key
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initializeStripe") {
                val publishableKey = call.argument<String>("publishableKey")
                if (publishableKey != null && publishableKey.isNotEmpty()) {
                    try {
                        PaymentConfiguration.init(applicationContext, publishableKey)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("STRIPE_INIT_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_KEY", "Publishable key is null or empty", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
