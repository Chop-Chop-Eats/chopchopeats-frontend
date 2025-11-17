import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../models/coupon_models.dart';
import '../services/coupon_servers.dart';

class CouponPage extends StatefulWidget {
  const CouponPage({super.key});

  @override
  State<CouponPage> createState() => _CouponPageState();
}

class _CouponPageState extends State<CouponPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CouponServers.getMyCouponList(CouponListQuery(pageNo: 1, pageSize: 10));
    });
  }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CommonAppBar(title: l10n.coupons),
      body: const Center(
        child: Text('优惠券'),
      ),
    );
  }
}