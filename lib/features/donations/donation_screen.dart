import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../core/theme.dart';

const _productIds = {
  'com.cathoapp.bible.donation.1euro',
  'com.cathoapp.bible.donation.2euros',
  'com.cathoapp.bible.donation.5euros',
  'com.cathoapp.bible.donation.10euros',
};

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  List<ProductDetails> _products = [];
  bool _loading = true;
  bool _purchasing = false;
  bool _success = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      setState(() {
        _loading = false;
        _error = 'Achats in-app non disponibles.';
      });
      return;
    }
    final response =
        await InAppPurchase.instance.queryProductDetails(_productIds);
    setState(() {
      _products = response.productDetails
        ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
      _loading = false;
    });
  }

  Future<void> _purchase(ProductDetails product) async {
    setState(() {
      _purchasing = true;
      _error = null;
    });
    try {
      final param = PurchaseParam(productDetails: product);
      await InAppPurchase.instance.buyConsumable(purchaseParam: param);
      if (mounted) setState(() { _success = true; _purchasing = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Erreur lors du paiement.'; _purchasing = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // Header sombre → or
          SliverToBoxAdapter(child: _DonationHeader()),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_success) _buildSuccess(),
                if (_loading && !_success) _buildLoading(),
                if (!_loading && !_success && _products.isEmpty) _buildEmpty(),
                if (!_loading && !_success && _products.isNotEmpty)
                  ..._products.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _DonationTile(
                          product: p,
                          onTap: _purchasing ? null : () => _purchase(p),
                          loading: _purchasing,
                        ),
                      )),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 14)),
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Les dons sont traités par Apple (iOS) ou Google (Android).\nUne commission de 30% est prélevée par la plateforme.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.sublabel,
                      height: 1.5),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: const Column(
        children: [
          Text('🙏', style: TextStyle(fontSize: 48)),
          SizedBox(height: 16),
          Text('Merci du fond du cœur !',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.label)),
          SizedBox(height: 10),
          Text(
            'Votre soutien permet de maintenir cette\napplication et d\'aider d\'autres fidèles.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppTheme.sublabel, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary)),
    );
  }

  Widget _buildEmpty() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Options de don non disponibles pour le moment.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.sublabel, height: 1.5),
      ),
    );
  }
}

class _DonationHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(24, top + 24, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF100800),
            Color(0xFF6B4400),
            Color(0xFFC9A844),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Column(
        children: [
          // Bouton retour
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Logo Lumen
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/app_icon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Soutenir le projet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Cette application est entièrement gratuite.\nSi elle vous aide dans votre vie de foi,\nvous pouvez soutenir son développement.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonationTile extends StatelessWidget {
  final ProductDetails product;
  final VoidCallback? onTap;
  final bool loading;

  const _DonationTile({
    required this.product,
    required this.onTap,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.label)),
                  if (product.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(product.description,
                          style: const TextStyle(
                              color: AppTheme.sublabel, fontSize: 12)),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: AppTheme.primary, strokeWidth: 2))
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primarySoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      product.price,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
