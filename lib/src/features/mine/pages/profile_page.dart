import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_img_editor/image_editor.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_image.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../providers/mine_provider.dart';

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
  // 图片选择器
  final _imagePicker = ImagePicker();
  // 裁剪后的头像路径
  String _avatarImage = '';
  ui.Image? _avatarImage2;

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
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
                    value: _avatarImage.isNotEmpty
                        ? _avatarImage
                        : userInfo?.avatar ?? '',
                    uiImage: _avatarImage2,
                    isImage: true,
                    onTap: _pickImage,
                  ),
                  _buildRowItem(
                    title: l10n.nickname,
                    value: userInfo?.nickname ?? '',
                    onTap:
                        () =>
                            _modifyNickname(nickname: userInfo?.nickname ?? ''),
                  ),
                  _buildRowItem(
                    title: l10n.phone,
                    value: userInfo?.mobile ?? '',
                    onTap:
                        () => _modifyNickname(
                          isNickname: false,
                          mobile: userInfo?.mobile ?? '',
                        ),
                  ),
                  _buildRowItem(
                    title: l10n.email,
                    value: userInfo?.email ?? '',
                    isArrow: false,
                    onTap: () {},
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
                    ? RawImage(image: uiImage, width: 48.w, height: 48.h,)
                    : CommonImage(
                        imagePath:
                            value.isNotEmpty ? value : "assets/images/avatar.png",
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
      final ImageSource source =
          result == 'camera' ? ImageSource.camera : ImageSource.gallery;
      
  

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile == null || !mounted) return;
      final popId2 = Pop.loading();
      final ui.Image image = await loadImageFromFile(pickedFile.path);
      Pop.hideLoading(popId2);
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
            ),
          ),
        ),
      );



      if (!mounted || editedImage == null) return;

      setState(() {
        _avatarImage2 = editedImage;
      });
      // final popId = Pop.loading();
      // final savedPath = await _saveEditedImage(editedImage);
      // if (savedPath == null) {
      //   Logger.warn('ProfilePage', '保存裁剪图片失败');
      //   return;
      // }

      // if (!mounted) return;

      // setState(() {
      //   _avatarImage = savedPath;
      // });
      // Pop.hideLoading(popId);
      // Logger.info('ProfilePage', '头像裁剪完成: $savedPath');

      // TODO: 调用上传图片接口
      // await _uploadAvatar(savedPath);
    } catch (e) {
      Logger.error('ProfilePage', '选择或裁剪图片失败: $e');
      if (mounted) {
        // 显示错误提示
        Pop.toast('选择图片失败，请重试', toastType: ToastType.error);
      }
    }
  }

  Future<String?> _saveEditedImage(ui.Image image) async {
    final bytes = await convertUiImageToBytes(image);
    if (bytes == null) {
      return null;
    }

    final directory = await getTemporaryDirectory();
    final file = File(
      '${directory.path}/image_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Widget _buildImageSourceOption({
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            color: textColor ?? Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 修改昵称
  Future<void> _modifyNickname({
    bool? isNickname = true,
    String? nickname,
    String? mobile,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await Pop.sheet<String>(
      title:
          isNickname != null && isNickname
              ? l10n.modifyNickname
              : l10n.modifyPhone,
      childBuilder:
          (dismiss) => Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonSpacing.standard,
                TextField(
                  keyboardType:
                      isNickname != null && isNickname
                          ? TextInputType.text
                          : TextInputType.phone,
                  controller:
                      isNickname != null && isNickname
                          ? _nicknameController
                          : _phoneController,
                  decoration: InputDecoration(
                    hintText:
                        isNickname != null && isNickname
                            ? nickname
                            : mobile ?? '',
                  ),
                  onChanged:
                      (value) =>
                          isNickname != null && isNickname
                              ? _nicknameController.text = value
                              : _phoneController.text = value,
                ),
                Divider(color: Colors.grey.shade100, height: 0.5.h),
                CommonSpacing.large,
                if (isNickname != null && isNickname) ...[
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
                  CommonSpacing.medium,
                ] else ...[
                  Text(
                    "验证码区域",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14.sp,
                    ),
                  ),
                  CommonSpacing.medium,
                ],
                CommonSpacing.huge,
                Center(
                  child: GestureDetector(
                    onTap: () {
                      dismiss(_nicknameController.text);
                    },
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
              ],
            ),
          ),
    );
    if (result != null) {
      Logger.info('ProfilePage', 'modifyNickname: $result');
    }
  }

  // 修改手机号
  Future<void> _modifyPhone() async {
    Logger.info('ProfilePage', 'modifyPhone');
  }
}
