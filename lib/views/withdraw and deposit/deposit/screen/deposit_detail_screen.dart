import 'dart:io';

import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/annotations.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/views/MyAccount/widgets/note_widget.dart';
import 'package:doin_fx/views/MyAccount/widgets/steps_widget.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/bloc/deposit_bloc.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/datamodel/doposit_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class DepositDetailScreen extends StatefulWidget {
  final DepositMethodConfig config;

  const DepositDetailScreen({super.key, required this.config});

  @override
  State<DepositDetailScreen> createState() => _DepositDetailScreenState();
}

class _DepositDetailScreenState extends State<DepositDetailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form field controllers
  late final TextEditingController _amountController;
  final TextEditingController _amountUsdCtrl = TextEditingController();
  late final TextEditingController _transactionIdController;
  late final TextEditingController _upiIdController;
  late final DepositBloc _depositBloc;
  late final ScrollController _scrollController;

  // static const double inrToUsdRate = 0.0112; // example rate

  File? _image;
  String? _errorMessage;

  void _calculateUsd() {
    if (widget.config.type != DepositMethodType.upi) {
      _amountUsdCtrl.text = _amountController.text;
      return;
    }

    final state = _depositBloc.state;

    if (state is! DepositLoaded) {
      _amountUsdCtrl.text = '0.00';
      return;
    }

    final text = _amountController.text;

    if (text.isEmpty) {
      _amountUsdCtrl.text = '0.00';
      return;
    }

    final inr = double.tryParse(text);
    if (inr == null) {
      _amountUsdCtrl.text = '0.00';
      return;
    }

    final minimumUsd = state.minimumValues.data.minimumDeposit;
    final minimumInr = state.minimumValues.data.inrValue;

    if (minimumInr == 0) {
      _amountUsdCtrl.text = '0.00';
      return;
    }

    // 🔥 Dynamic backend-based conversion
    final usd = inr / minimumInr;

    _amountUsdCtrl.text = usd.toStringAsFixed(2);
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _transactionIdController = TextEditingController();
    _upiIdController = TextEditingController();
    _depositBloc = DepositBloc();
    // update UI when form fields change so button enabled state refreshes
    _amountController.addListener(() => setState(() {}));
    _transactionIdController.addListener(() => setState(() {}));
    _upiIdController.addListener(() => setState(() {}));
    _amountController.addListener(_calculateUsd);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountUsdCtrl.dispose();
    _transactionIdController.dispose();
    _upiIdController.dispose();
    _depositBloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isDepositFormComplete() {
    final hasAmount = _amountController.text.isNotEmpty && double.tryParse(_amountController.text) != null;
    final hasTransactionId = _transactionIdController.text.isNotEmpty;
    final hasScreenshot = _image != null;

    // if (widget.config.type == DepositMethodType.upi) {
    //   hasUpiId = _upiIdController.text.isNotEmpty;
    // }

    return hasAmount && hasTransactionId && hasScreenshot;
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final img = File(file.path);
      setState(() => _image = img);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_image == null) {
      setState(() => _errorMessage = 'Please upload a payment screenshot');
      return;
    }

    if (_transactionIdController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter transaction ID');
      return;
    }

    if (_amountController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter amount');
      return;
    }

    setState(() => _errorMessage = null);

    final paymentType = widget.config.type == DepositMethodType.upi ? 'upi' : 'usdt';

    _depositBloc.add(
      OnSubmit(
        paymentMethod: paymentType,
        transactionId: _transactionIdController.text.trim(),
        enterAmount: _amountController.text.trim(),
        upiId: _upiIdController.text.isNotEmpty ? _upiIdController.text.trim() : null,
        paymentScreenshot: _image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    final String usd = 'assets/images/deposit/usd_symbol.png';

    return BlocProvider<DepositBloc>(
      create: (context) => _depositBloc..add(LoadInitialValues()),
      child: BlocConsumer<DepositBloc, DepositState>(
        listener: (context, state) {
          if (state is DepositSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.response.message), backgroundColor: Colors.green));
            // Navigate back after successful submission
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.pop(context);
            });
          } else if (state is DepositFailure) {
            setState(() => _errorMessage = state.message);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (BuildContext context, DepositState state) {
          double? minimumUsd;
          double? minimumInr;
          if (state is DepositLoaded) {
            minimumUsd = state.minimumValues.data.minimumDeposit;
            minimumInr = state.minimumValues.data.inrValue;
          }

          return Scaffold(
            appBar: AppBar(title: Text(config.title)),
            body: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Error message display
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(_errorMessage!, style: TextStyle(color: Colors.red.shade900)),
                            ),
                          ],
                        ),
                      ),
                    ),

                  /// Steps
                  StepsCard(config.steps),

                  NoteCard(config.note),

                  const SizedBox(height: 20),

                  /// QR / Address
                  Align(alignment: Alignment.center, child: _sectionTitle(config.title, fontSize: 30)),
                  // Use effectiveQrImage which checks API data first, then falls back to hardcoded
                  if (config.effectiveQrImage != null)
                    Center(
                      child: config.effectiveQrImage!.startsWith('http')
                          ? Image.network(
                              config.effectiveQrImage!,
                              height: 160,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.qr_code_2, size: 160, color: Colors.grey[400]);
                              },
                            )
                          : Image.asset(config.effectiveQrImage!, height: 160),
                    ),

                  // Use effectiveAddress which checks API data first, then falls back to hardcoded
                  if (config.effectiveAddress != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(config.addressLabel ?? 'Address : ', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        Expanded(child: SelectableText(config.effectiveAddress!, style: const TextStyle(height: 1.4))),
                      ],
                    ),
                  ],

                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        minimumTextResolver(config, minimumUsd ?? 0, minimumInr ?? 0),

                        style: const TextStyle(color: Color(0xFFB00000), fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Amount
                  ///
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _sectionTitle('Enter Amount in ${config.currency}'),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Amount is required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid amount';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(13),
                              child: Image.asset(config.symbol, width: 20, height: 20, fit: BoxFit.contain),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                            hintText: '0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        ///////////////////// Receive Amnt in USD
                        _sectionTitle('You Will Recive Amount in USD'),
                        TextField(
                          controller: _amountUsdCtrl,
                          keyboardType: TextInputType.number,
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(13),
                              child: Image.asset(usd, width: 20, height: 20, fit: BoxFit.contain),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                            hintText: '0',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade400),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          ),
                        ),

                        /// Transaction ID
                        if (config.requireTxnId) ...[
                          const SizedBox(height: 20),
                          _sectionTitle('Transaction ID'),
                          TextFormField(
                            controller: _transactionIdController,
                            textCapitalization: TextCapitalization.characters,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Transaction ID is required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Transaction ID / UTR',
                              hintText: 'Enter your transaction reference',
                              prefixIcon: const Icon(Icons.receipt_long),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                              ),
                              helperText: 'Required for payment verification',
                              helperStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                            ),
                          ),
                        ],

                        /// UPI ID (if UPI payment)
                        // if (widget.config.type == DepositMethodType.upi) ...[
                        //   const SizedBox(height: 20),
                        //   _sectionTitle('UPI ID'),
                        //   TextFormField(
                        //     controller: _upiIdController,
                        //     keyboardType: TextInputType.text,
                        //     decoration: InputDecoration(
                        //       labelText: 'UPI ID',
                        //       hintText: 'Enter your UPI ID (e.g., name@bank)',
                        //       prefixIcon: const Icon(Icons.person),
                        //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        //       enabledBorder: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(10),
                        //         borderSide: BorderSide(color: Colors.grey.shade400),
                        //       ),
                        //       focusedBorder: OutlineInputBorder(
                        //         borderRadius: BorderRadius.circular(10),
                        //         borderSide: const BorderSide(color: Color(0xFFFF9800), width: 2),
                        //       ),
                        //       contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        //     ),
                        //   ),
                        // ],
                      ],
                    ),
                  ),

                  /// Screenshot upload placeholder
                  if (config.requireScreenshot) ...[
                    const SizedBox(height: 20),
                    _sectionTitle('Upload Screenshot'),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _image == null
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.cloud_upload_outlined, size: 32),
                                    SizedBox(height: 8),
                                    Text('Tap to upload image'),
                                  ],
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  /// Deposit Button
                  BlocBuilder<DepositBloc, DepositState>(
                    builder: (context, state) {
                      final isLoading = state is DepositLoading;

                      // 🔹 Get minimum values from API (if loaded)
                      double? minimumInr;
                      double? minimumUsd;

                      if (state is DepositLoaded) {
                        minimumInr = state.minimumValues.data.inrValue;
                        minimumUsd = state.minimumValues.data.minimumDeposit;
                      }

                      // 🔹 Parse entered values
                      final enteredInr = double.tryParse(_amountController.text) ?? 0.0;

                      final enteredUsd = double.tryParse(_amountUsdCtrl.text) ?? 0.0;

                      bool isAmountTooLow = false;
                      String? minimumMessage;

                      // 🔹 UPI Minimum Check (INR restriction)
                      if (widget.config.type == DepositMethodType.upi && minimumUsd != null && minimumInr != null) {
                        final conversionRate = minimumInr; // 92
                        final minimumRequiredInr = minimumUsd * conversionRate;

                        if (enteredInr > 0 && enteredInr < minimumRequiredInr) {
                          isAmountTooLow = true;
                          minimumMessage = 'Minimum deposit is ₹${minimumRequiredInr.toStringAsFixed(0)}';
                        }
                      }

                      if (widget.config.type == DepositMethodType.usdtTrc20 && minimumUsd != null) {
                        if (enteredUsd > 0 && enteredUsd < minimumUsd) {
                          isAmountTooLow = true;
                          minimumMessage = 'Minimum deposit is \$${minimumUsd.toStringAsFixed(2)}';
                        }
                      }

                      if (widget.config.type == DepositMethodType.usdtErc20 && minimumUsd != null) {
                        if (enteredUsd > 0 && enteredUsd < minimumUsd) {
                          isAmountTooLow = true;
                          minimumMessage = 'Minimum deposit is \$${minimumUsd.toStringAsFixed(2)}';
                        }
                      }

                      if (widget.config.type == DepositMethodType.usdtBep20 && minimumUsd != null) {
                        if (enteredUsd > 0 && enteredUsd < minimumUsd) {
                          isAmountTooLow = true;
                          minimumMessage = 'Minimum deposit is \$${minimumUsd.toStringAsFixed(2)}';
                        }
                      }

                      // 🔹 USDT Minimum Check (USD restriction)
                      // if (widget.config.type == DepositMethodType.usdt && minimumUsd != null) {
                      //   if (enteredUsd > 0 && enteredUsd < minimumUsd) {
                      //     isAmountTooLow = true;
                      //     minimumMessage = 'Minimum deposit is \$${minimumUsd.toStringAsFixed(2)}';
                      //   }
                      // }

                      final isEnabled = _isDepositFormComplete() && !isLoading && !isAmountTooLow;

                      return Column(
                        children: [
                          if (isAmountTooLow)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                minimumMessage ?? '',
                                style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEnabled ? const Color(0xFFFF9800) : Colors.grey.shade400,
                                disabledBackgroundColor: Colors.grey.shade400,
                              ),
                              onPressed: isEnabled ? _submit : null,
                              child: isLoading
                                  ? AppLoaders.buttonLoader()
                                  : const Text('Deposit', style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );

          // return const Center(child: Text('Issue in Deposit'));
        },
      ),
    );
  }

  Widget _sectionTitle(String text, {double? fontSize}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize ?? 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

String minimumTextResolver(DepositMethodConfig config, double minimumUsd, double conversionRate) {
  if (config.type == DepositMethodType.upi) {
    final minimumInr = minimumUsd * conversionRate;

    return '${config.minDepositText} '
        // '\$${minimumUsd.toStringAsFixed(2)} '
        '₹${minimumInr.toStringAsFixed(0)}';
  }

  return '${config.minDepositText} \$${minimumUsd.toStringAsFixed(2)}';
}
