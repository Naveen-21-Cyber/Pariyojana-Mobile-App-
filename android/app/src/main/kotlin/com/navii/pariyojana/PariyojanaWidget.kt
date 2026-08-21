package com.navii.pariyojana

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews

/**
 * PariyojanaWidget — 2×2 Android home screen widget.
 * Displays idea count + active project count sourced from SharedPreferences
 * written by the Flutter home_widget package.
 */
class PariyojanaWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val TAG = "PariyojanaWidget"

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            try {
                // Read values safely across candidate SharedPreferences stores
                val ideaCount = readIntFromPrefs(context, "pariyojana_idea_count")
                val projectCount = readIntFromPrefs(context, "pariyojana_project_count")

                val views = RemoteViews(context.packageName, R.layout.pariyojana_widget)
                views.setTextViewText(R.id.widget_idea_count, ideaCount.toString())
                views.setTextViewText(R.id.widget_project_count, projectCount.toString())

                // Explicit intent targeting MainActivity to satisfy Android 12+ trampoline restrictions
                val targetIntent = Intent(context, MainActivity::class.java).apply {
                    action = Intent.ACTION_MAIN
                    addCategory(Intent.CATEGORY_LAUNCHER)
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    targetIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e(TAG, "Error updating PariyojanaWidget: ${e.message}", e)
                try {
                    // Safe fallback inflate
                    val fallbackViews = RemoteViews(context.packageName, R.layout.pariyojana_widget)
                    appWidgetManager.updateAppWidget(appWidgetId, fallbackViews)
                } catch (fallbackError: Exception) {
                    Log.e(TAG, "Fallback inflate also failed: ${fallbackError.message}")
                }
            }
        }

        private fun readIntFromPrefs(context: Context, key: String): Int {
            val prefNames = arrayOf("HomeWidgetPreferences", "com.navii.pariyojana", "FlutterSharedPreferences")
            val altKey = "flutter.$key"

            for (prefName in prefNames) {
                val prefs: SharedPreferences = context.getSharedPreferences(prefName, Context.MODE_PRIVATE)
                
                // Try primary key as Int
                if (prefs.contains(key)) {
                    try {
                        return prefs.getInt(key, 0)
                    } catch (_: Exception) {
                        try {
                            return prefs.getString(key, "0")?.toIntOrNull() ?: 0
                        } catch (_: Exception) {}
                    }
                }
                
                // Try flutter-prefixed key as Int / String
                if (prefs.contains(altKey)) {
                    try {
                        return prefs.getInt(altKey, 0)
                    } catch (_: Exception) {
                        try {
                            return prefs.getString(altKey, "0")?.toIntOrNull() ?: 0
                        } catch (_: Exception) {}
                    }
                }
            }
            return 0
        }
    }
}
