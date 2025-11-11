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
import '../../../core/maps/map_picker_page.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/common_indicator.dart';
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
  LatLng? _streetLatLng;
  String? _streetFromMap;
  bool _isDefault = false;
  StateItem? _selectedState;
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
      _isDefault = initial.defaultStatus;
      _selectedState = StateItem(id: initial.id ?? -1, state: initial.state);
    } else {
      _streetController.text = '';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stateListProvider.notifier).loadStates();
    });
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
        id: _logic.initial?.id,
        mobile: phone,
        name: name,
        state: state.state,
        zipCode: zipCode,
      );

      await _logic.submit(params: params);
      await ref.read(addressListProvider.notifier).loadAddresses();
      Pop.hideLoading(loadingId);
      Pop.toast(
        _logic.successMessage(l10n),
        toastType: ToastType.success,
      );
      if (mounted) {
        Navigate.pop(context, true);
      }
    } catch (e) {
      Pop.hideLoading(loadingId);
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
          initialAddress: currentAddress.isNotEmpty ? currentAddress : settings.locationLabel,
          title: l10n?.mapSelectLocationTitle,
          confirmText: l10n?.mapConfirmLocation,
          searchHint: l10n?.mapSearchHint,
        ),
      );

      if (result == null) {
        Logger.info('AddAddressPage', '用户取消地图选点');
        return;
      }

      final latLng = result.position;
      final formattedAddress = (result.address?.trim().isNotEmpty ?? false)
          ? result.address!.trim()
          : (l10n?.mapCoordinateLabel(latLng.latitude, latLng.longitude) ??
              '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}');

      setState(() {
        _streetLatLng = latLng;
        _streetFromMap = formattedAddress;
      });
      _streetController.text = formattedAddress;
      Logger.info('AddAddressPage', '地图选点成功: $formattedAddress (${latLng.latitude}, ${latLng.longitude})');
    } catch (e, stack) {
      Logger.error('AddAddressPage', '地图选点失败: $e\n$stack');
      Pop.toast(
        l10n?.mapPlaceDetailFailed ?? '解析地点失败，请稍后重试',
        toastType: ToastType.error,
      );
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
      maxHeight: SheetDimension.fraction(0.6),
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
                  if (_streetLatLng != null) ...[
                    CommonSpacing.small,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16.w,
                          color: AppTheme.primaryOrange,
                        ),
                        CommonSpacing.width(8),
                        Expanded(
                          child: Text(
                            l10n.mapCoordinateLabel(
                              _streetLatLng!.latitude,
                              _streetLatLng!.longitude,
                            ),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
