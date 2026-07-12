import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sudan_goods/contact/controllers/contact_controller.dart';
import 'package:sudan_goods/authentication/user/user_provider.dart';
import 'package:sudan_goods/theme/app_theme.dart';
import 'package:sudan_goods/theme/design_tokens.dart';
import 'package:sudan_goods/l10n/app_localizations.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  String _selectedSubject = 'general';
  int _charCount = 0;

  static const int _maxChars = 500;
  static const int _minChars = 10;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() => _charCount = _messageController.text.length);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final contact = Provider.of<ContactController>(context, listen: false);
    await contact.submit(
      uid: userProvider.currentUser.uid,
      email: userProvider.currentUser.email,
      subject: _selectedSubject,
      message: _messageController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          l10n.contactUs,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Consumer<ContactController>(
          builder: (context, contact, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder:
                  (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
              child:
                  contact.isSuccess
                      ? _SuccessCard(
                        key: const ValueKey('success'),
                        onReset: () => contact.reset(),
                      )
                      : _FormBody(
                        key: const ValueKey('form'),
                        formKey: _formKey,
                        messageController: _messageController,
                        charCount: _charCount,
                        maxChars: _maxChars,
                        minChars: _minChars,
                        selectedSubject: _selectedSubject,
                        onSubjectChanged:
                            (v) => setState(() => _selectedSubject = v),
                        onSubmit: () => _submit(l10n),
                        isSending: contact.isSending,
                        isError: contact.isError,
                      ),
            );
          },
        ),
      ),
    );
  }
}

// ── Form body ──────────────────────────────────────────────────────────────────

class _FormBody extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController messageController;
  final int charCount;
  final int maxChars;
  final int minChars;
  final String selectedSubject;
  final ValueChanged<String> onSubjectChanged;
  final VoidCallback onSubmit;
  final bool isSending;
  final bool isError;

  const _FormBody({
    super.key,
    required this.formKey,
    required this.messageController,
    required this.charCount,
    required this.maxChars,
    required this.minChars,
    required this.selectedSubject,
    required this.onSubjectChanged,
    required this.onSubmit,
    required this.isSending,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final email =
        userProvider.isUserLoaded ? (userProvider.currentUser.email) : '';
    final isNearLimit = charCount >= maxChars - 50;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.space20,
        DesignTokens.space24,
        DesignTokens.space20,
        DesignTokens.space40,
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Page header ───────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.mail_outline_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: DesignTokens.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.contactFormTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.contactFormSubtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space24),

            // ── Error banner ─────────────────────────────────────────────
            if (isError) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space16,
                  vertical: DesignTokens.space12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusMedium,
                  ),
                  border: Border.all(color: Colors.red.withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: DesignTokens.space8),
                    Expanded(
                      child: Text(
                        l10n.contactFormError,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DesignTokens.space16),
            ],

            // ── Form card ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(DesignTokens.space20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Email field
                  _FieldLabel(label: l10n.contactFormEmailLabel),
                  const SizedBox(height: DesignTokens.space8),
                  TextFormField(
                    initialValue: email,
                    readOnly: true,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      suffixIcon: Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: Colors.black26,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF7F8FA),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.space16,
                        vertical: DesignTokens.space12,
                      ),
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space20),

                  // Subject
                  _FieldLabel(label: l10n.contactFormSubjectLabel),
                  const SizedBox(height: DesignTokens.space12),
                  _SubjectChips(
                    selected: selectedSubject,
                    onChanged: onSubjectChanged,
                    subjects: [
                      _SubjectItem(
                        'general',
                        l10n.subjectGeneral,
                        Icons.chat_bubble_outline_rounded,
                      ),
                      _SubjectItem(
                        'order_issue',
                        l10n.subjectOrderIssue,
                        Icons.shopping_bag_outlined,
                      ),
                      _SubjectItem(
                        'feedback',
                        l10n.subjectFeedback,
                        Icons.thumb_up_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.space20),

                  // Message field
                  _FieldLabel(label: l10n.contactFormMessageLabel),
                  const SizedBox(height: DesignTokens.space8),
                  TextFormField(
                    controller: messageController,
                    maxLines: 6,
                    maxLength: maxChars,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    buildCounter:
                        (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => Text(
                          l10n.contactFormCharCount(currentLength),
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isNearLimit
                                    ? Colors.red.shade600
                                    : Colors.black38,
                            fontWeight:
                                isNearLimit
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                          ),
                        ),
                    decoration: InputDecoration(
                      hintText: l10n.contactFormMessageHint,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black26,
                      ),
                      alignLabelWithHint: true,
                      contentPadding: const EdgeInsets.all(
                        DesignTokens.space16,
                      ),
                    ),
                    validator: (v) {
                      final trimmed = v?.trim() ?? '';
                      if (trimmed.isEmpty) {
                        return l10n.contactFormValidationEmpty;
                      }
                      if (trimmed.length < minChars) {
                        return l10n.contactFormValidationTooShort;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space24),

            // ── CTA ──────────────────────────────────────────────────────
            _GradientButton(
              label: l10n.contactFormSendButton,
              isLoading: isSending,
              onTap: isSending ? null : onSubmit,
            ),
            const SizedBox(height: DesignTokens.space12),
            Text(
              l10n.contactFormSubtitle,
              style: const TextStyle(fontSize: 11, color: Colors.black38),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Success card ───────────────────────────────────────────────────────────────

class _SuccessCard extends StatelessWidget {
  final VoidCallback onReset;
  const _SuccessCard({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Green check icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEBFAF0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF22C55E),
                size: 44,
              ),
            ),
            const SizedBox(height: DesignTokens.space24),
            Text(
              l10n.contactFormSuccessTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space12),
            Text(
              l10n.contactFormSuccessSubtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black45,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignTokens.space32),
            SizedBox(
              width: double.infinity,
              child: _GradientButton(
                label: l10n.contactFormSendAnother,
                isLoading: false,
                onTap: onReset,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subject chips ──────────────────────────────────────────────────────────────

class _SubjectItem {
  final String value;
  final String label;
  final IconData icon;
  const _SubjectItem(this.value, this.label, this.icon);
}

class _SubjectChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final List<_SubjectItem> subjects;

  const _SubjectChips({
    required this.selected,
    required this.onChanged,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: DesignTokens.space8,
      runSpacing: DesignTokens.space8,
      children:
          subjects.map((s) {
            final isSelected = s.value == selected;
            return GestureDetector(
              onTap: () => onChanged(s.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space12,
                  vertical: DesignTokens.space8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.black12,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : DesignTokens.shadowSmall,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      s.icon,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      s.label,
                      style: AppTypography.small.copyWith(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

// ── Small helpers ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTypography.small.copyWith(
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          onTap: onTap,
          child: Center(
            child:
                isLoading
                    ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                    : Text(
                      label,
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
