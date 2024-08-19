import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item.dart';

class DeliverooColors {
  static const Color primary = Color(0xFF00CCBC);
  static const Color secondary = Color(0xFF2E3333);
  static const Color background = Color(0xFFF9FAFA);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
}

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Your Cart',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: DeliverooColors.primary,
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
          Icon(Icons.shopping_cart_outlined, size: 100, color: Color(0xFFE0E0E0)),
          SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Add some delicious items to get started!',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: DeliverooColors.textLight,
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
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        cart.removeItem(itemId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed from cart'),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                cart.addItem(itemId, item.name, item.price, item.imageUrl, item.sellerType);
              },
            ),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
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
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: DeliverooColors.textDark,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '${item.price.toStringAsFixed(2)} MAD',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: DeliverooColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        _buildQuantityButton(Icons.remove, () => cart.decrementQuantity(itemId)),
                        SizedBox(width: 10),
                        Text(
                          '${item.quantity}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: DeliverooColors.textDark,
                          ),
                        ),
                        SizedBox(width: 10),
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
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: DeliverooColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 20, color: DeliverooColors.primary),
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  'Total',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: DeliverooColors.textLight,
                  ),
                ),
                Text(
                  '${cart.totalAmount.toStringAsFixed(2)} MAD',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DeliverooColors.textDark,
                  ),
                ),
              ],
            ),
            SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: cart.items.isNotEmpty ? () {
                  Navigator.pushNamed(context, '/checkout');
                } : null,
                child: Text(
                  'Checkout',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: DeliverooColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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