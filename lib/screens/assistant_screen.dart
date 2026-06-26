import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cineflow_app/constants/app_colors.dart';
import 'package:cineflow_app/controllers/assistant_controller.dart';
import 'package:cineflow_app/widgets/turkish_text_field.dart';

class AssistantScreen extends GetView<AssistantController> {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inputCtrl = TextEditingController();
    final inputFocusNode = FocusNode();
    
    return GestureDetector(
      onTap: () => inputFocusNode.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.smart_toy),
              SizedBox(width: 8),
              Text('Film Asistanı'),
            ],
          ),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          actions: [
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                controller.clearMessages();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Welcome content always visible at top
                    _buildWelcomeContent(),
                    
                    // Chat messages if any
                    if (controller.messages.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Divider(color: AppColors.grey600),
                      const SizedBox(height: 16),
                      ...controller.messages.map((m) {
                        final isUser = m.role == 'user';
                        return Align(
                          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: isUser ? AppColors.primaryGradient : AppColors.cardGradient,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                if (!isUser)
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                              ],
                            ),
                            child: Text(
                              m.content,
                              style: TextStyle(color: isUser ? AppColors.onPrimary : AppColors.onCard),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                );
              }),
            ),
            _buildInputBar(inputCtrl, inputFocusNode),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  size: 40,
                  color: AppColors.onPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Film Asistanı',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onCard,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Size en uygun film ve dizi önerilerini sunuyorum!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onCard.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputBar(TextEditingController inputCtrl, FocusNode inputFocusNode) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TurkishTextField(
                controller: inputCtrl,
                focusNode: inputFocusNode,
                decoration: InputDecoration(
                  hintText: 'assistant_input_hint'.tr,
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (v) {
                  if (v.trim().isEmpty) return;
                  controller.handlePrompt(v.trim());
                  inputCtrl.clear();
                },
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => controller.isThinking.value
                ? const SizedBox(
                    width: 40,
                    height: 40,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final v = inputCtrl.text.trim();
                      if (v.isEmpty) return;
                      controller.handlePrompt(v);
                      inputCtrl.clear();
                    },
                  )),
          ],
        ),
      ),
    );
  }
}


