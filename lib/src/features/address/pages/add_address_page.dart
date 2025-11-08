import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_indicator.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/address_models.dart';
import '../providers/address_provider.dart';
import '../services/address_services.dart';

class AddAddressPage extends ConsumerStatefulWidget {
  const AddAddressPage({super.key});

  @override
  ConsumerState<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends ConsumerState<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _detailController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _stateController = TextEditingController();
  bool _isDefault = false;
  StateItem? _selectedState;

  @override
  void initState() {
    super.initState();
    _streetController.text = '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stateListProvider.notifier).loadStates();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (_streetController.text.isEmpty) {
      _streetController.text = l10n.addressStreetFixedValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _detailController.dispose();
    _zipCodeController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final street = _streetController.text.trim();
    final detail = _detailController.text.trim();
    final zipCode = _zipCodeController.text.trim();
    final state = _selectedState;

    if (name.isEmpty || phone.isEmpty || street.isEmpty || zipCode.isEmpty) {
      Pop.toast(l10n.addressFormIncomplete, toastType: ToastType.warn);
      return;
    }

    if (state == null) {
      Pop.toast(l10n.addressSelectStateHint, toastType: ToastType.warn);
      return;
    }

    final loadingId = Pop.loading();

    try {
      final params = AddressItem(
        address: street,
        defaultStatus: _isDefault,
        detailAddress: detail.isEmpty ? null : detail,
        id: 0,
        mobile: phone,
        name: name,
        state: state.state,
        zipCode: zipCode,
      );

      await AddressServices.createUserAddress(params);
      await ref.read(addressListProvider.notifier).loadAddresses();
      Pop.hideLoading(loadingId);
      Pop.toast(l10n.addressCreateSuccess, toastType: ToastType.success);
      if (mounted) {
        Navigate.pop(context);
      }
    } catch (e) {
      Pop.hideLoading(loadingId);
      Logger.error("AddAddressPage", "Error: $e");
      Pop.toast(e.toString(), toastType: ToastType.error);
    }
  }

  Future<void> _selectState() async {
    final l10n = AppLocalizations.of(context)!;
    var stateState = ref.read(stateListProvider);

    if (stateState.states.isEmpty && !stateState.isLoading) {
      final loadingId = Pop.loading();
      await ref.read(stateListProvider.notifier).loadStates();
      Pop.hideLoading(loadingId);
      stateState = ref.read(stateListProvider);
    }

    if (stateState.error != null && stateState.states.isEmpty) {
      Pop.toast(stateState.error!, toastType: ToastType.error);
      return;
    }

    if (stateState.states.isEmpty) {
      Pop.toast(l10n.addressSelectStateEmpty, toastType: ToastType.none);
      return;
    }

    final result = await Pop.sheet<StateItem>(
      title: l10n.addressSelectStateSheetTitle,
      childBuilder: (dismiss) {
        final currentState = ref.read(stateListProvider);
        if (currentState.isLoading && currentState.states.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            child: const Center(child: CommonIndicator()),
          );
        }

        if (currentState.error != null && currentState.states.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentState.error!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                CommonSpacing.medium,
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final loading = Pop.loading();
                      await ref.read(stateListProvider.notifier).loadStates();
                      Pop.hideLoading(loading);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      l10n.tryAgainText,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final states = currentState.states;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 360.h),
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (_, index) {
              final item = states[index];
              return ListTile(
                title: Text(
                  item.state,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => dismiss(item),
              );
            },
            separatorBuilder:
                (_, __) => Divider(height: 1.h, color: Colors.grey.shade200),
            itemCount: states.length,
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedState = result;
        _stateController.text = result.state;
      });
    }
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(16.r),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen<StateListState>(stateListProvider, (previous, next) {
      if (!mounted) return;
      if (next.error != null && next.states.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Logger.error("AddAddressPage", "Error: ${next.error!}");
            Pop.toast(next.error!, toastType: ToastType.error);
          }
        });
      }
    });
    final stateState = ref.watch(stateListProvider);

    return Scaffold(
      appBar: CommonAppBar(
        title: l10n.addAddress,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(l10n.addressRecipientNameLabel),
                  CommonSpacing.small,
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      l10n.addressRecipientNameLabel,
                    ),
                  ),
                  CommonSpacing.standard,
                  _buildLabel(l10n.addressPhoneNumberLabel),
                  CommonSpacing.small,
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(l10n.addressPhoneNumberLabel),
                  ),
                  CommonSpacing.standard,
                  _buildLabel(l10n.addressStreetLabel),
                  CommonSpacing.small,
                  TextFormField(
                    controller: _streetController,
                    readOnly: true,
                    decoration: _inputDecoration(
                      l10n.addressStreetLabel,
                    ).copyWith(
                      suffixIcon: Icon(
                        Icons.arrow_forward_ios,
                        size: 16.w,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                  CommonSpacing.standard,
                  _buildLabel(l10n.addressDetailLabel),
                  CommonSpacing.small,
                  TextFormField(
                    controller: _detailController,
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(l10n.addressDetailLabel),
                  ),
                  CommonSpacing.standard,
                  _buildLabel(l10n.addressStateLabel),
                  CommonSpacing.small,
                  GestureDetector(
                    onTap: _selectState,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _stateController,
                        decoration: _inputDecoration(
                          _selectedState?.state ?? l10n.addressStateLabel,
                        ).copyWith(
                          suffixIcon: Icon(
                            Icons.keyboard_arrow_down,
                            size: 24.w,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (stateState.isLoading && _selectedState == null) ...[
                    CommonSpacing.small,
                    Row(
                      children: [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: CommonIndicator(size: 16),
                        ),
                        CommonSpacing.width(8.w),
                        Text(
                          l10n.loadingText,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  CommonSpacing.standard,
                  _buildLabel(l10n.addressZipCodeLabel),
                  CommonSpacing.small,
                  TextFormField(
                    controller: _zipCodeController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    decoration: _inputDecoration(l10n.addressZipCodeLabel),
                  ),
                  CommonSpacing.extraLarge,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.addressSetDefaultToggle,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isDefault,
                        activeColor: Colors.white,
                        activeTrackColor: AppTheme.primaryOrange,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade300,
                        onChanged: (value) {
                          setState(() {
                            _isDefault = value;
                          });
                        },
                      ),
                    ],
                  ),
                  CommonSpacing.huge,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: Text(
                        l10n.btnSave,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  CommonSpacing.large,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }
}
