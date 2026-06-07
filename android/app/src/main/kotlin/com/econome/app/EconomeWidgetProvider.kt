package com.econome.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews

// ─── Shared Helper ──────────────────────────────────────────────────

object WidgetHelper {
    const val PREF_NAME = "HomeWidgetPreferences"
    const val KEY_OVER_BUDGET = "overBudget"

    fun parseColor(hex: String): Int {
        return try {
            Color.parseColor(hex)
        } catch (_: Exception) {
            Color.parseColor("#A1A1AA")
        }
    }

    /** Crée un PendingIntent pour ouvrir l'application au tap. */
    fun createOpenAppIntent(context: Context, widgetId: Int): PendingIntent {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName) ?: run {
            Intent().apply {
                setClassName(context.packageName, "${context.packageName}.MainActivity")
            }
        }
        intent?.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        return PendingIntent.getActivity(context, widgetId, intent, flags)
    }
}

// ─── Full Widget (4×1) — Balance + Budget + 3 transactions ──────────

class EconomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(WidgetHelper.PREF_NAME, Context.MODE_PRIVATE)
        for (id in appWidgetIds) {
            updateFull(context, appWidgetManager, id, prefs)
        }
    }

    private fun updateFull(
        context: Context,
        manager: AppWidgetManager,
        id: Int,
        prefs: android.content.SharedPreferences,
    ) {
        val views = RemoteViews(context.packageName, R.layout.econome_widget_layout)

        val balance = prefs.getString("balance", "—") ?: "—"
        val balanceColor = WidgetHelper.parseColor(prefs.getString("balanceColor", "#A1A1AA") ?: "#A1A1AA")
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

        // Tap → ouvre l'app (sur le bouton racine ou le solde)
        views.setOnClickPendingIntent(
            R.id.balance_text,
            WidgetHelper.createOpenAppIntent(context, id)
        )

        manager.updateAppWidget(id, views)
    }
}

// ─── Compact Widget (2×1) — Balance only ────────────────────────────

class CompactWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(WidgetHelper.PREF_NAME, Context.MODE_PRIVATE)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.econome_compact_widget)

            val balance = prefs.getString("balance", "—") ?: "—"
            val balanceColor = WidgetHelper.parseColor(prefs.getString("balanceColor", "#A1A1AA") ?: "#A1A1AA")

            views.setTextViewText(R.id.compact_balance, balance)
            views.setTextColor(R.id.compact_balance, balanceColor)
            views.setTextViewText(R.id.compact_label, "Solde")

            // Tap → ouvre l'app
            views.setOnClickPendingIntent(
                R.id.compact_balance,
                WidgetHelper.createOpenAppIntent(context, id)
            )

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

// ─── Budget Widget (4×1) — Budget progress bar ─────────────────────

class BudgetWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(WidgetHelper.PREF_NAME, Context.MODE_PRIVATE)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.econome_budget_widget)

            val budgetLabel = prefs.getString("budgetLabel", "—") ?: "—"
            val budgetSpent = prefs.getString("budgetSpent", "0") ?: "0"
            val budgetTotal = prefs.getString("budgetTotal", "0") ?: "0"
            val budgetPct = prefs.getString("budgetPct", "0") ?: "0"
            val overBudget = prefs.getBoolean(WidgetHelper.KEY_OVER_BUDGET, false)

            views.setTextViewText(R.id.budget_widget_title, "Budget mensuel")
            views.setTextViewText(R.id.budget_widget_amount, "$budgetSpent / $budgetTotal")
            views.setTextViewText(R.id.budget_widget_label, "$budgetLabel  ·  $budgetPct%")

            // Couleur du montant selon dépassement (la barre est gérée par XML)
            if (overBudget) {
                views.setTextColor(R.id.budget_widget_amount, Color.parseColor("#EF4444"))
            } else {
                views.setTextColor(R.id.budget_widget_amount, Color.parseColor("#F59E0B"))
            }

            // Valeur de la barre de progression
            val pctFloat = budgetPct.toFloatOrNull()?.coerceIn(0f, 100f) ?: 0f
            views.setInt(R.id.budget_progress, "setProgress", pctFloat.toInt())

            // Tap → ouvre l'app
            views.setOnClickPendingIntent(
                R.id.budget_widget_amount,
                WidgetHelper.createOpenAppIntent(context, id)
            )

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

// ─── Savings Widget (4×1) — Savings goal progress ──────────────────

class SavingsWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        val prefs = context.getSharedPreferences(WidgetHelper.PREF_NAME, Context.MODE_PRIVATE)
        for (id in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.econome_savings_widget)

            val goalName = prefs.getString("savingsName", "") ?: ""
            val goalCurrent = prefs.getString("savingsCurrent", "0 €") ?: "0 €"
            val goalTarget = prefs.getString("savingsTarget", "0 €") ?: "0 €"
            val goalPct = prefs.getString("savingsPct", "0") ?: "0"

            views.setTextViewText(R.id.savings_widget_name, goalName)
            views.setTextViewText(R.id.savings_widget_amount, "$goalCurrent / $goalTarget")
            views.setTextViewText(R.id.savings_widget_pct, "${goalPct}% atteint")

            // Couleur selon progression : vert vif si objectif atteint
            val pctFloat = goalPct.toFloatOrNull()?.coerceIn(0f, 100f) ?: 0f
            if (pctFloat >= 100f) {
                views.setTextColor(R.id.savings_widget_amount, Color.parseColor("#22C55E"))
            } else {
                views.setTextColor(R.id.savings_widget_amount, Color.parseColor("#10B981"))
            }

            // Valeur de la barre de progression
            views.setInt(R.id.savings_progress, "setProgress", pctFloat.toInt())

            // Tap → ouvre l'app
            views.setOnClickPendingIntent(
                R.id.savings_widget_amount,
                WidgetHelper.createOpenAppIntent(context, id)
            )

            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
