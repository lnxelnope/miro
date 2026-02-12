import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/ai/gemini_service.dart';
import '../providers/profile_provider.dart';

class ApiKeyScreen extends ConsumerStatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  ConsumerState<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends ConsumerState<ApiKeyScreen> {
  final _keyController = TextEditingController();
  bool _isLoading = false;
  bool _isTesting = false;
  bool _hasKey = false;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _loadExistingKey();
  }

  Future<void> _loadExistingKey() async {
    final key = await SecureStorageService.getGeminiApiKey();
    if (key != null && key.isNotEmpty && mounted) {
      setState(() {
        _keyController.text = key;
        _hasKey = true;
      });
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up Gemini API Key')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBox(),
            const SizedBox(height: 24),
            _buildStep1(),
            _buildStep2(),
            _buildStep3(),
            _buildStep4(),
            _buildStep5KeyInput(),
            const SizedBox(height: 16),
            _buildSaveButton(),
            const SizedBox(height: 8),
            _buildTestButton(),
            const SizedBox(height: 8),
            if (_hasKey) _buildDeleteButton(),
            const SizedBox(height: 32),
            _buildFAQ(),
          ],
        ),
      ),
    );
  }

  // ============ UI Components ============

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.smart_toy, size: 32, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Food Analysis',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 4),
                Text('Snap food photos → AI calculates calories automatically\nGemini API is free — no payment required!',
                    style: TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _buildStepCard(
      stepNumber: 1,
      title: 'เปิด Google AI Studio',
      description: 'กดปุ่มด้านล่างเพื่อไปสร้าง API Key',
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _openUrl('https://aistudio.google.com/apikey'),
          icon: const Icon(Icons.open_in_new),
          label: const Text('เปิด Google AI Studio'),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return _buildStepCard(
      stepNumber: 2,
      title: 'Sign in with Google Account',
      description: 'Use your existing Gmail or Google Account (create one for free if needed)',
    );
  }

  Widget _buildStep3() {
    return _buildStepCard(
      stepNumber: 3,
      title: 'คลิก "Create API Key"',
      description: 'กดปุ่มสีน้ำเงิน "Create API Key"\nถ้าถามให้เลือก Project → กด "Create API key in new project"',
    );
  }

  Widget _buildStep4() {
    return _buildStepCard(
      stepNumber: 4,
      title: 'Copy Key and paste it below',
      description: 'Click the Copy button next to the created Key\nKey will look like: AIzaSyxxxx...',
    );
  }

  Widget _buildStep5KeyInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStepBadge(5),
            const SizedBox(width: 8),
            const Text('วาง API Key ที่นี่',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _keyController,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  hintText: 'Paste copied API Key',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // ปุ่มวาง (Paste)
            IconButton.filled(
              onPressed: _pasteFromClipboard,
              icon: const Icon(Icons.content_paste),
              tooltip: 'วาง',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepBadge(stepNumber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                if (child != null) ...[
                  const SizedBox(height: 8),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBadge(int number) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text('$number',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveKey,
        icon: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.save),
        label: const Text('Save API Key'),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: (_isTesting || !_hasKey) ? null : _testConnection,
        icon: _isTesting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.wifi_tethering),
        label: Text(_isTesting ? 'Testing...' : 'Test Connection'),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton.icon(
        onPressed: _deleteKey,
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        label: const Text('ลบ API Key', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  // ============ FAQ Section ============

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Frequently Asked Questions',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _buildFaqItem(
          question: 'Is it really free?',
          answer: 'Yes, it\'s free! Gemini 2.0 Flash offers 1,500 free requests/day\n'
              'For food logging (5-15 times/day) → free forever, no payment needed',
        ),
        _buildFaqItem(
          question: 'ปลอดภัยไหม?',
          answer: 'API Key เก็บใน Secure Storage ในเครื่องเท่านั้น\n'
              'แอปไม่ส่ง Key ไปที่ server ของเรา\n'
              'ถ้า Key หลุด → ลบทิ้งสร้างใหม่ได้เลย (ไม่ใช่รหัสผ่าน Google)',
        ),
        _buildFaqItem(
          question: 'What if I don\'t create a Key?',
          answer: 'You can still use the app! But:\n'
              '❌ Cannot take photos → AI analysis\n'
              '✅ Can log food manually\n'
              '✅ Quick Add works\n'
              '✅ Can view kcal/macro summary',
        ),
        _buildFaqItem(
          question: 'ต้องมีบัตรเครดิตไหม?',
          answer: 'ไม่ต้อง — สร้าง API Key ได้ฟรีโดยไม่ต้องใส่บัตรเครดิต',
        ),
      ],
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 8, bottom: 12),
      children: [
        Text(answer, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ],
    );
  }

  // ============ Actions ============

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() => _keyController.text = data.text!);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        _showSnackBar('ไม่สามารถเปิดลิงก์ได้: $url', isError: true);
      }
    }
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      _showSnackBar('Please paste API Key first', isError: true);
      return;
    }
    if (!key.startsWith('AIza')) {
      _showSnackBar('API Key ไม่ถูกต้อง — ต้องขึ้นต้นด้วย "AIza"', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SecureStorageService.saveGeminiApiKey(key);
      
      // Update profile
      final profileNotifier = ref.read(profileNotifierProvider.notifier);
      final profile = ref.read(profileNotifierProvider).value;
      if (profile != null) {
        profile.hasGeminiApiKey = true;
        await profileNotifier.updateProfile(profile);
      }
      
      if (mounted) {
        setState(() {
          _hasKey = true;
          _isLoading = false;
        });
        _showSnackBar('API Key saved successfully');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Error: $e', isError: true);
      }
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    try {
      final success = await GeminiService.testConnection();
      if (mounted) {
        _showSnackBar(success ? '✅ Connection successful! Ready to use' : '❌ Connection failed',
            isError: !success);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _deleteKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบ API Key?'),
        content: const Text('จะไม่สามารถใช้ AI วิเคราะห์อาหารได้จนกว่าจะตั้งค่าใหม่'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SecureStorageService.deleteGeminiApiKey();
      
      // Update profile
      final profileNotifier = ref.read(profileNotifierProvider.notifier);
      final profile = ref.read(profileNotifierProvider).value;
      if (profile != null) {
        profile.hasGeminiApiKey = false;
        await profileNotifier.updateProfile(profile);
      }
      
      if (mounted) {
        setState(() {
          _keyController.clear();
          _hasKey = false;
        });
        _showSnackBar('API Key deleted successfully');
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
