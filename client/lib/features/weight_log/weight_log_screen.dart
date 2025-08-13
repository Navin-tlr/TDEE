import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weight_log_provider.dart';

class WeightLogScreen extends ConsumerWidget {
  const WeightLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    void submitLog() async {
      if (formKey.currentState!.validate()) {
        try {
          await ref.read(weightLogServiceProvider).logWeight(
                weightKg: double.parse(weightController.text),
              );
          Navigator.of(context).pop(); // Go back to dashboard on success
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to log weight: $e")),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Weight'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: weightController,
                decoration: const InputDecoration(
                  labelText: 'Current Weight (kg)',
                  hintText: 'e.g., 80.5',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: submitLog,
                child: const Text('Log Weight'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}