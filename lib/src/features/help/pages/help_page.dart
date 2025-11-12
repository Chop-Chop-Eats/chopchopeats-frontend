import 'package:chop_user/src/core/l10n/app_localizations.dart';
import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:chop_user/src/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_spacing.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  static const String _supportEmail = 'aaron@chopchopeats.org';
  static const String _supportPhone = '2015547433';

  void _toast(String message) {
    toast(message);
  }

  Future<void> _copyEmail(AppLocalizations l10n) async {
    await Clipboard.setData(const ClipboardData(text: _supportEmail));
    if (!mounted) return;
    _toast(l10n.helpEmailCopiedToast);
  }

  Future<void> _launchDialer(AppLocalizations l10n) async {
    final Uri dialUri = Uri(scheme: 'tel', path: _supportPhone);
    bool success = false;
    try {
      success = await launchUrl(
        dialUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      success = false;
    }
    if (!mounted) return;
    if (!success) {
      _toast(l10n.helpDialerLaunchFailedToast);
    }
  }

  Widget _buildContactTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 18.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 24.sp, color: AppTheme.primaryOrange),
                CommonSpacing.width(12.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CommonAppBar(title: l10n.help),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.helpShareFeedbackTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              CommonSpacing.small,
              Text(
                l10n.helpShareFeedbackDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              CommonSpacing.large,
              _buildContactTile(
                icon: Icons.email_outlined,
                label: l10n.helpSupportEmailLabel,
                value: _supportEmail,
                onTap: () => _copyEmail(l10n),
              ),
              CommonSpacing.small,
              _buildContactTile(
                icon: Icons.phone_android,
                label: l10n.helpSupportPhoneLabel,
                value: _supportPhone,
                onTap: () => _launchDialer(l10n),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
