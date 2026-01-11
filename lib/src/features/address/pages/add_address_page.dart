import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unified_popups/unified_popups.dart';

import '../../../core/config/app_services.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/navigate.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/logger/logger.dart';
import '../../../core/maps/pages/map_picker_page.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_spacing.dart';
import '../models/address_models.dart';
import '../providers/address_provider.dart';
import '../services/address_services.dart';

class AddAddressPage extends ConsumerStatefulWidget {
  const AddAddressPage({super.key, this.arguments});

  final AddressFormArguments? arguments;

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
  final _cityController = TextEditingController();
  LatLng? _streetLatLng;
  String? _streetFromMap;
  bool _isDefault = false;
  late final _AddressFormLogic _logic;

  bool get _isEditing => _logic.mode == AddressFormMode.edit;

  @override
  void initState() {
    super.initState();
    _logic = _resolveLogic();
    _streetController.addListener(_handleStreetChanged);
    final initial = _logic.initial;
    if (initial != null) {
      _nameController.text = initial.name;
      _phoneController.text = initial.mobile;
      _streetController.text = initial.address;
      _detailController.text = initial.detailAddress ?? '';
      _zipCodeController.text = initial.zipCode;
      _stateController.text = initial.state;
      // 注意：城市字段不在 AddressItem 模型中，编辑时无法从初始数据获取
      _isDefault = initial.defaultStatus;
    } else {
      _streetController.text = '';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    if (!_isEditing && _streetController.text.isEmpty) {
      _streetController.text = l10n.addressStreetFixedValue;
    }
  }

  @override
  void dispose() {
    _streetController.removeListener(_handleStreetChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _detailController.dispose();
    _zipCodeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _handleStreetChanged() {
    if (_streetLatLng == null) return;
    final current = _streetController.text.trim();
    final original = _streetFromMap?.trim();
    if (original == null || current != original) {
      if (!mounted) return;
      setState(() {
        _streetLatLng = null;
        _streetFromMap = null;
      });
    }
  }

  _AddressFormLogic _resolveLogic() {
    final args = widget.arguments;
    if (args == null || args.mode == AddressFormMode.create) {
      return const _CreateAddressFormLogic();
    }
    return _EditAddressFormLogic(args.initial!);
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final street = _streetController.text.trim();
    final detail = _detailController.text.trim();
    final zipCode = _zipCodeController.text.trim();
    final state = _stateController.text.trim();

    if (name.isEmpty || phone.isEmpty || street.isEmpty || zipCode.isEmpty || state.isEmpty) {
      Pop.toast(l10n.addressFormIncomplete, toastType: ToastType.warn);
      return;
    }

    // 确保从地图选择了位置
    if (_streetLatLng == null) {
      Pop.toast(l10n.mapSelectLocationTitle, toastType: ToastType.warn);
      return;
    }

    Pop.loading();

    try {
      final params = AddressItem(
        address: street,
        defaultStatus: _isDefault,
        detailAddress: detail.isEmpty ? null : detail,
        id: _logic.initial?.id,
        mobile: phone,
        name: name,
        state: state,
        zipCode: zipCode,
        latitude: _streetLatLng?.latitude,
        longitude: _streetLatLng?.longitude,
      );

      await _logic.submit(params: params);
      await ref.read(addressListProvider.notifier).loadAddresses();
      Pop.hideLoading();
      Pop.toast(
        _logic.successMessage(l10n),
        toastType: ToastType.success,
      );
      if (mounted) {
        Navigate.pop(context, true);
      }
    } catch (e) {
      Pop.hideLoading();
      Logger.error("AddAddressPage", "Error: $e");
      Pop.toast(e.toString(), toastType: ToastType.error);
    }
  }

  Future<void> _pickStreetOnMap() async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    final settings = AppServices.appSettings;
    final initialPosition = _streetLatLng ??
        LatLng(settings.latitude, settings.longitude);
    final currentAddress = _streetController.text.trim();

    try {
      final result = await Navigate.push<MapPickerResult>(
        context,
        Routes.mapPicker,
        arguments: MapPickerArguments(
          initialPosition: initialPosition,
          initialAddress: currentAddress.isNotEmpty ? currentAddress : (settings.isLocationInitialized ? settings.locationLabel : null),
        ),
      );

      if (result == null) {
        Logger.info('AddAddressPage', '用户取消地图选点');
        return;
      }

      final latLng = result.position;
      final addressComponents = result.addressComponents;
      final trimmedAddress = result.address?.trim() ?? '';
      final trimmedLabel = result.label?.trim() ?? '';
      Logger.info('AddAddressPage', 'addressComponents: $addressComponents');
      Logger.info('AddAddressPage', 'trimmedAddress: $trimmedAddress');
      Logger.info('AddAddressPage', 'trimmedLabel: $trimmedLabel');
      // 优先使用地址组件中的街道信息，否则使用格式化地址
      String formattedAddress;
      if (addressComponents?.street != null && addressComponents!.street!.isNotEmpty) {
        formattedAddress = addressComponents.street!;
      } else {
        formattedAddress = trimmedAddress.isNotEmpty
            ? trimmedAddress
            : trimmedLabel.isNotEmpty
                ? trimmedLabel
                : (l10n?.mapCoordinateLabel(latLng.latitude, latLng.longitude) ??
                    '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}');
      }
      Logger.info('AddAddressPage', 'formattedAddress: $formattedAddress');

      setState(() {
        _streetLatLng = latLng;
        _streetFromMap = formattedAddress;
      });
      
      // 填充街道地址
      _streetController.text = formattedAddress;
      
      // 填充城市、州和邮编（从地址组件中获取）
      if (addressComponents != null) {
        if (addressComponents.city != null && addressComponents.city!.isNotEmpty) {
          _cityController.text = addressComponents.city!;
        }
        if (addressComponents.state != null && addressComponents.state!.isNotEmpty) {
          _stateController.text = addressComponents.state!;
        }
        if (addressComponents.zipCode != null && addressComponents.zipCode!.isNotEmpty) {
          _zipCodeController.text = addressComponents.zipCode!;
        }
      }
      
      Logger.info('AddAddressPage', '地图选点成功: $formattedAddress (${latLng.latitude}, ${latLng.longitude})');
      Logger.info('AddAddressPage', '地址组件: state=${addressComponents?.state}, zipCode=${addressComponents?.zipCode}');
    } catch (e, stack) {
      Logger.error('AddAddressPage', '地图选点失败: $e\n$stack');
      Pop.toast(
        l10n?.mapPlaceDetailFailed ?? '解析地点失败，请稍后重试',
        toastType: ToastType.error,
      );
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

    return Scaffold(
      appBar: CommonAppBar(
        title: _isEditing ? l10n.editAddress : l10n.addAddress,
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
                    textInputAction: TextInputAction.next,
                    decoration: _inputDecoration(
                      l10n.addressStreetLabel,
                    ),
                  ),
                  CommonSpacing.small,
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _pickStreetOnMap,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryOrange,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(Icons.map_outlined, size: 18.w),
                      label: Text(
                        l10n.mapSelectLocationTitle,
                        style: TextStyle(fontSize: 14.sp),
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
                  _buildLabel(l10n.addressCityLabel),
                  CommonSpacing.small,
                  TextFormField(
                    controller: _cityController,
                    readOnly: true,
                    decoration: _inputDecoration(l10n.addressCityLabel),
                  ),
                  CommonSpacing.standard,
                  _buildLabel(l10n.addressStateLabel),
                  CommonSpacing.small,
                  TextFormField(
                    controller: _stateController,
                    readOnly: true,
                    decoration: _inputDecoration(l10n.addressStateLabel),
                  ),
                  CommonSpacing.standard,
                  _buildLabel(l10n.addressZipCodeLabel),
                  CommonSpacing.small,
                  TextFormField(
                    controller: _zipCodeController,
                    readOnly: true,
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

abstract class _AddressFormLogic {
  const _AddressFormLogic(this.mode);

  final AddressFormMode mode;

  AddressItem? get initial;

  Future<void> submit({required AddressItem params});

  String successMessage(AppLocalizations l10n);
}

class _CreateAddressFormLogic extends _AddressFormLogic {
  const _CreateAddressFormLogic() : super(AddressFormMode.create);

  @override
  AddressItem? get initial => null;

  @override
  Future<void> submit({required AddressItem params}) {
    return AddressServices.createUserAddress(params);
  }

  @override
  String successMessage(AppLocalizations l10n) => l10n.addressCreateSuccess;
}

class _EditAddressFormLogic extends _AddressFormLogic {
  const _EditAddressFormLogic(this._initial) : super(AddressFormMode.edit);

  final AddressItem _initial;

  @override
  AddressItem get initial => _initial;

  @override
  Future<void> submit({required AddressItem params}) async {
    if (_initial.id == null) {
      throw Exception('编辑地址缺少 ID');
    }
    await AddressServices.updateUserAddress(params);
  }

  @override
  String successMessage(AppLocalizations l10n) => l10n.addressUpdateSuccess;
}
