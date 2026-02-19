import 'dart:io';

import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/annotations.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/views/MyAccount/widgets/note_widget.dart';
import 'package:doin_fx/views/MyAccount/widgets/steps_widget.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/bloc/withdraw_bloc.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/datamodel/withdraw_model.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

@RoutePage()
class WithdrawScreen extends StatefulWidget {
  final WithdrawMethodConfig config;

  const WithdrawScreen({super.key, required this.config});

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form field controllers
  late final TextEditingController _amountController;
  final TextEditingController _amountUsdCtrl = TextEditingController();
  late final TextEditingController _transactionIdController;
  // late final TextEditingController _upiIdController;
  late final WithdrawBloc _withdrawBloc;
  late final ScrollController _scrollController;

  // static const double inrToUsdRate = 0.0112; // example rate

  File? _image;
  String? _errorMessage;

  void _calculateUsd() {
    if (widget.config.type == WithdrawMethodType.upi) {
      final text = _amountController.text; // ✅ INR input

      if (text.isEmpty) {
        _amountUsdCtrl.text = '0.00';
        return;
      }

      final inr = double.tryParse(text);
      if (inr == null) {
        _amountUsdCtrl.text = '0.00';
        return;
      }

      final usd = inr / 90;
      _amountUsdCtrl.text = usd.toStringAsFixed(2);
    } else {
      _amountUsdCtrl.text = _amountController.text;
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _transactionIdController = TextEditingController();
    _withdrawBloc = WithdrawBloc();
    // update UI when form fields change so button enabled state refreshes
    _amountController.addListener(() => setState(() {}));
    _transactionIdController.addListener(() => setState(() {}));
    _amountController.addListener(_calculateUsd);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountUsdCtrl.dispose();
    _transactionIdController.dispose();
    _withdrawBloc.close();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isWithdrawFormComplete({double? minimumUsd}) {
    final hasAmount =
        _amountController.text.isNotEmpty &&
        double.tryParse(_amountController.text) != null;
    final hasTransactionId = _transactionIdController.text.isNotEmpty;
    final hasScreenshot = _image != null;

    bool hasMinimumAmount = false;
    if (minimumUsd != null && minimumUsd > 0) {
      {
        final usdAmount = double.tryParse(_amountController.text) ?? 0.0;
        hasMinimumAmount = usdAmount >= minimumUsd;
      }
    }

    return hasAmount && hasTransactionId && hasScreenshot && hasMinimumAmount;
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      final img = File(file.path);
      setState(() => _image = img);
    }
  }

  void _submit({double? minimumUsd, double? minimumInr}) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_image == null) {
      setState(() {
        _errorMessage = 'Please upload a payment screenshot';
        _scrollToTop();
      });
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

    if (minimumUsd != null && minimumUsd > 0) {
      final usdAmount = double.tryParse(_amountController.text) ?? 0.0;
      if (usdAmount < minimumUsd) {
        setState(() {
          _errorMessage =
              'Minimum withdrawal amount is \$${minimumUsd.toStringAsFixed(2)} USD';
          _scrollToTop();
        });
        return;
      }
    }

    setState(() => _errorMessage = null);

    final paymentType = widget.config.type == WithdrawMethodType.upi
        ? 'upi'
        : 'usdt';

    _withdrawBloc.add(
      OnWithdraw(
        paymentMethod: paymentType,
        paymentAddress: _transactionIdController.text.trim(),
        requestedAmount: _amountController.text.trim(),
        // upiId: _upiIdController.text.isNotEmpty
        //     ? _upiIdController.text.trim()
        //     : null,
        paymentScreenshot: _image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return BlocProvider<WithdrawBloc>(
      create: (context) => _withdrawBloc..add(LoadInitialValues()),
      child: BlocListener<WithdrawBloc, WithdrawState>(
        listener: (context, state) {
          if (state is WithdrawSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.response.message),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate back after successful submission
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) Navigator.pop(context);
            });
          } else if (state is WithdrawFailure) {
            setState(() => _errorMessage = state.message);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
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
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                /// Steps
                StepsCard(
                  config.steps,
                  onClose: () {},
                  withDraw: isWithDraw(config.type),
                ),

                NoteCard(config.note),

                const SizedBox(height: 20),

                /// QR / Address / Bank Details
                // Align(
                //   alignment: Alignment.center,
                //   child: _sectionTitle(config.title, fontSize: 30),
                // ),

                // Handle bank transfer - show bank details
                // if (config.isBankTransfer) ...[
                //   const SizedBox(height: 16),
                //   Container(
                //     padding: const EdgeInsets.all(16),
                //     decoration: BoxDecoration(
                //       color: Colors.blue[50],
                //       borderRadius: BorderRadius.circular(12),
                //       border: Border.all(color: Colors.blue[200]!),
                //     ),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text(
                //           'Bank Details:',
                //           style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             color: Colors.blue[700],
                //             fontSize: 16,
                //           ),
                //         ),
                //         const SizedBox(height: 12),
                //         SelectableText(
                //           config.bankDetails,
                //           style: const TextStyle(
                //             fontSize: 14,
                //             height: 1.6,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ]
                // else 
                ...[
                  // Handle QR code for UPI/USDT
                  // if (config.effectiveQrImage != null)
                  //   Center(
                  //     child: config.effectiveQrImage!.startsWith('http')
                  //         ? Image.network(
                  //             config.effectiveQrImage!,
                  //             height: 160,
                  //             loadingBuilder: (context, child, loadingProgress) {
                  //               if (loadingProgress == null) return child;
                  //               return const Center(
                  //                 child: CircularProgressIndicator(),
                  //               );
                  //             },
                  //             errorBuilder: (context, error, stackTrace) {
                  //               return Icon(
                  //                 Icons.qr_code_2,
                  //                 size: 160,
                  //                 color: Colors.grey[400],
                  //               );
                  //             },
                  //           )
                  //         : Image.asset(config.effectiveQrImage!, height: 160),
                  //   ),

                  // if (config.effectiveAddress != null) ...[
                  //   const SizedBox(height: 12),
                  //   Row(
                  //     children: [
                  //       Text(
                  //         config.addressLabel ?? 'Address : ',
                  //         style: const TextStyle(fontWeight: FontWeight.w600),
                  //       ),
                  //       SelectableText(config.effectiveAddress!),
                  //     ],
                  //   ),
                  // ],
                ],

                BlocBuilder<WithdrawBloc, WithdrawState>(
                  builder: (context, state) {
                    String minimumText = config.minWithdrawText;
                    if (state is WithDrawLoaded) {
                      final minimumUsd =
                          state.minimumValues.data.minimumWithdrawal;
                      final inrValue = state.minimumValues.data.inrValue;
                      if (widget.config.type == WithdrawMethodType.upi &&
                          inrValue > 0) {
                        final minimumInr = minimumUsd * inrValue;
                        minimumText =
                            '${config.minWithdrawText}${minimumUsd.toStringAsFixed(0)} USD';
                      } else {
                        minimumText =
                            '${config.minWithdrawText}\$${minimumUsd.toStringAsFixed(2)} USD';
                      }
                    }
                    return Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          minimumText,
                          style: const TextStyle(
                            color: Color(0xFFB00000),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                /// Amount
                ///
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _sectionTitle('Enter Amount in USD'),
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
                            child: Image.asset(
                              'assets/images/deposit/usd_symbol.png',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade400),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF9800),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      ///////////////////// Receive Amnt in USD
                      // _sectionTitle('You Will Recive Amount in USD'),
                      // TextField(
                      //   controller: _amountUsdCtrl,
                      //   keyboardType: TextInputType.number,
                      //   readOnly: true,
                      //   decoration: InputDecoration(
                      //     prefixIcon: Padding(
                      //       padding: const EdgeInsets.all(13),
                      //       child: Image.asset(
                      //         usd,
                      //         width: 20,
                      //         height: 20,
                      //         fit: BoxFit.contain,
                      //       ),
                      //     ),
                      //     prefixIconConstraints: const BoxConstraints(
                      //       minWidth: 48,
                      //       minHeight: 48,
                      //     ),
                      //     hintText: '0',
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //       borderSide:
                      //       BorderSide(color: Colors.grey.shade400),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(10),
                      //       borderSide: const BorderSide(
                      //         color: Color(0xFFFF9800),
                      //         width: 2,
                      //       ),
                      //     ),
                      //     contentPadding: const EdgeInsets.symmetric(
                      //       vertical: 16,
                      //       horizontal: 12,
                      //     ),
                      //   ),
                      // ),

                      /// Transaction ID
                      if (config.requireTxnId) ...[
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: _sectionTitle(
                            'Enter Your ${resolveType(config.type)} address here',
                          ),
                        ),
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
                            // labelText: 'Transaction ID / UTR',
                            // hintText: 'Enter your transaction reference',
                            prefixIcon: const Icon(Icons.receipt_long),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Color(0xFFFF9800),
                                width: 2,
                              ),
                            ),
                            // helperText: 'Required for withdrawal verification',
                            helperStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],

                      /// UPI ID (if UPI payment)
                      // if (widget.config.type.toString().contains('UPI')) ...[
                      //   const SizedBox(height: 20),
                      //   _sectionTitle('UPI ID'),
                      //   TextFormField(
                      //     controller: _upiIdController,
                      //     keyboardType: TextInputType.text,
                      //     decoration: InputDecoration(
                      //       labelText: 'UPI ID',
                      //       hintText: 'Enter your UPI ID (e.g., name@bank)',
                      //       prefixIcon: const Icon(Icons.person),
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //       ),
                      //       enabledBorder: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //         borderSide: BorderSide(
                      //           color: Colors.grey.shade400,
                      //         ),
                      //       ),
                      //       focusedBorder: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //         borderSide: const BorderSide(
                      //           color: Color(0xFFFF9800),
                      //           width: 2,
                      //         ),
                      //       ),
                      //       contentPadding: const EdgeInsets.symmetric(
                      //         horizontal: 14,
                      //         vertical: 16,
                      //       ),
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
                BlocBuilder<WithdrawBloc, WithdrawState>(
                  builder: (context, state) {
                    final isLoading = state is WithdrawLoading;
                    double? minimumUsd;
                    double? minimumInr;
                    if (state is WithDrawLoaded) {
                      minimumUsd = state.minimumValues.data.minimumWithdrawal;
                      minimumInr = state.minimumValues.data.inrValue;
                    }
                    final isEnabled =
                        _isWithdrawFormComplete(minimumUsd: minimumUsd) &&
                        !isLoading;

                    String? minimumMessage;
                    if (minimumUsd != null && minimumUsd > 0) {
                      {
                        final usdAmount =
                            double.tryParse(_amountController.text) ?? 0.0;
                        if (usdAmount > 0 && usdAmount < minimumUsd) {
                          minimumMessage =
                              'Minimum withdrawal amount is \$${minimumUsd.toStringAsFixed(2)} USD';
                        }
                      }
                    }

                    return Column(
                      children: [
                        if (minimumMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              minimumMessage,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isEnabled
                                  ? const Color(0xFFFF9800)
                                  : Colors.grey.shade400,
                              disabledBackgroundColor: Colors.grey.shade400,
                            ),
                            onPressed: isEnabled
                                ? () => _submit(
                                    minimumUsd: minimumUsd,
                                    minimumInr: minimumInr,
                                  )
                                : null,
                            child: isLoading
                                ? AppLoaders.buttonLoader()
                                : const Text(
                                    'WithDraw',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
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
 