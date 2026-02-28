import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_mode_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../../l10n/app_localizations.dart';

class ModeToggle extends ConsumerWidget {
  const ModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    final isBasic = mode == AppMode.basic;
    final l10n = L10n.of(context)!;

    return GestureDetector(
      onTap: () => ref.read(appModeProvider.notifier).toggle(),
      child: AnimatedContainer(
        duration: AppDurations.normal,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isBasic
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.ai.withValues(alpha: 0.12),
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: isBasic
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.ai.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBasic ? Icons.grid_view_rounded : Icons.auto_awesome_rounded,
              size: 14,
              color: isBasic ? AppColors.primary : AppColors.ai,
            ),
            const SizedBox(width: 4),
            AnimatedSwitcher(
              duration: AppDurations.fast,
              child: Text(
                isBasic ? l10n.basicMode : l10n.proMode,
                key: ValueKey(isBasic),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isBasic ? AppColors.primary : AppColors.ai,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
