import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/providers/locale_provider.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  final VoidCallback onLanguageSelected;

  const LanguageSelectionScreen({
    super.key,
    required this.onLanguageSelected,
  });

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedCode;
  late AnimationController _animController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  static const _languages = [
    {'code': 'en', 'flag': '🇺🇸', 'name': 'English', 'native': 'English'},
    {'code': 'th', 'flag': '🇹🇭', 'name': 'Thai', 'native': 'ไทย'},
    {'code': 'vi', 'flag': '🇻🇳', 'name': 'Vietnamese', 'native': 'Tiếng Việt'},
    {'code': 'id', 'flag': '🇮🇩', 'name': 'Indonesian', 'native': 'Bahasa Indonesia'},
    {'code': 'zh', 'flag': '🇨🇳', 'name': 'Chinese', 'native': '中文'},
    {'code': 'ja', 'flag': '🇯🇵', 'name': 'Japanese', 'native': '日本語'},
    {'code': 'ko', 'flag': '🇰🇷', 'name': 'Korean', 'native': '한국어'},
    {'code': 'es', 'flag': '🇪🇸', 'name': 'Spanish', 'native': 'Español'},
    {'code': 'fr', 'flag': '🇫🇷', 'name': 'French', 'native': 'Français'},
    {'code': 'de', 'flag': '🇩🇪', 'name': 'German', 'native': 'Deutsch'},
    {'code': 'pt', 'flag': '🇵🇹', 'name': 'Portuguese', 'native': 'Português'},
    {'code': 'hi', 'flag': '🇮🇳', 'name': 'Hindi', 'native': 'हिन्दी'},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _confirmSelection() async {
    if (_selectedCode == null) return;

    ref.read(localeProvider.notifier).state = Locale(_selectedCode!);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_locale', _selectedCode!);
    await prefs.setBool('language_selected', true);

    widget.onLanguageSelected();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Column(
              children: [
                // -- Top: Logo + Title --
                SizedBox(height: size.height * 0.06),
                _buildHeader(size, isDark),
                SizedBox(height: size.height * 0.03),

                // -- Language Grid --
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemCount: _languages.length,
                      itemBuilder: (context, index) {
                        final lang = _languages[index];
                        final isSelected = _selectedCode == lang['code'];
                        return _buildLanguageTile(
                          lang,
                          isSelected,
                          cardBg,
                          isDark,
                          index,
                        );
                      },
                    ),
                  ),
                ),

                // -- Bottom: Continue Button --
                _buildContinueButton(isDark),
                SizedBox(height: size.height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size, bool isDark) {
    return Column(
      children: [
        // Logo with glow effect
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/icon/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to MiRO',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose your preferred language',
          style: TextStyle(
            fontSize: 15,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'เลือกภาษาที่คุณต้องการ',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.textSecondaryDark.withValues(alpha: 0.7)
                : AppColors.textTertiary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageTile(
    Map<String, String> lang,
    bool isSelected,
    Color cardBg,
    bool isDark,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => setState(() => _selectedCode = lang['code']),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08)
                : cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Flag
              Text(
                lang['flag']!,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              // Native name
              Text(
                lang['native']!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? Colors.white
                          : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // English name
              Text(
                lang['name']!,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.7)
                      : isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              // Selected check
              if (isSelected) ...[
                const SizedBox(height: 4),
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final isEnabled = _selectedCode != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: AnimatedOpacity(
              opacity: isEnabled ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton(
                onPressed: isEnabled ? _confirmSelection : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: isEnabled ? 4 : 0,
                  shadowColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isEnabled ? 'Continue' : 'Select a language',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (isEnabled) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
