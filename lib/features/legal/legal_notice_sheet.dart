import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_info.dart';
import '../../l10n/l10n_ext.dart';

/// Impressum direkt in der App (§ 5 DDG): in zwei Tipps erreichbar
/// (Einstellungen → Impressum) und auch offline lesbar. Inhalt wie bei „Qubble“;
/// die Online-Fassung liegt in `web/impressum.html`.
class LegalNoticeSheet extends StatelessWidget {
  const LegalNoticeSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const LegalNoticeSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l10n;

    Widget section(String title, Widget body) => Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              body,
            ],
          ),
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.legalNotice, style: theme.textTheme.titleMedium),
            section(
              l.legalNoticeLaw,
              SelectableText(
                [
                  AppInfo.providerName,
                  AppInfo.businessName,
                  AppInfo.providerStreet,
                  AppInfo.providerCity,
                  l.legalCountry,
                ].join('\n'),
                style: theme.textTheme.bodyLarge,
              ),
            ),
            section(
              l.legalContact,
              InkWell(
                onTap: () => launchUrl(
                  Uri(scheme: 'mailto', path: AppInfo.contactEmail),
                  mode: LaunchMode.externalApplication,
                ),
                child: Text(
                  AppInfo.contactEmail,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            section(
              l.legalResponsible,
              Text(l.legalResponsibleBody(AppInfo.providerName),
                  style: theme.textTheme.bodyMedium),
            ),
            section(
              l.legalDispute,
              Text(l.legalDisputeBody, style: theme.textTheme.bodyMedium),
            ),
            section(
              l.legalNote,
              Text(l.legalNoteBody, style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
