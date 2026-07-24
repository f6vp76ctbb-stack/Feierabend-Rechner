import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profiles/profile_manage_sheet.dart';
import '../state/home_providers.dart';

/// Horizontale Leiste zum schnellen Umschalten zwischen Profilen.
/// Zeigt nur mehr als ein Element, wenn es mehrere Profile gibt — bleibt sonst dezent.
class ProfileBar extends ConsumerWidget {
  const ProfileBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profilesControllerProvider);
    final controller = ref.read(profilesControllerProvider.notifier);

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final p in state.profiles)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(p.name),
                selected: p.id == state.activeId,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  controller.setActive(p.id);
                },
              ),
            ),
          ActionChip(
            avatar: const Icon(Icons.tune_rounded, size: 18),
            label: const Text('Profile'),
            onPressed: () => ProfileManageSheet.show(context),
          ),
        ],
      ),
    );
  }
}
