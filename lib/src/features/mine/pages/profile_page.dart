import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_img_editor/image_editor.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../providers/mine_provider.dart';
import '../models/mine_model.dart';
import '../services/mine_services.dart';
import '../../auth/models/auth_models.dart';
import '../../auth/services/auth_services.dart';
import '../../../core/enums/auth_enums.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  // 修改昵称
  final _nicknameController = TextEditingController();
  // 修改手机号
  final _phoneController = TextEditingController();
  // 修改邮箱
  final _emailController = TextEditingController();
  // 手机验证码
  final _smsCodeController = TextEditingController();
  // 短信倒计时
  Timer? _smsTimer;
  int _smsCountdown = 0;
  bool _isSendingSms = false;
  bool _isUpdatingPhone = false;
  // 图片选择器
  final _imagePicker = ImagePicker();
  // 裁剪后的头像路径
  ui.Image? _avatarImage;

  @override
  void dispose() {
    _cancelSmsTimer();
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _smsCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userInfo = ref.watch(userInfoDataProvider);
    final isLoading = ref.watch(userInfoLoadingProvider);
    final error = ref.watch(userInfoErrorProvider);

    // 显示加载状态
    if (isLoading && userInfo == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.w),
          borderRadius: BorderRadius.circular(24.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 2.w,
              offset: Offset(0, 1.w),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: const CommonIndicator(color: Colors.white),
        ),
      );
    }

    // 显示错误状态
    if (error != null && userInfo == null) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2.w),
          borderRadius: BorderRadius.circular(24.w),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 2.w,
              offset: Offset(0, 1.w),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48.w, color: Colors.red),
              SizedBox(height: 16.h),
              Text(
                '加载失败',
                style: TextStyle(fontSize: 16.sp, color: Colors.red),
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            CommonAppBar(
              title: l10n.profile,
              backgroundColor: Colors.transparent,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  _buildRowItem(
                    title: l10n.avatar,
                    value: userInfo?.avatar ?? '',
                    uiImage: _avatarImage,
                    isImage: true,
                    onTap: _pickImage,
                  ),
                  _buildRowItem(
                    title: l10n.nickname,
                    value: userInfo?.nickname ?? '',
                    onTap: () => _modifyNickname(userInfo?.nickname ?? ''),
                  ),
                  _buildRowItem(
                    title: l10n.phone,
                    value: userInfo?.mobile ?? '',
                    onTap: () => _modifyPhone(userInfo?.mobile ?? ''),
                  ),
                  _buildRowItem(
                    title: l10n.email,
                    value: userInfo?.email ?? '',
                    onTap: () => _modifyEmail(userInfo?.email ?? ''),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowItem({
    bool? isImage = false,
    bool? isArrow = true,
    ui.Image? uiImage,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Row(
              children: [
                if (isImage != null && isImage)
                  uiImage != null
                      ? RawImage(image: uiImage, width: 48.w, height: 48.h)
                      : CommonImage(
                        imagePath:
                            value.isNotEmpty
                                ? value
                                : "assets/images/avatar.png",
                        width: 48.w,
                        height: 48.h,
                        borderRadius: 24.w,
                      )
                else
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (isArrow != null && isArrow) ...[
                  CommonSpacing.width(8.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.w,
                    color: Colors.grey.shade600,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;

    // 显示选择菜单
    final result = await Pop.sheet<String>(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12.r),
        topRight: Radius.circular(12.r),
      ),
      childBuilder:
          (dismiss) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 相机选项
              _buildImageSourceOption(
                title: l10n.camera,
                onTap: () => dismiss('camera'),
              ),
              CommonSpacing.medium,
              Container(color: Colors.grey.shade200, height: 0.5.h),
              CommonSpacing.medium,
              // 相册选项
              _buildImageSourceOption(
                title: l10n.gallery,
                onTap: () => dismiss('gallery'),
              ),
              CommonSpacing.medium,
              Container(color: Colors.grey.shade200, height: 4.h),
              CommonSpacing.medium,
              // 取消按钮
              _buildImageSourceOption(
                title: l10n.btnCancel,
                onTap: () => dismiss(null),
                textColor: Colors.grey.shade600,
              ),
            ],
          ),
    );

    if (result == null) return;

    try {
      // 根据选择获取图片
      final ImageSource source = result == 'camera' ? ImageSource.camera : ImageSource.gallery;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null || !mounted) return;
      final popId = Pop.loading();
      final ui.Image image = await loadImageFromFile(pickedFile.path);
      Pop.hideLoading(popId);
      if (!mounted) return;

      final ui.Image? editedImage = await Navigator.of(context).push<ui.Image?>(
        MaterialPageRoute(
          builder: (context) => ImageEditor(
            image: image,
            config: ImageEditorConfig(
              enableText: false,
              topToolbar: TopToolbarConfig(
                titleText: l10n.avatar,
                cancelText: l10n.btnCancel,
                confirmText: l10n.btnConfirm,
              ),
              compression: ImageCompressionConfig(
                scale: 0.1,
                enabled: true
              ),
            ),
          ),
        ),
      );

      if (!mounted || editedImage == null) return;

      final pid = Pop.loading();
      final bytes = await convertUiImageToBytes(editedImage);
      if (bytes == null) {
        return;
      }

      setState(() {
        _avatarImage = editedImage;
      });

      // 上传头像接口
      await _uploadAvatar(bytes , pid);

    } catch (e) {
      Logger.error('ProfilePage', '选择或裁剪图片失败: $e');
      if (mounted) {
        // 显示错误提示
        Pop.toast('选择图片失败，请重试', toastType: ToastType.error);
      }
    }
  }

  Future<void> _uploadAvatar(Uint8List bytes, String popId) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final avatarUrl = await MineServices().uploadAvatar(
        bytes,
        fileName: 'avatar_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      if (!mounted) return;
      await _updateUserInfo(
        newAvatar: avatarUrl,
        showLoading: false,
        showSuccessToast: false,
      );
      if (!mounted) return;
      Pop.toast(l10n.avatarUploadSuccess, toastType: ToastType.success);
      Logger.info('ProfilePage', '头像上传成功');
    } catch (e) {
      Logger.error('ProfilePage', '上传头像失败: $e');
      if (mounted) {
        Pop.toast(l10n.avatarUploadFailed, toastType: ToastType.error);
      }
    } finally {
      Pop.hideLoading(popId);
    }
  }

  Widget _buildImageSourceOption({
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: textColor ?? Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _modifyNickname(String currentNickname) async {
    final l10n = AppLocalizations.of(context)!;
    _nicknameController
      ..text = currentNickname
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: _nicknameController.text.length),
      );
    final result = await _showTextInputSheet(
      title: l10n.modifyNickname,
      controller: _nicknameController,
      hintText: currentNickname,
      keyboardType: TextInputType.text,
      tips: [
        Text(
          l10n.modifyNicknameTips1,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14.sp,
          ),
        ),
        CommonSpacing.medium,
        Text(
          l10n.modifyNicknameTips2,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14.sp,
          ),
        ),
        CommonSpacing.medium,
        Text(
          l10n.modifyNicknameTips3,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
    if (result == null) return;
    final trimmed = result.trim();
    if (trimmed.isEmpty) {
      Pop.toast(l10n.modifyNicknameEmpty, toastType: ToastType.error);
      return;
    }
    if (trimmed == currentNickname) {
      Pop.toast(l10n.modifyNoChange, toastType: ToastType.warn);
      return;
    }
    await _updateUserInfo(newNickname: trimmed);
  }

  Future<void> _modifyEmail(String currentEmail) async {
    final l10n = AppLocalizations.of(context)!;
    _emailController
      ..text = currentEmail
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: _emailController.text.length),
      );
    final result = await _showTextInputSheet(
      title: l10n.modifyEmail,
      controller: _emailController,
      hintText: currentEmail,
      keyboardType: TextInputType.emailAddress,
    );
    if (result == null) return;
    final trimmed = result.trim();
    if (trimmed.isEmpty) {
      Pop.toast(l10n.modifyEmailEmpty, toastType: ToastType.error);
      return;
    }
    final emailReg = RegExp(r'^[\w\-.]+@[\w-]+(\.[\w-]+)+$');
    if (!emailReg.hasMatch(trimmed)) {
      Pop.toast(l10n.modifyEmailInvalid, toastType: ToastType.error);
      return;
    }
    if (trimmed == currentEmail) {
      Pop.toast(l10n.modifyNoChange, toastType: ToastType.warn);
      return;
    }
    await _updateUserInfo(newEmail: trimmed);
  }

  Future<void> _modifyPhone(String currentMobile) async {
    final l10n = AppLocalizations.of(context)!;
    _phoneController
      ..text = currentMobile
      ..selection = TextSelection.fromPosition(
        TextPosition(offset: _phoneController.text.length),
      );
    _smsCodeController.clear();
    _resetPhoneState();
    await Pop.sheet<bool>(
      title: l10n.modifyPhone,
      childBuilder: (dismiss) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> handleSendSms() async {
              final phone = _phoneController.text.trim();
              if (phone.isEmpty) {
                Pop.toast(l10n.modifyPhoneEmpty, toastType: ToastType.error);
                return;
              }
              if (_isSendingSms || _smsCountdown > 0) return;
              setModalState(() {
                _isSendingSms = true;
              });
              try {
                final params = AppAuthSmsSendParams(
                  mobile: phone,
                  scene: SmsSceneEnum.modifyPhone,
                  userPlatformType: UserPlatformTypeEnum.normal,
                );
                await AuthServices().sendSms(params);
                Pop.toast(l10n.smsSendSuccess, toastType: ToastType.success);
                _startSmsCountdown(setModalState);
              } catch (e) {
                Logger.error('ProfilePage', '发送验证码失败: $e');
                Pop.toast(l10n.smsSendFailed, toastType: ToastType.error);
              } finally {
                setModalState(() {
                  _isSendingSms = false;
                });
              }
            }

            Future<void> handleSubmit() async {
              final phone = _phoneController.text.trim();
              final code = _smsCodeController.text.trim();
              if (phone.isEmpty) {
                Pop.toast(l10n.modifyPhoneEmpty, toastType: ToastType.error);
                return;
              }
              if (code.isEmpty) {
                Pop.toast(l10n.modifyPhoneCodeEmpty, toastType: ToastType.error);
                return;
              }
              if (_isUpdatingPhone) return;
              setModalState(() {
                _isUpdatingPhone = true;
              });
              final popId = Pop.loading();
              try {
                await AuthServices().updatePhone(
                  AppAuthUpdatePhoneParams(
                    code: code,
                    mobile: phone,
                  ),
                );
                await ref.read(userInfoProvider.notifier).refresh();
                Pop.toast(l10n.modifySuccess, toastType: ToastType.success);
                dismiss(true);
              } catch (e) {
                Logger.error('ProfilePage', '修改手机号失败: $e');
                Pop.toast(l10n.modifyPhoneFailed, toastType: ToastType.error);
              } finally {
                Pop.hideLoading(popId);
                setModalState(() {
                  _isUpdatingPhone = false;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonSpacing.standard,
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: l10n.modifyPhoneNew,
                      hintText: currentMobile,
                    ),
                  ),
                  CommonSpacing.medium,
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _smsCodeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: l10n.modifyPhoneCodeLabel,
                            hintText: l10n.modifyPhoneCodeHint,
                          ),
                        ),
                      ),
                      CommonSpacing.width(12.w),
                      GestureDetector(
                        onTap: handleSendSms,
                        child: Container(
                          decoration: BoxDecoration(
                            color: (_smsCountdown > 0 || _isSendingSms)
                                ? Colors.grey.shade300
                                : AppTheme.primaryOrange,
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                          child: Text(
                            _smsCountdown > 0
                                ? l10n.modifyPhoneResend(_smsCountdown)
                                : l10n.modifyPhoneSendCode,
                            style: TextStyle(
                              color: (_smsCountdown > 0 || _isSendingSms)
                                  ? Colors.grey.shade600
                                  : Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  CommonSpacing.huge,
                  Center(
                    child: GestureDetector(
                      onTap: handleSubmit,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 48.w,
                          vertical: 12.h,
                        ),
                        child: Text(
                          _isUpdatingPhone ? l10n.btnSaving : l10n.btnSave,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  CommonSpacing.large,
                ],
              ),
            );
          },
        );
      },
    );
    _resetPhoneState();
  }

  Future<String?> _showTextInputSheet({
    required String title,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    List<Widget>? tips,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Pop.sheet<String>(
      title: title,
      childBuilder: (dismiss) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonSpacing.standard,
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hintText,
              ),
              autofocus: true,
            ),
            CommonSpacing.large,
            if (tips != null) ...[
              ...tips,
              CommonSpacing.medium,
            ],
            CommonSpacing.huge,
            Center(
              child: GestureDetector(
                onTap: () => dismiss(controller.text),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryOrange,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 48.w,
                    vertical: 12.h,
                  ),
                  child: Text(
                    l10n.btnSave,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            CommonSpacing.large,
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserInfo({
    String? newNickname,
    String? newEmail,
    String? newAvatar,
    bool showLoading = true,
    bool showSuccessToast = true,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final userInfo = ref.read(userInfoDataProvider);
    if (userInfo == null) {
      Pop.toast(l10n.modifyUserInfoMissing, toastType: ToastType.error);
      return;
    }
    String? popId;
    if (showLoading) {
      popId = Pop.loading();
    }
    try {
      await MineServices().updateUserInfo(
        UpdateUserInfoParams(
          avatar: newAvatar ?? userInfo.avatar ?? '',
          nickname: newNickname ?? userInfo.nickname,
          email: newEmail ?? userInfo.email,
        ),
      );
      await ref.read(userInfoProvider.notifier).refresh();
      if (showSuccessToast) {
        Pop.toast(l10n.modifySuccess, toastType: ToastType.success);
      }
    } catch (e) {
      Logger.error('ProfilePage', '更新用户信息失败: $e');
      Pop.toast(l10n.modifyFailed, toastType: ToastType.error);
    } finally {
      if (popId != null) {
        Pop.hideLoading(popId);
      }
    }
  }

  void _startSmsCountdown(StateSetter setModalState) {
    _smsCountdown = 60;
    setModalState(() {});
    _smsTimer?.cancel();
    _smsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_smsCountdown <= 1) {
        _cancelSmsTimer();
        setModalState(() {
          _smsCountdown = 0;
        });
      } else {
        setModalState(() {
          _smsCountdown -= 1;
        });
      }
    });
  }

  void _cancelSmsTimer() {
    _smsTimer?.cancel();
    _smsTimer = null;
  }

  void _resetPhoneState() {
    _cancelSmsTimer();
    _smsCountdown = 0;
    _isSendingSms = false;
    _isUpdatingPhone = false;
    _smsCodeController.clear();
  }
}
