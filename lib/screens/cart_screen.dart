import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';
import 'package:easy_localization/easy_localization.dart';

class CarrefourColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
}

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CarrefourColors.background,
      appBar: AppBar(
        title: Text(
          'your_cart'.tr(),
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: CarrefourColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<CartService>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return _buildEmptyCart();
          }
          return _buildCartList(context, cart);
        },
      ),
      bottomNavigationBar: _buildCheckoutBar(context),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 100, color: CarrefourColors.accent.withOpacity(0.5)),
          SizedBox(height: 20),
          Text(
            'cart_empty'.tr(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CarrefourColors.textDark,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'add_items_to_start'.tr(),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: CarrefourColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(BuildContext context, CartService cart) {
    return ListView.builder(
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        String key = cart.items.keys.elementAt(index);
        return _buildCartItem(context, cart.items[key]!, cart, key);
      },
    );
  }

Widget _buildCartItem(BuildContext context, CartItem item, CartService cart, String itemId) {
  return Dismissible(
    key: Key(item.id),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: CarrefourColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.delete_outline, color: Colors.white, size: 28),
    ),
    onDismissed: (direction) {
      cart.removeItem(itemId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('item_removed_from_cart'.tr(args: [item.name])),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'undo'.tr(),
            onPressed: () {
              cart.addItem(itemId, item.name, item.price, item.imageUrl, item.sellerType);
            },
          ),
        ),
      );
    },
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: CarrefourColors.accent.withOpacity(0.2), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(item.imageUrl),
                ),
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CarrefourColors.textDark,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(2)} MAD',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: CarrefourColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      _buildQuantityButton(Icons.remove, () => cart.decrementQuantity(itemId)),
                      SizedBox(width: 15),
                      Text(
                        '${item.quantity}',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CarrefourColors.textDark,
                        ),
                      ),
                      SizedBox(width: 15),
                      _buildQuantityButton(Icons.add, () => cart.incrementQuantity(itemId)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
  return InkWell(
    onTap: onPressed,
    child: Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: CarrefourColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 20, color: CarrefourColors.primary),
    ),
  );
}  Widget _buildCheckoutBar(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: CarrefourColors.secondary.withOpacity(0.2),
            offset: Offset(0, -3),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'total'.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: CarrefourColors.textLight,
                  ),
                ),
                Text(
                  '${cart.totalAmount.toStringAsFixed(2)} MAD',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CarrefourColors.textDark,
                  ),
                ),
              ],
            ),
            SizedBox(width: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: CarrefourColors.accent,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: cart.items.isNotEmpty ? () {
                    Navigator.pushNamed(context, '/checkout');
                  } : null,
                  child: Text(
                    'checkout'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: CarrefourColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}