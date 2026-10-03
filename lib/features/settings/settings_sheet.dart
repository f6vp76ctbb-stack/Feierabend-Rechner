import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/monetization_config.dart';
import '../../core/formatting.dart';
import '../../domain/reminder_planner.dart';
import '../../l10n/l10n_ext.dart';
import '../designs/design_providers.dart';
import '../designs/design_shop_sheet.dart';
import '../home/state/home_providers.dart';
import '../home/widgets/duration_adjust_sheet.dart';
import '../pro/paywall_sheet.dart';
import '../pro/pro_providers.dart';
import '../reminders/reminder_providers.dart';
import '../widget/widget_providers.dart';

/// Einstellungs-Overlay: Soll pro Tag, Erscheinungsbild, Pro, Rechtliches.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final mode = ref.watch(themeModeProvider);
    final dailyTarget = ref.watch(dailyTargetProvider);
    final isPro = ref.watch(isProProvider);
    final pro = ref.watch(proControllerProvider);
    final tester = ref.watch(testerBuildProvider);
    final storeAvailable =
        !tester && ref.watch(purchaseBackendProvider).isSupported;
    final privacyOptions =
        ref.watch(privacyOptionsRequiredProvider).valueOrNull ?? false;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.settings, style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),

            // --- Pro ---
            Text(l.proSection, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            if (isPro)
              Row(
                children: [
                  const Icon(Icons.workspace_premium_rounded,
                      color: Color(0xFF00B894)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tester
                          ? l.testerBuildActive
                          : pro.purchased ||
                                  !MonetizationConfig.isMobile ||
                                  pro.trialUntil == null
                              ? l.proActive
                              : l.proTrialActive(DateFormat.Md(context.lang)
                                  .add_Hm()
                                  .format(pro.trialUntil!)),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            if (!tester &&
                (!isPro || (!pro.purchased && MonetizationConfig.isMobile)))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton.icon(
                  onPressed: () => PaywallSheet.show(context),
                  icon: const Icon(Icons.workspace_premium_rounded),
                  label: Text(l.unlockPro),
                ),
              ),
            if (storeAvailable)
              TextButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref.read(proControllerProvider.notifier).restore();
                  messenger.showSnackBar(
                      SnackBar(content: Text(l.restoreDone)));
                },
                child: Text(l.restorePurchases),
              ),
            const SizedBox(height: 16),

            // --- Erinnerungen (nur in den mobilen Apps) ---
            if (ref.watch(notificationBackendProvider).isSupported) ...[
              const _RemindersSection(),
              const SizedBox(height: 16),
            ],

            // --- Home-Screen-Widget (nur Android) ---
            if (ref.watch(widgetBackendProvider).isSupported) ...[
              const _WidgetSection(),
              const SizedBox(height: 16),
            ],

            // --- Soll pro Tag ---
            Text(l.dailyTarget, style: theme.textTheme.labelLarge),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await DurationAdjustSheet.show(
                  context,
                  title: l.dailyTarget,
                  initial: dailyTarget,
                  step: const Duration(minutes: 15),
                  min: Duration.zero,
                  max: const Duration(hours: 16),
                  presets: const [
                    Duration(hours: 6),
                    Duration(hours: 7),
                    Duration(hours: 8),
                    Duration(hours: 8, minutes: 30),
                  ],
                );
                if (picked != null) {
                  ref.read(dailyTargetProvider.notifier).set(picked);
                }
              },
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: Text(Formatting.durationHm(dailyTarget)),
            ),
            const SizedBox(height: 6),
            Text(l.dailyTargetHint, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),

            // --- Designs (einzeln kaufbar) ---
            Text(l.designsTitle, style: theme.textTheme.labelLarge),
            const _DesignsTile(),
            const SizedBox(height: 16),

            // --- Erscheinungsbild ---
            Text(l.appearance, style: theme.textTheme.labelLarge),
            const SizedBox(height: 10),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text(l.themeSystem),
                  icon: const Icon(Icons.brightness_auto_rounded),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text(l.themeLight),
                  icon: const Icon(Icons.light_mode_rounded),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text(l.themeDark),
                  icon: const Icon(Icons.dark_mode_rounded),
                ),
              ],
              selected: {mode},
              showSelectedIcon: false,
              onSelectionChanged: (sel) {
                HapticFeedback.selectionClick();
                ref.read(themeModeProvider.notifier).set(sel.first);
              },
            ),
            const SizedBox(height: 12),
            Text(l.autosaveHint, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),

            // --- Rechtliches ---
            Text(l.legalSection, style: theme.textTheme.labelLarge),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.policy_outlined),
              title: Text(l.privacyPolicy),
              trailing: const Icon(Icons.open_in_new_rounded, size: 18),
              onTap: () => launchUrl(
                Uri.parse(MonetizationConfig.privacyPolicyUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
            if (privacyOptions && !isPro)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(l.privacySettings),
                onTap: () =>
                    ref.read(adsBackendProvider).showPrivacyOptions(),
              ),
          ],
        ),
      ),
    );
  }
}

