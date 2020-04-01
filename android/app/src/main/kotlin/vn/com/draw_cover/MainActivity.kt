package vn.com.draw_cover

import io.flutter.embedding.android.DrawableSplashScreen
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.SplashScreen
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.view.FlutterMain

class MainActivity: FlutterActivity() {
    override fun provideSplashScreen(): SplashScreen? {
        // Load the splash Drawable.
        val splash = activity!!.resources.getDrawable(R.drawable.splash)

        // Construct a DrawableSplashScreen with the loaded splash Drawable and
        // return it.
        return DrawableSplashScreen(splash)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        FlutterMain.startInitialization(this)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
