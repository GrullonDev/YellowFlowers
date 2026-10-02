package com.grullondev.amarillas

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Widget "Flor del día": muestra la frase del día y el progreso del jardín.
 * Los datos los escribe HomeWidgetService (Flutter); las frases vienen
 * precalculadas por fecha, así que cambian a medianoche sin abrir la app.
 */
class FlowerWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val quote = widgetData.getString("quote_$today", null)
            ?: widgetData.getString("quote_fallback", null)
            ?: "Cada día es una nueva oportunidad para florecer."
        val author = widgetData.getString("author_$today", "") ?: ""
        val flowers = widgetData.getString("flowers", "0") ?: "0"
        val streak = widgetData.getString("streak", "0") ?: "0"
        val bloomedToday = widgetData.getString("bloomed_on", "") == today

        val status = if (bloomedToday) {
            "🌼 $flowers flores · 🔥 $streak días"
        } else {
            "🌱 Tu flor de hoy te espera · $flowers flores"
        }

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.flower_widget).apply {
                setTextViewText(R.id.widget_quote, "“$quote”")
                setTextViewText(R.id.widget_author, "— $author")
                setViewVisibility(
                    R.id.widget_author,
                    if (author.isBlank()) View.GONE else View.VISIBLE,
                )
                setTextViewText(R.id.widget_status, status)

                val open = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("amarillas://garden"),
                )
                setOnClickPendingIntent(R.id.widget_root, open)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
