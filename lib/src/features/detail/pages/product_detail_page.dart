import 'package:flutter/material.dart';

import '../../../core/widgets/common_app_bar.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '商品详情',
      ),
      body: Column(
        children: [
          Text('商品详情'),
        ],
      ),
    );
  }
}