class _RemindersSection extends ConsumerWidget {
  const _RemindersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final settings = ref.watch(reminderSettingsProvider);
    final isPro = ref.watch(isProProvider);
    final active = settings.enabled && isPro;
    final ctrl = ref.read(reminderSettingsProvider.notifier);

    Future<void> toggle(bool on) async {
      HapticFeedback.selectionClick();
      if (!on) return ctrl.setEnabled(false);
      if (!isPro) return PaywallSheet.show(context);
      final messenger = ScaffoldMessenger.of(context);
      final granted =
          await ref.read(notificationBackendProvider).requestPermission();
      if (granted) {
        ctrl.setEnabled(true);
      } else {
        messenger.showSnackBar(SnackBar(content: Text(l.notificationsDenied)));
      }
    }

    // Vorschläge + eigene Zeiten, kürzeste zuerst.
    final chips = {...ReminderOptions.presetLeads, ...settings.leads}.toList()
      ..sort();

    void toggleLead(Duration lead) {
      HapticFeedback.selectionClick();
      if (!settings.hasLead(lead) &&
          settings.leads.length >= ReminderOptions.maxLeads) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.reminderMaxLeads)));
        return;
      }
      ctrl.toggleLead(lead);
    }

    Future<void> addCustom() async {
      final picked = await DurationAdjustSheet.show(
        context,
        title: l.reminderCustomTitle,
        initial: const Duration(minutes: 45),
        step: const Duration(minutes: 5),
        min: const Duration(minutes: 5),
        max: ReminderOptions.maxLead,
        presets: const [
          Duration(minutes: 10),
          Duration(minutes: 45),
          Duration(minutes: 90),
          Duration(hours: 3),
        ],
      );
      if (picked != null && !settings.hasLead(picked)) toggleLead(picked);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.remindersTitle, style: theme.textTheme.labelLarge),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.notifications_active_outlined),
          title: Row(
            children: [
              Flexible(child: Text(l.remindersSwitch)),
              if (!isPro) ...[const SizedBox(width: 8), const ProBadge()],
            ],
          ),
          subtitle: Text(l.remindersHint),
          value: active,
          onChanged: toggle,
        ),
        if (active) ...[
          Text(l.reminderLeads, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final lead in chips)
                FilterChip(
                  label: Text(Formatting.durationLong(lead, context.units)),
                  selected: settings.hasLead(lead),
                  onSelected: (_) => toggleLead(lead),
                ),
              ActionChip(
                avatar: const Icon(Icons.add_rounded, size: 18),
                label: Text(l.reminderCustom),
                onPressed: addCustom,
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.coffee_outlined),
            title: Text(l.reminderHalf),
            value: settings.halfTime,
            onChanged: ctrl.setHalfTime,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.celebration_outlined),
            title: Text(l.reminderEnd),
            value: settings.atEnd,
            onChanged: ctrl.setAtEnd,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.format_quote_rounded),
            title: Text(l.reminderQuote),
            subtitle: Text(l.reminderQuoteHint),
            value: settings.withQuote,
            onChanged: ctrl.setWithQuote,
          ),
        ],
      ],
    );
  }
}

class _WidgetSection extends ConsumerWidget {
  const _WidgetSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;

    Future<void> add() async {
      HapticFeedback.selectionClick();
      final messenger = ScaffoldMessenger.of(context);
      final pinned = await ref.read(widgetBackendProvider).requestPin();
      // Launcher ohne „Anheften"-Dialog: Weg von Hand erklären.
      if (!pinned) {
        messenger.showSnackBar(SnackBar(content: Text(l.widgetManual)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.widgetTitle, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(l.widgetHint, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: add,
          icon: const Icon(Icons.widgets_outlined),
          label: Text(l.widgetAdd),
        ),
      ],
    );
  }
}

class _DesignsTile extends ConsumerWidget {
  const _DesignsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final design = ref.watch(activeDesignProvider);
    final colors = design.ring;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: design.hearts
            ? const Icon(Icons.favorite_rounded, size: 18, color: Colors.white)
            : null,
      ),
      title: Text(l.designsOpen),
      subtitle: Text(l.designCurrent(designName(l, design))),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => DesignShopSheet.show(context),
    );
  }
}
