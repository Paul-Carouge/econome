package com.econome.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.widget.RemoteViews

class EconomeWidgetProvider : AppWidgetProvider() {

    companion object {
        const val PREF_NAME = "HomeWidgetPreferences"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
        val widgetName = prefs.getString("widgetName", "EconomeWidget") ?: "EconomeWidget"

        for (appWidgetId in appWidgetIds) {
            when (widgetName) {
                "CompactWidget" -> updateCompact(context, appWidgetManager, appWidgetId, prefs)
                "BudgetWidget" -> updateBudget(context, appWidgetManager, appWidgetId, prefs)
                "SavingsWidget" -> updateSavings(context, appWidgetManager, appWidgetId, prefs)
                else -> updateFull(context, appWidgetManager, appWidgetId, prefs) // EconomeWidget (full)
            }
        }
    }

    // ─── Compact Widget ─────────────────────────────────────────────
    private fun updateCompact(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        prefs: android.content.SharedPreferences,
    ) {
        val views = RemoteViews(context.packageName, R.layout.econome_compact_widget)

        val balance = prefs.getString("balance", "—") ?: "—"
        val balanceColor = parseColor(prefs.getString("balanceColor", "#A1A1AA") ?: "#A1A1AA")

        views.setTextViewText(R.id.compact_balance, balance)
        views.setTextColor(R.id.compact_balance, balanceColor)
        views.setTextViewText(R.id.compact_label, "Solde")

        manager.updateAppWidget(id, views)
    }

    // ─── Budget Widget ──────────────────────────────────────────────
    private fun updateBudget(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        prefs: android.content.SharedPreferences,
    ) {
        val views = RemoteViews(context.packageName, R.layout.econome_budget_widget)

        val budgetLabel = prefs.getString("budgetLabel", "—") ?: "—"
        val budgetSpent = prefs.getString("budgetSpent", "0") ?: "0"
        val budgetTotal = prefs.getString("budgetTotal", "0") ?: "0"
        val budgetPct = prefs.getString("budgetPct", "0") ?: "0"

        views.setTextViewText(R.id.budget_widget_title, "Budget mensuel")
        views.setTextViewText(R.id.budget_widget_amount, "$budgetSpent / $budgetTotal")
        views.setTextViewText(R.id.budget_widget_label, "$budgetLabel  •  $budgetPct%")

        // Set progress bar width via layout params
        val pct = budgetPct.toFloatOrNull()?.coerceIn(0f, 100f) ?: 0f
        val progressWidth = (pct / 100f * 32768).toInt() // max width in layout_weight terms
        views.setInt(R.id.budget_widget_progress, "setLayoutWidth", progressWidth)

        manager.updateAppWidget(id, views)
    }

    // ─── Savings Widget ─────────────────────────────────────────────
    private fun updateSavings(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        prefs: android.content.SharedPreferences,
    ) {
        val views = RemoteViews(context.packageName, R.layout.econome_savings_widget)

        val goalName = prefs.getString("savingsName", "") ?: ""
        val goalCurrent = prefs.getString("savingsCurrent", "0 €") ?: "0 €"
        val goalTarget = prefs.getString("savingsTarget", "0 €") ?: "0 €"
        val goalPct = prefs.getString("savingsPct", "0") ?: "0"

        views.setTextViewText(R.id.savings_widget_name, goalName)
        views.setTextViewText(R.id.savings_widget_amount, "$goalCurrent / $goalTarget")
        views.setTextViewText(R.id.savings_widget_pct, "${goalPct}% atteint")

        val pct = goalPct.toFloatOrNull()?.coerceIn(0f, 100f) ?: 0f
        val progressWidth = (pct / 100f * 32768).toInt()
        views.setInt(R.id.savings_widget_progress, "setLayoutWidth", progressWidth)

        manager.updateAppWidget(id, views)
    }

    // ─── Full Widget (original, improved) ───────────────────────────
    private fun updateFull(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        prefs: android.content.SharedPreferences,
    ) {
        val views = RemoteViews(context.packageName, R.layout.econome_widget_layout)

        val balance = prefs.getString("balance", "—") ?: "—"
        val balanceColor = parseColor(prefs.getString("balanceColor", "#A1A1AA") ?: "#A1A1AA")
        val budgetLabel = prefs.getString("budgetLabel", "") ?: ""
        val tx1 = prefs.getString("tx1", "") ?: ""
        val tx2 = prefs.getString("tx2", "") ?: ""
        val tx3 = prefs.getString("tx3", "") ?: ""

        views.setTextViewText(R.id.balance_text, balance)
        views.setTextColor(R.id.balance_text, balanceColor)

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

        manager.updateAppWidget(id, views)
    }

    private fun parseColor(hex: String): Int {
        return try {
            Color.parseColor(hex)
        } catch (_: Exception) {
            Color.parseColor("#A1A1AA")
        }
    }
}

// ─── Compact Widget Provider ─────────────────────────────────────────
class CompactWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(EconomeWidgetProvider.PREF_NAME, Context.MODE_PRIVATE)
        val provider = EconomeWidgetProvider()
        // Reuse the main provider's method by updating prefs with widget name
        prefs.edit().putString("widgetName", "CompactWidget").apply()
        provider.onUpdate(context, appWidgetManager, appWidgetIds)
    }
}

// ─── Budget Widget Provider ──────────────────────────────────────────
class BudgetWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(EconomeWidgetProvider.PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString("widgetName", "BudgetWidget").apply()
        val provider = EconomeWidgetProvider()
        provider.onUpdate(context, appWidgetManager, appWidgetIds)
    }
}

// ─── Savings Widget Provider ─────────────────────────────────────────
class SavingsWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(EconomeWidgetProvider.PREF_NAME, Context.MODE_PRIVATE)
        prefs.edit().putString("widgetName", "SavingsWidget").apply()
        val provider = EconomeWidgetProvider()
        provider.onUpdate(context, appWidgetManager, appWidgetIds)
    }
}
