package com.example.money_bird

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget showing the Money Bird financial-health score and today's
 * spending. Data is pushed from Flutter via the `home_widget` plugin and read
 * here from the shared [SharedPreferences].
 */
class MoneyBirdWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.money_bird_widget)

            val score = readInt(widgetData, "mb_score", 0)
            val band = widgetData.getString("mb_band", "") ?: ""
            val spentToday = widgetData.getString("mb_spent_today", "฿0") ?: "฿0"
            val title = widgetData.getString("mb_title", "Financial health") ?: "Financial health"
            val spentLabel = widgetData.getString("mb_spent_label", "Spent today") ?: "Spent today"
            val tapHint = widgetData.getString("mb_tap_hint", "Tap to add") ?: "Tap to add"

            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_score, score.toString())
            views.setTextViewText(R.id.widget_band, band)
            views.setTextViewText(R.id.widget_spent_label, spentLabel)
            views.setTextViewText(R.id.widget_spent_value, spentToday)
            views.setTextViewText(R.id.widget_tap_hint, tapHint)
            views.setProgressBar(R.id.widget_progress, 100, score.coerceIn(0, 100), false)
            views.setTextColor(R.id.widget_band, colorForScore(score))

            // Tapping the widget opens the app.
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun readInt(prefs: SharedPreferences, key: String, default: Int): Int {
        return try {
            prefs.getInt(key, default)
        } catch (_: ClassCastException) {
            try {
                prefs.getLong(key, default.toLong()).toInt()
            } catch (_: ClassCastException) {
                prefs.getString(key, default.toString())?.toIntOrNull() ?: default
            }
        }
    }

    private fun colorForScore(score: Int): Int = when {
        score >= 80 -> Color.parseColor("#22C55E")
        score >= 60 -> Color.parseColor("#2F6BFF")
        score >= 40 -> Color.parseColor("#FBBF24")
        else -> Color.parseColor("#FB7185")
    }
}
