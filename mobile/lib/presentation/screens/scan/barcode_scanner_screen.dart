import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/services/ai_service_provider.dart';
import '../../../data/datasources/local/hive_boxes.dart';
import '../../theme/app_theme.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // For web, show manual input UI
    // For mobile, this would use camera (when running on actual device)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: _buildManualInputUI(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.ingredientScanner),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.document_scanner),
        label: const Text('Scan Ingredients'),
      ),
    );
  }

  Widget _buildManualInputUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 80,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 32),

          // Title
          Text(
            kIsWeb ? 'Enter Barcode' : 'Scan or Enter Barcode',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            kIsWeb
                ? 'Enter the product barcode number to analyze its sustainability'
                : 'Point camera at barcode or enter manually',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Barcode Input
          TextField(
            controller: _barcodeController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Barcode Number',
              hintText: 'e.g., 5901234123457',
              prefixIcon: const Icon(Icons.qr_code),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onSubmitted: (_) => _analyzeBarcode(),
          ),
          const SizedBox(height: 24),

          // Analyze Button
          ElevatedButton.icon(
            onPressed: _isProcessing ? null : _analyzeBarcode,
            icon: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(_isProcessing ? 'Analyzing...' : 'Analyze Product'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Quick Demo Barcodes
          const Text(
            'Try these demo barcodes:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDemoChip('Organic Milk', '5901234123457'),
              _buildDemoChip('Plastic Bottle', '8901234567890'),
              _buildDemoChip('Eco Soap', '3456789012345'),
              _buildDemoChip('Electronics', '8888888888888'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoChip(String label, String barcode) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.qr_code, size: 16),
      onPressed: () {
        _barcodeController.text = barcode;
        _analyzeBarcode();
      },
    );
  }

  Future<void> _analyzeBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a barcode')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final aiService = ref.read(aiServiceProvider);
      final report = await aiService.analyzeBarcode(barcode);

      // Cache the report
      await HiveBoxes.cacheReport(report);

      // Update user scan count
      final user = HiveBoxes.currentUser.incrementScans();
      await HiveBoxes.updateUser(user);

      if (mounted) {
        context.push(
          AppRoutes.sustainabilityReport,
          extra: {'report': report.toJson()},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
