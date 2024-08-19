import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:my_delivery_app/models/cart_item.dart';
import 'package:my_delivery_app/screens/order_tracking_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';
import '../screens/marjane_screen.dart';
import '../models/custom_user.dart';

class DeliverooColors {
  static const Color primary = Color(0xFF00CCBC);
  static const Color secondary = Color(0xFF2E3333);
  static const Color background = Color(0xFFF9FAFA);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFFF8000);
}

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final PaymentService _paymentService = PaymentService();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedPaymentMethod = 'Cash';
  LatLng _selectedLocation = LatLng(31.7917, -7.0926);
  bool _isBottomSheetOpen = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hasModifiedMap = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _addressController.addListener(_onAddressChanged);
  }

  Future<void> _loadUserInfo() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user != null) {
      final userData = await _firestoreService.getUser(user.uid);
      setState(() {
        _addressController.text = userData['address'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
        if (userData['location'] != null) {
          _selectedLocation = LatLng(
            userData['location'].latitude,
            userData['location'].longitude,
          );
          _mapController.move(_selectedLocation, 15.0);
        }
      });
    }
  }

  void _onAddressChanged() {
    if (!_hasModifiedMap) {
      _updateMapFromAddress(_addressController.text);
    }
    _hasModifiedMap = false;
  }

  Future<void> _updateMapFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _selectedLocation = LatLng(locations.first.latitude, locations.first.longitude);
          _mapController.move(_selectedLocation, 15.0);
        });
      }
    } catch (e) {
      print('Error updating map from address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartService>(context);
    final auth = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: DeliverooColors.background,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: DeliverooColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: cart.items.isEmpty
          ? _buildEmptyCart(context)
          : Stack(
              children: [
                _buildCartItems(cart),
                _buildBottomSheet(context, cart, auth),
              ],
            ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: DeliverooColors.primary,
          ),
          SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text(
              'SHOP NOW',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: DeliverooColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MarjaneScreen(location: 'casablanca')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(CartService cart) {
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 180),
      itemCount: cart.items.length,
      itemBuilder: (ctx, i) => _buildCartItem(context, cart, cart.items.entries.toList()[i]),
    );
  }

  Widget _buildCartItem(BuildContext context, CartService cart, MapEntry<String, CartItem> entry) {
    final String productId = entry.key;
    final CartItem item = entry.value;

    return Dismissible(
      key: Key(productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        cart.removeItem(productId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item.name} removed from cart')),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(item.imageUrl),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${item.quantity} x ${item.price.toStringAsFixed(2)} MAD',
                      style: GoogleFonts.poppins(
                        color: DeliverooColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(item.price * item.quantity).toStringAsFixed(2)} MAD',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: DeliverooColors.primary,
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  cart.removeItem(productId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} removed from cart')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, CartService cart, AuthService auth) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: 0,
      left: 0,
      right: 0,
      height: _isBottomSheetOpen ? MediaQuery.of(context).size.height * 0.9 : 180,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -20) {
            setState(() {
              _isBottomSheetOpen = true;
            });
          } else if (details.primaryDelta! > 20) {
            setState(() {
              _isBottomSheetOpen = false;
            });
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _buildSummary(cart),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildDeliveryDetails(),
                        _buildPaymentMethod(),
                      ],
                    ),
                  ),
                ),
                _buildConfirmOrderButton(context, cart, auth),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(CartService cart) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            '${(cart.totalAmount + 10).toStringAsFixed(2)} MAD',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: DeliverooColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Details',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 15.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point;
                    _hasModifiedMap = true;
                  });
                  _updateAddressFromLocation(point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40.0,
                      height: 40.0,
                      point: _selectedLocation,
                      child: Icon(
                        Icons.location_on,
                        color: DeliverooColors.primary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.location_on, color: DeliverooColors.primary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.phone, color: DeliverooColors.primary),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateAddressFromLocation(LatLng point) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.street}, ${place.locality}, ${place.country}';
        setState(() {
          _addressController.text = address;
        });
        }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Widget _buildPaymentMethod() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          RadioListTile(
            title: Text('Pay with Cash'),
            value: 'Cash',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value.toString();
              });
            },
            activeColor: DeliverooColors.primary,
          ),
          RadioListTile(
            title: Text('Add New Card'),
            value: 'Card',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value.toString();
              });
            },
            activeColor: DeliverooColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmOrderButton(BuildContext context, CartService cart, AuthService auth) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: ElevatedButton(
        child: Text(
          'Confirm Order',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: DeliverooColors.primary,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: Size(double.infinity, 50),
        ),
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            if (!_isBottomSheetOpen) {
              setState(() {
                _isBottomSheetOpen = true;
              });
            } else {
              _showConfirmOrderDialog(context, cart, auth);
            }
          } else {
            setState(() {
              _isBottomSheetOpen = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Please fill in all required fields')),
            );
          }
        },
      ),
    );
  }

  void _showConfirmOrderDialog(BuildContext context, CartService cart, AuthService auth) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TicketOrderSummary(
                  total: (cart.totalAmount + 10).toStringAsFixed(2),
                  paymentMethod: _selectedPaymentMethod,
                  address: _addressController.text,
                  phone: _phoneController.text,
                ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Are you sure you want to place this order?',
                    style: GoogleFonts.poppins(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              child: Text(
                'Confirm',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliverooColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (auth.currentUser == null) {
                  _showRegistrationBottomSheet(context, cart);
                } else {
                  await _processPayment(context, cart, auth);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showRegistrationBottomSheet(BuildContext context, CartService cart) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return RegistrationBottomSheet(
          onRegistrationComplete: (CustomUser user) async {
            Navigator.pop(context); // Close the bottom sheet
            await _processPayment(context, cart, Provider.of<AuthService>(context, listen: false));
          },
          address: _addressController.text,
          phone: _phoneController.text,
        );
      },
    );
  }

Future<void> _processPayment(BuildContext context, CartService cart, AuthService auth) async {
    try {
      String? paymentIntentId;
      if (_selectedPaymentMethod == 'Card') {
        final PaymentIntent paymentResult = await _paymentService.processPayment(
          cart.totalAmount + 10,
          'MAD',
        );

        if (paymentResult.status != 'succeeded') {
          throw Exception('Payment failed: ${paymentResult.status}');
        }
        paymentIntentId = paymentResult.id;
      }

      List<Map<String, dynamic>> orderItems = cart.items.entries.map((entry) {
        return {
          'product_id': entry.key,
          'product_name': entry.value.name,
          'quantity': entry.value.quantity,
          'price': entry.value.price,
          'sellerType': entry.value.sellerType,
        };
      }).toList();

      String sellerType = cart.items.values.first.sellerType;

      String orderId = await _firestoreService.createOrder(
        userId: auth.currentUser!.uid,
        totalAmount: cart.totalAmount + 10,
        orderItems: orderItems,
        status: _selectedPaymentMethod == 'Cash' ? 'Pending' : 'Paid',
        paymentMethod: _selectedPaymentMethod,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        location: GeoPoint(_selectedLocation.latitude, _selectedLocation.longitude),
        paymentIntentId: paymentIntentId,
        sellerType: sellerType,
      );

      cart.clear();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(orderId: orderId),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing order: ${error.toString()}')),
      );
    }
  }
  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

