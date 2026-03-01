import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/logger.dart';
import '../../../l10n/app_localizations.dart';
import '../logic/scan_controller.dart';
import '../services/gallery_service.dart';
import '../services/vision_processor.dart';
import '../services/qr_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dialog that offers to scan the user's gallery photos from the last 7 days
/// on first launch, after the Feature Tour completes.
class RetroScanDialog extends StatefulWidget {
  const RetroScanDialog({super.key});

  static const String _keyRetroScanDone = 'retro_scan_completed';

  static Future<bool> hasCompletedRetroScan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRetroScanDone) ?? false;
  }

  static Future<void> markRetroScanDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRetroScanDone, true);
  }

  /// Show the retro scan dialog. Returns the number of food entries found, or null if skipped.
  static Future<int?> show(BuildContext context) async {
    final alreadyDone = await hasCompletedRetroScan();
    if (alreadyDone) return null;

    if (!context.mounted) return null;

    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RetroScanDialog(),
    );
  }

  @override
  State<RetroScanDialog> createState() => _RetroScanDialogState();
}

enum _RetroScanPhase { ask, scanning, done }

class _RetroScanDialogState extends State<RetroScanDialog>
    with SingleTickerProviderStateMixin {
  _RetroScanPhase _phase = _RetroScanPhase.ask;
  int _totalImages = 0;
  int _foodFound = 0;
  String _statusText = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _phase = _RetroScanPhase.scanning;
      _statusText = L10n.of(context)!.retroScanFetchingPhotos;
    });

    try {
      final galleryService = GalleryService();
      final visionProcessor = VisionProcessor();
      final qrParser = QRParser();
      final scanController = ScanController(
        galleryService,
        visionProcessor,
        qrParser,
      );

      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));

      AppLogger.info('RetroScan: Starting scan for images from last 3 days...');

      final images = await galleryService.fetchNewImages(after: threeDaysAgo);

      if (!mounted) return;

      setState(() {
        _totalImages = images.length;
        _statusText = L10n.of(context)!.retroScanAnalyzing;
      });

      if (images.isEmpty) {
        setState(() {
          _phase = _RetroScanPhase.done;
          _foodFound = 0;
        });
        await RetroScanDialog.markRetroScanDone();
        return;
      }

      final savedCount = await scanController.scanNewImages(after: threeDaysAgo);

      visionProcessor.dispose();

      if (!mounted) return;

      setState(() {
        _phase = _RetroScanPhase.done;
        _foodFound = savedCount;
      });

      await RetroScanDialog.markRetroScanDone();

      AppLogger.info('RetroScan: Complete! Found $savedCount food entries from ${images.length} images');
    } catch (e) {
      AppLogger.error('RetroScan: Error during scan', e);
      if (!mounted) return;

      setState(() {
        _phase = _RetroScanPhase.done;
        _foodFound = 0;
      });

      await RetroScanDialog.markRetroScanDone();
    }
  }

  void _skip() async {
    await RetroScanDialog.markRetroScanDone();
    if (mounted) {
      Navigator.pop(context, null);
    }
  }

  void _close() {
    Navigator.pop(context, _foodFound);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: switch (_phase) {
                _RetroScanPhase.ask => _buildAskPhase(l10n, isDark),
                _RetroScanPhase.scanning => _buildScanningPhase(l10n, isDark),
                _RetroScanPhase.done => _buildDonePhase(l10n, isDark),
              },
            ),
          ),
          if (_phase != _RetroScanPhase.scanning)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.05),
                ),
                onPressed: () {
                  RetroScanDialog.markRetroScanDone();
                  Navigator.pop(context, _phase == _RetroScanPhase.done ? _foodFound : null);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAskPhase(L10n l10n, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.info.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.photo_library_rounded,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.retroScanTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.retroScanDescription,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.08),
            borderRadius: AppRadius.sm,
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.info),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.retroScanNote,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startScan,
            icon: const Icon(Icons.auto_awesome, size: 20),
            label: Text(l10n.retroScanStart),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _skip,
          child: Text(
            l10n.retroScanSkip,
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningPhase(L10n l10n, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.document_scanner_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          l10n.retroScanTagline,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        ClipRRect(
          borderRadius: AppRadius.sm,
          child: const LinearProgressIndicator(
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _statusText,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        if (_totalImages > 0) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.retroScanPhotosFound(_totalImages),
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDonePhase(L10n l10n, bool isDark) {
    final hasResults = _foodFound > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: (hasResults ? AppColors.success : AppColors.info)
                .withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            hasResults ? Icons.check_circle_rounded : Icons.search_off_rounded,
            size: 48,
            color: hasResults ? AppColors.success : AppColors.info,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          hasResults
              ? l10n.retroScanCompleteTitle
              : l10n.retroScanNoResultsTitle,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          hasResults
              ? l10n.retroScanCompleteDesc(_foodFound)
              : l10n.retroScanNoResultsDesc,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (hasResults) ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.08),
              borderRadius: AppRadius.sm,
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.warning),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.retroScanAnalyzeHint,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _close,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.sm),
            ),
            child: Text(l10n.retroScanDone),
          ),
        ),
      ],
    );
  }
}
