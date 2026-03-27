import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service_provider.dart';
import '../../../data/datasources/local/hive_boxes.dart';
import '../../theme/app_theme.dart';

class ProductScannerScreen extends ConsumerStatefulWidget {
  const ProductScannerScreen({super.key});

  @override
  ConsumerState<ProductScannerScreen> createState() => _ProductScannerScreenState();
}

class _ProductScannerScreenState extends ConsumerState<ProductScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selectedImage;
  bool _isAnalyzing = false;
  String _statusMessage = '';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImage = bytes;
        _statusMessage = '';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: AppTheme.scoreBad),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    setState(() {
      _isAnalyzing = true;
      _statusMessage = 'Sending image to Gemma AI for analysis...';
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final report = await aiService.analyzeImage(_selectedImage!);

      // Cache & increment scan count
      await HiveBoxes.cacheReport(report);
      final user = HiveBoxes.currentUser.incrementScans();
      await HiveBoxes.updateUser(user);

      if (mounted) {
        context.push(
          AppRoutes.sustainabilityReport,
          extra: {'report': report.toJson()},
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Analysis failed. Make sure the backend is running.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.scoreBad),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product'),
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.primaryCharcoal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview area
            GestureDetector(
              onTap: _isAnalyzing ? null : () => _showSourcePicker(isDark),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 280,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _selectedImage != null
                        ? AppTheme.accentEmerald.withValues(alpha: 0.4)
                        : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300),
                    width: 2,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _selectedImage != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(_selectedImage!, fit: BoxFit.cover),
                          // Overlay gradient
                          Positioned(
                            bottom: 0, left: 0, right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppTheme.accentEmerald, size: 18),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text('Image ready for analysis',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                                  ),
                                  if (!_isAnalyzing)
                                    GestureDetector(
                                      onTap: () => _showSourcePicker(isDark),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text('Change', style: TextStyle(color: Colors.white, fontSize: 12)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.accentEmerald.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt_rounded, size: 48, color: AppTheme.accentEmerald),
                          ),
                          const SizedBox(height: 20),
                          Text('Tap to capture or select image',
                              style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : AppTheme.primaryCharcoal,
                              )),
                          const SizedBox(height: 6),
                          Text('Take a photo of product ingredients or packaging',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                              )),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Quick source buttons
            if (_selectedImage == null)
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      color: AppTheme.accentEmerald,
                      isDark: isDark,
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      color: AppTheme.accentCyan,
                      isDark: isDark,
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Status message
            if (_statusMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _isAnalyzing
                      ? AppTheme.accentCyan.withValues(alpha: 0.1)
                      : AppTheme.scoreBad.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _isAnalyzing
                        ? AppTheme.accentCyan.withValues(alpha: 0.3)
                        : AppTheme.scoreBad.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    if (_isAnalyzing)
                      const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentCyan),
                      )
                    else
                      Icon(Icons.error_outline_rounded, color: AppTheme.scoreBad, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_statusMessage, style: TextStyle(
                      color: _isAnalyzing ? AppTheme.accentCyan : AppTheme.scoreBad,
                      fontWeight: FontWeight.w500, fontSize: 13,
                    ))),
                  ],
                ),
              ),

            // Analyze button
            if (_selectedImage != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : _analyzeImage,
                  icon: _isAnalyzing
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(_isAnalyzing ? 'Analyzing with Gemma AI...' : 'Analyze with AI'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppTheme.accentEmerald,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppTheme.accentEmerald.withValues(alpha: 0.5),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            const SizedBox(height: 28),

            // Info section
            _buildInfoCard(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? AppTheme.cardDark : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.info_outline_rounded, color: AppTheme.accentCyan, size: 20),
            const SizedBox(width: 8),
            Text('How It Works', style: TextStyle(fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
          ]),
          const SizedBox(height: 14),
          _infoStep('1', 'Capture or select a photo of product ingredients or packaging', isDark),
          const SizedBox(height: 10),
          _infoStep('2', 'Our Gemma AI vision model analyzes the image for sustainability data', isDark),
          const SizedBox(height: 10),
          _infoStep('3', 'Get a detailed sustainability report with carbon score and recommendations', isDark),
        ],
      ),
    );
  }

  Widget _infoStep(String number, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24, height: 24,
          decoration: const BoxDecoration(
            color: AppTheme.accentEmerald,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(number, style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          height: 1.4,
        ))),
      ],
    );
  }

  void _showSourcePicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text('Select Image Source', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : AppTheme.primaryCharcoal,
              )),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentEmerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppTheme.accentEmerald),
                ),
                title: Text('Camera', style: TextStyle(fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
                subtitle: Text('Take a photo of the product',
                    style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: AppTheme.accentCyan),
                ),
                title: Text('Gallery', style: TextStyle(fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.primaryCharcoal)),
                subtitle: Text('Choose from your gallery',
                    style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade500)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isDark ? AppTheme.cardDark : Colors.white,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(label, style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppTheme.primaryCharcoal,
            )),
          ],
        ),
      ),
    );
  }
}
