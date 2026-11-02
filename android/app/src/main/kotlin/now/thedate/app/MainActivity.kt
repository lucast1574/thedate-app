package now.thedate.app

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Bundle
import android.os.Build
import android.view.View
import android.view.ViewGroup
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "celebration_updates",
                "Novedades de tu celebración",
                NotificationManager.IMPORTANCE_DEFAULT,
            )
            channel.description = "Confirmaciones y reservas de regalos"
            getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        }
    }

    override fun onPostResume() {
        super.onPostResume()
        removeNativeFocusHighlights(window.decorView)
    }

    private fun removeNativeFocusHighlights(view: View) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            view.defaultFocusHighlightEnabled = false
        }
        if (view is ViewGroup) {
            for (index in 0 until view.childCount) {
                removeNativeFocusHighlights(view.getChildAt(index))
            }
        }
    }
}