class TicketOrderSummary extends StatelessWidget {
  final String total;
  final String paymentMethod;
  final String address;
  final String phone;

  const TicketOrderSummary({
    Key? key,
    required this.total,
    required this.paymentMethod,
    required this.address,
    required this.phone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Summary',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Snap a photo of your ticket!',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
                    ),
                    Text(
                      '$total MAD',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF14B8A6),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildInfoRow('Payment', paymentMethod),
                _buildInfoRow('Address', address),
                _buildInfoRow('Phone', phone),
              ],
            ),
          ),
          Divider(color: Colors.grey[300], thickness: 1, height: 1),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order ID',
                  style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#${_generateRandomOrderId()}',
                    style: GoogleFonts.robotoMono(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _generateRandomOrderId() {
    return (Random().nextDouble() * 1000000).toInt().toString().padLeft(6, '0');
  }
}


class RegistrationBottomSheet extends StatefulWidget {
  final Function(CustomUser) onRegistrationComplete;
  final String address;
  final String phone;

  RegistrationBottomSheet({
    required this.onRegistrationComplete,
    required this.address,
    required this.phone,
  });

  @override
  _RegistrationBottomSheetState createState() => _RegistrationBottomSheetState();
}

class _RegistrationBottomSheetState extends State<RegistrationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  late String _phone;
  bool _isRegistering = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _phone = widget.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DeliverooColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Register to Place Order',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: DeliverooColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            _buildTextField(
              icon: Icons.person,
              hintText: 'Name',
              onSaved: (value) => _name = value!,
              validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
            ),
            SizedBox(height: 16),
            _buildTextField(
              icon: Icons.email,
              hintText: 'Email',
              onSaved: (value) => _email = value!,
              validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
            ),
            SizedBox(height: 16),
            _buildTextField(
              icon: Icons.lock,
              hintText: 'Password',
              obscureText: !_isPasswordVisible,
              onSaved: (value) => _password = value!,
              validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: DeliverooColors.textLight,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(
              icon: Icons.phone,
              hintText: 'Phone',
              initialValue: _phone,
              onSaved: (value) => _phone = value!,
              validator: (value) => value!.isEmpty ? 'Please enter your phone number' : null,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: _isRegistering
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Register and Place Order',
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: DeliverooColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: _isRegistering ? null : _register,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String hintText,
    required Function(String?) onSaved,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    String? initialValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DeliverooColors.textLight.withOpacity(0.5)),
      ),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: DeliverooColors.primary),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(textStyle: TextStyle(color: DeliverooColors.textLight)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          suffixIcon: suffixIcon,
        ),
        style: GoogleFonts.poppins(textStyle: TextStyle(color: DeliverooColors.textDark)),
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isRegistering = true;
      });
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        CustomUser? user = await authService.registerWithEmailAndPassword(_email, _password, _name, _phone);
        if (user != null) {
          // Update user's address
          await Provider.of<FirestoreService>(context, listen: false).updateUserInfo(
            user.uid,
            _name,
            _phone,
            widget.address,
          );
          widget.onRegistrationComplete(user);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isRegistering = false;
        });
      }
    }
  }
}
