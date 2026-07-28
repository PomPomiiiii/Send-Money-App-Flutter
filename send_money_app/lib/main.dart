import 'package:flutter/material.dart';

void main() => runApp(const SendMoneyApp());

class SendMoneyApp extends StatelessWidget {
  const SendMoneyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Send Money Demo',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const SendMoneyScreen(),
    );
  }
}

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  // --- Controllers read/write the text field values ---
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();

  // --- Local state ---
  double _balance = 5000;
  bool _isLoading = false;
  bool _touched = false; // becomes true once the user tries to submit
  String? _lastRecipient;
  double? _lastAmount;
  bool _showSuccess = false;

  @override
  void dispose() {
    // Always dispose controllers to avoid memory leaks — a common interview question
    _recipientController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // --- Validation logic, kept separate from the widget tree for clarity ---
  String? get _recipientError {
    if (!_touched) return null;
    if (_recipientController.text.trim().isEmpty) return 'Recipient is required';
    return null;
  }

  String? get _amountError {
    if (!_touched) return null;
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return 'Enter an amount greater than 0';
    if (amount > _balance) return 'Insufficient balance';
    return null;
  }

  bool get _isValid {
    final amount = double.tryParse(_amountController.text);
    return _recipientController.text.trim().isNotEmpty &&
        amount != null &&
        amount > 0 &&
        amount <= _balance;
  }

  // --- Simulated "send" action, standing in for a real POST /transfer call ---
  Future<void> _handleSend() async {
    setState(() => _touched = true);
    if (!_isValid) return;

    setState(() => _isLoading = true);

    // Simulate network latency — in a real app this would be:
    //   final result = await walletRepository.transfer(recipient, amount);
    await Future.delayed(const Duration(milliseconds: 900));

    final amount = double.parse(_amountController.text);

    setState(() {
      _balance -= amount;
      _lastRecipient = _recipientController.text;
      _lastAmount = amount;
      _isLoading = false;
      _showSuccess = true;
    });
  }

  void _reset() {
    setState(() {
      _recipientController.clear();
      _amountController.clear();
      _touched = false;
      _showSuccess = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _showSuccess ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // --- Balance card ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Available balance', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                '₱${_balance.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- Recipient field ---
        TextField(
          controller: _recipientController,
          onChanged: (_) => setState(() {}), // re-validate on every keystroke
          decoration: InputDecoration(
            labelText: 'Recipient',
            hintText: 'e.g. Juan Dela Cruz',
            errorText: _recipientError,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // --- Amount field ---
        TextField(
          controller: _amountController,
          onChanged: (_) => setState(() {}),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Amount (PHP)',
            hintText: '0.00',
            errorText: _amountError,
            border: const OutlineInputBorder(),
          ),
        ),

        const Spacer(),

        // --- Submit button, disabled while loading or invalid after touch ---
        FilledButton.icon(
          onPressed: _isLoading || (_touched && !_isValid) ? null : _handleSend,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send),
          label: Text(_isLoading ? 'Sending...' : 'Send Money'),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          const Text('Transfer successful', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Sent ₱${_lastAmount!.toStringAsFixed(2)} to $_lastRecipient'),
          const SizedBox(height: 8),
          Text('New balance: ₱${_balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          FilledButton(onPressed: _reset, child: const Text('Send another')),
        ],
      ),
    );
  }
}