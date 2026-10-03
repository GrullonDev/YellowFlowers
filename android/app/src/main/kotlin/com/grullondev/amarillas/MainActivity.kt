package com.grullondev.amarillas

import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // 1. Splash Screen API core
        val splashScreen = installSplashScreen()
        
        super.onCreate(savedInstanceState)
        
        // 2. Activate native Edge-to-Edge mode (Required for Android 15+)
        // This allows Flutter content to flow under system bars seamlessly
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
