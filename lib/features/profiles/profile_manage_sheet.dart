import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/state/home_providers.dart';

/// Overlay zur Profil-Verwaltung: umschalten, anlegen, umbenennen, löschen.
class ProfileManageSheet extends ConsumerWidget {
  const ProfileManageSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ProfileManageSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(profilesControllerProvider);
    final controller = ref.read(profilesControllerProvider.notifier);
    final canDelete = state.profiles.length > 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('Profile', style: theme.textTheme.titleMedium),
          ),
          const SizedBox(height: 8),
          ...state.profiles.map(
            (p) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              leading: Icon(
                p.id == state.activeId
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: theme.colorScheme.primary,
              ),
              title: Text(p.name),
              onTap: () {
                HapticFeedback.selectionClick();
                controller.setActive(p.id);
                Navigator.of(context).pop();
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Umbenennen',
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () async {
                      final name = await _promptName(context, initial: p.name);
                      if (name != null && name.isNotEmpty) {
                        controller.renameProfile(p.id, name);
                      }
                    },
                  ),
                  IconButton(
                    tooltip: canDelete ? 'Löschen' : 'Mindestens ein Profil',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: canDelete
                        ? () => _confirmDelete(context, ref, p.id, p.name)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FilledButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('Neues Profil'),
              onPressed: () async {
                final name = await _promptName(context, initial: '');
                if (name != null && name.isNotEmpty) {
                  controller.addProfile(name);
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('„$name" löschen?'),
        content: const Text('Das Profil wird dauerhaft entfernt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (ok == true) {
      ref.read(profilesControllerProvider.notifier).deleteProfile(id);
    }
  }
}

/// Kleiner Namens-Dialog. Liefert den Namen oder `null` bei Abbruch.
Future<String?> _promptName(BuildContext context, {required String initial}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(initial.isEmpty ? 'Neues Profil' : 'Profil umbenennen'),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'z. B. Mo–Do, Freitag, Nachtschicht',
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Speichern'),
        ),
      ],
    ),
  );
}
