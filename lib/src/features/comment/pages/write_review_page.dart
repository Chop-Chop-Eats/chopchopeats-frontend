import 'dart:io';

import 'package:chop_user/src/core/network/api_exception.dart';
import 'package:chop_user/src/core/utils/logger/logger.dart';
import 'package:chop_user/src/core/utils/pop/toast.dart';
import 'package:chop_user/src/core/widgets/common_image.dart';
import 'package:chop_user/src/features/comment/models/comment_model.dart';
import 'package:chop_user/src/features/comment/services/comment_service.dart';
import 'package:chop_user/src/features/order/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chop_user/src/core/l10n/app_localizations.dart';

class WriteReviewPage extends StatefulWidget {
  final dynamic order; // Accept both AppTradeOrderPageRespVO and AppTradeOrderDetailRespVO

  const WriteReviewPage({super.key, required this.order});

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 5;
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedImages.length >= 4) {
      Toast.show(l10n.commentMaxImages);
      return;
    }

    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage(
        limit: 4 - _selectedImages.length,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
        });
      }
    } catch (e) {
      Logger.error('WriteReviewPage', 'Pick image failed: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context)!;

    if (_rating == 0) {
      Toast.show(l10n.commentSelectRating);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      List<String> imageUrls = [];
      // Upload images first
      for (var image in _selectedImages) {
        final bytes = await image.readAsBytes();
        final url = await CommentService.uploadImage(bytes);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      final req = AppMerchantShopCommentCreateReqVO(
        shopId: widget.order.shopId ?? '',
        orderId: widget.order.orderNo ?? '', // Assuming orderNo is orderId
        comment: _commentController.text,
        rate: _rating,
        image: imageUrls.isNotEmpty ? imageUrls : null,
      );

      await CommentService.createComment(req);

      if (mounted) {
        Toast.show(l10n.commentSuccess);
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      Logger.error('WriteReviewPage', 'Submit review failed: $e');
      if (mounted) {
        if (e is ApiException) {
          Toast.show(e.message);
        } else {
          Toast.show(l10n.commentFailed);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          l10n.commentTitle,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.commentExperienceTitle,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.commentExperienceSubtitle,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
            SizedBox(height: 24.h),
            _buildShopCard(),
            SizedBox(height: 32.h),
            _buildRatingBar(),
            SizedBox(height: 32.h),
            _buildCommentArea(l10n),
            SizedBox(height: 32.h),
            _buildSubmitButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildShopCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.order.shopName ?? '',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${widget.order.categoryName ?? ''} • ${widget.order.englishCategoryName ?? ''}',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 60.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.order.items?.length ?? 0,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final item = widget.order.items![index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    color: Colors.grey[100],
                    child: CommonImage(
                      imagePath: item.imageThumbnail ?? '',
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Icon(
              index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
              color: const Color(0xFFFFB800), // Star color from image
              size: 40.sp,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCommentArea(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.commentShareExperienceHint,
              hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(fontSize: 14.sp, color: Colors.black),
          ),
          SizedBox(height: 16.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: [
              ..._selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final file = entry.value;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        File(file.path),
                        width: 80.w,
                        height: 80.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
              if (_selectedImages.length < 4)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 24.sp,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          l10n.commentUploadImages,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF5722),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 0,
        ),
        child:
            _isSubmitting
                ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(
                  l10n.commentSubmit,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }
}
