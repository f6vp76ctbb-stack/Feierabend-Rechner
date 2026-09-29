package com.thinkube.feierabendrechner

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews

/**
 * Home-Screen-Widget: Feierabend-Uhrzeit, mit Pro ein live tickender Countdown.
 *
 * Die App liefert nur Zeitpunkte (siehe `lib/services/widget_backend.dart`); den
 * Countdown zählt der Chronometer selbst herunter, ohne dass die App läuft.
 */
class FeierabendWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        FeierabendWidget.render(context, manager, ids)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            FeierabendWidget.ACTION_REFRESH,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> FeierabendWidget.refreshAll(context)
        }
    }
}

object FeierabendWidget {
    const val CHANNEL = "com.thinkube.feierabendrechner/widget"
    const val ACTION_REFRESH = "com.thinkube.feierabendrechner.WIDGET_REFRESH"

    private const val PREFS = "feierabend_widget"
    private const val KEY_HAS_DATA = "has_data"
    private const val KEY_START = "start_millis"
    private const val KEY_END = "end_millis"
    private const val KEY_LABEL = "end_label"
    private const val KEY_PRO_UNTIL = "pro_until_millis"

    /** Nach so langer Zeit nach Feierabend gilt der Stand als „von gestern". */
    private const val STALE_AFTER_MS = 6 * 60 * 60 * 1000L

    /** Stand aus der App speichern und alle Widgets neu zeichnen. */
    fun save(context: Context, args: Map<*, *>) {
        fun long(key: String) = (args[key] as? Number)?.toLong() ?: 0L
        prefs(context).edit()
            .putBoolean(KEY_HAS_DATA, true)
            .putLong(KEY_START, long("startMillis"))
            .putLong(KEY_END, long("endMillis"))
            .putString(KEY_LABEL, args["endLabel"] as? String ?: "")
            .putLong(KEY_PRO_UNTIL, long("proUntilMillis"))
            .apply()
        refreshAll(context)
    }

    fun refreshAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(
            ComponentName(context, FeierabendWidgetProvider::class.java)
        )
        if (ids.isNotEmpty()) render(context, manager, ids)
    }

    /** Launcher bitten, das Widget abzulegen (Android 8+, falls unterstützt). */
    fun requestPin(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val manager = context.getSystemService(AppWidgetManager::class.java) ?: return false
        if (!manager.isRequestPinAppWidgetSupported) return false
        return manager.requestPinAppWidget(
            ComponentName(context, FeierabendWidgetProvider::class.java), null, null
        )
    }

    fun render(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val prefs = prefs(context)
        val now = System.currentTimeMillis()
        val start = prefs.getLong(KEY_START, 0L)
        val end = prefs.getLong(KEY_END, 0L)
        val proUntil = prefs.getLong(KEY_PRO_UNTIL, 0L)
        val isPro = proUntil == -1L || proUntil > now
        val fresh = prefs.getBoolean(KEY_HAS_DATA, false) && now - end < STALE_AFTER_MS

        val views = RemoteViews(context.packageName, R.layout.feierabend_widget)
        views.setOnClickPendingIntent(R.id.widget_root, launchIntent(context))

        if (!fresh) {
            views.setTextViewText(R.id.widget_time, "--:--")
            showStatus(views, context.getString(R.string.widget_open))
            views.setViewVisibility(R.id.widget_progress, View.GONE)
            manager.updateAppWidget(ids, views)
            scheduleRefresh(context, 0L)
            return
        }

        views.setTextViewText(R.id.widget_time, prefs.getString(KEY_LABEL, ""))
        views.setViewVisibility(R.id.widget_progress, View.VISIBLE)
        val total = (end - start).coerceAtLeast(1L)
        val done = ((now - start).coerceIn(0L, total) * 1000L / total).toInt()
        views.setProgressBar(R.id.widget_progress, 1000, done, false)

        when {
            now >= end -> showStatus(views, context.getString(R.string.widget_reached))
            !isPro -> showStatus(views, context.getString(R.string.widget_locked))
            else -> {
                views.setViewVisibility(R.id.widget_status, View.GONE)
                views.setViewVisibility(R.id.widget_countdown, View.VISIBLE)
                views.setChronometer(
                    R.id.widget_countdown,
                    SystemClock.elapsedRealtime() + (end - now),
                    context.getString(R.string.widget_left_format),
                    true,
                )
                views.setChronometerCountDown(R.id.widget_countdown, true)
            }
        }
        manager.updateAppWidget(ids, views)
        // Zum Feierabend (bzw. Ende des Pro-Tests) auf „erreicht" umschalten.
        val next = listOf(end, if (proUntil > now) proUntil else 0L)
            .filter { it > now }
            .minOrNull() ?: 0L
        scheduleRefresh(context, next)
    }

    private fun showStatus(views: RemoteViews, text: String) {
        views.setChronometer(R.id.widget_countdown, SystemClock.elapsedRealtime(), null, false)
        views.setViewVisibility(R.id.widget_countdown, View.GONE)
        views.setViewVisibility(R.id.widget_status, View.VISIBLE)
        views.setTextViewText(R.id.widget_status, text)
    }

    /**
     * Nicht-exakter Alarm mit kleinem Zeitfenster (`setWindow`): braucht keine
     * Sonder-Berechtigung und kommt verlässlich kurz nach dem Zeitpunkt.
     * `at == 0` hebt einen geplanten Alarm auf.
     */
    private fun scheduleRefresh(context: Context, at: Long) {
        val alarms = context.getSystemService(AlarmManager::class.java) ?: return
        val intent = Intent(context, FeierabendWidgetProvider::class.java)
            .setAction(ACTION_REFRESH)
        val pending = PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        alarms.cancel(pending)
        if (at > 0L) alarms.setWindow(AlarmManager.RTC, at, 60_000L, pending)
    }

    private fun launchIntent(context: Context): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
            .setAction(Intent.ACTION_MAIN)
            .addCategory(Intent.CATEGORY_LAUNCHER)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        return PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}
