package com.econome.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class EconomeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, prefs)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        prefs: android.content.SharedPreferences,
    ) {
        val views = RemoteViews(context.packageName, R.layout.econome_widget_layout)

        val balance = prefs.getString("balance", "—") ?: "—"
        val balanceColor = prefs.getString("balanceColor", "#A1A1AA") ?: "#A1A1AA"
        val budgetLabel = prefs.getString("budgetLabel", "") ?: ""
        val tx1 = prefs.getString("tx1", "") ?: ""
        val tx2 = prefs.getString("tx2", "") ?: ""
        val tx3 = prefs.getString("tx3", "") ?: ""

        try {
            val colorInt = android.graphics.Color.parseColor(balanceColor)
            views.setTextColor(R.id.balance_text, colorInt)
        } catch (_: Exception) {
            views.setTextColor(R.id.balance_text, android.graphics.Color.parseColor("#A1A1AA"))
        }

        views.setTextViewText(R.id.balance_text, balance)

        if (budgetLabel.isNotEmpty()) {
            views.setTextViewText(R.id.budget_text, budgetLabel)
            views.setViewVisibility(R.id.budget_text, android.view.View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.budget_text, android.view.View.GONE)
        }

        views.setTextViewText(R.id.tx1, tx1)
        views.setViewVisibility(R.id.tx1, if (tx1.isNotEmpty()) android.view.View.VISIBLE else android.view.View.GONE)
        views.setTextViewText(R.id.tx2, tx2)
        views.setViewVisibility(R.id.tx2, if (tx2.isNotEmpty()) android.view.View.VISIBLE else android.view.View.GONE)
        views.setTextViewText(R.id.tx3, tx3)
        views.setViewVisibility(R.id.tx3, if (tx3.isNotEmpty()) android.view.View.VISIBLE else android.view.View.GONE)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
