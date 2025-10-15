import 'package:flutter/material.dart';

import '../../../core/utils/logger/logger.dart';
import '../services/detail_services.dart';

class DetailPage extends StatefulWidget {
  final String id;
  const DetailPage({super.key, required this.id});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final response = await DetailServices().getShop(widget.id);
    Logger.info('DetailPage', '店铺详情: ${response}');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Text('详情'),
          ],
        ),
      ),
    );
  }
}