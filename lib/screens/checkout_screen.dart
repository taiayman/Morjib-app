import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:my_delivery_app/models/cart_item.dart';
import 'package:my_delivery_app/screens/order_tracking_screen.dart';
import 'package:my_delivery_app/screens/register_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/loading_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../services/cart_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/payment_service.dart';
import '../screens/marjane_screen.dart';
import '../models/custom_user.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/loading_overlay.dart';

class DeliverooColors {
  static const Color primary = Color(0xFFD9251D);
  static const Color secondary = Color(0xFFD9B382);
  static const Color background = Color(0xFFE0D5B7);
  static const Color textDark = Color(0xFF2E3333);
  static const Color textLight = Color(0xFF585C5C);
  static const Color accent = Color(0xFFD9B382);
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
  LatLng _selectedLocation = LatLng(31.6295, -7.9811); // Marrakech coordinates
  bool _isBottomSheetOpen = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _hasModifiedMap = false;
  final MapController _mapController = MapController();

  // CMI Payment Details Controllers
  final MaskedTextController _cardNumberController = MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

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
          'checkout'.tr(),
          style: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
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
            Icons.shopping_bag_outlined,
            size: 100,
            color: DeliverooColors.accent,
          ),
          SizedBox(height: 20),
          Text(
            'cart_empty'.tr(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: DeliverooColors.textDark,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text(
              'shop_now'.tr(),
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
        decoration: BoxDecoration(
          color: DeliverooColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        cart.removeItem(productId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('item_removed_from_cart'.tr(args: [item.name]))),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: DeliverooColors.accent.withOpacity(0.2), width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: DeliverooColors.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${item.quantity}x ${item.price.toStringAsFixed(2)} MAD',
                      style: GoogleFonts.poppins(
                        color: DeliverooColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${(item.price * item.quantity).toStringAsFixed(2)} MAD',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: DeliverooColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              InkWell(
                onTap: () {
                  cart.removeItem(productId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('item_removed_from_cart'.tr(args: [item.name]))),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: DeliverooColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.delete_outline, color: DeliverooColors.primary, size: 24),
                ),
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
            'total'.tr(),
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          Text(
            '${(cart.totalAmount + 10).toStringAsFixed(2)} MAD',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
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
            'delivery_details'.tr(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
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
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                  tileBuilder: (context, tileWidget, tile) {
                    return ColorFiltered(
                      colorFilter: ColorFilter.matrix([
                        0.33, 0.33, 0.33, 0, -30, // Red channel
                        0.33, 0.33, 0.33, 0, -30, // Green channel
                        0.33, 0.33, 0.33, 0, -30, // Blue channel
                        0,    0,    0,    1,  0,   // Alpha channel
                      ]),
                      child: tileWidget,
                    );
                  },
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
              labelText: 'address'.tr(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.location_on, color: DeliverooColors.primary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'please_enter_address'.tr();
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'phone_number'.tr(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: Icon(Icons.phone, color: DeliverooColors.primary),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'please_enter_phone'.tr();
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
            'payment_method'.tr(),
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          RadioListTile(
            title: Text('pay_with_cash'.tr(), style: GoogleFonts.poppins()),
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
            title: Text('pay_with_cmi'.tr(), style: GoogleFonts.poppins()),
            value: 'CMI',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value.toString();
              });
            },
            activeColor: DeliverooColors.primary,
          ),
          if (_selectedPaymentMethod == 'CMI')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: InputDecoration(
                      labelText: 'card_number'.tr(),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: Icon(Icons.credit_card, color: DeliverooColors.primary),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please_enter_card_number'.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryDateController,
                          decoration: InputDecoration(
                            labelText: 'expiry_date'.tr(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: Icon(Icons.calendar_today, color: DeliverooColors.primary),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please_enter_expiry_date'.tr();
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: InputDecoration(
                            labelText: 'cvv'.tr(),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: Icon(Icons.lock, color: DeliverooColors.primary),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please_enter_cvv'.tr();
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConfirmOrderButton(BuildContext context, CartService cart, AuthService auth) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: DeliverooColors.accent.withOpacity(0.5),
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: ElevatedButton(
          child: Text(
            'confirm_order'.tr(),
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
            elevation: 0,
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
                SnackBar(content: Text('please_fill_all_fields'.tr())),
              );
            }
          },
        ),
      ),
    );
  }

  void _showConfirmOrderDialog(BuildContext context, CartService cart, AuthService auth) async {
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => LoadingOverlay(),
    );

    try {
      // 1. Process the payment (or simulate it) if needed.
      String? paymentId;
      if (_selectedPaymentMethod == 'CMI') {
        String cardNumber = _cardNumberController.text.replaceAll(' ', '');
        String expiryDate = _expiryDateController.text;
        String cvv = _cvvController.text;

        paymentId = await _paymentService.processCMIPayment(
          amount: cart.totalAmount + 10,
          currency: 'MAD',
          cardNumber: cardNumber,
          expiryDate: expiryDate,
          cvv: cvv,
        );
      }

      // 2. Create the order in Firestore.
      String orderId = await _firestoreService.createOrder(
        userId: auth.currentUser!.uid,
        totalAmount: cart.totalAmount + 10,
        orderItems: cart.items.entries.map((entry) {
          return {
            'product_id': entry.key,
            'product_name': entry.value.name,
            'quantity': entry.value.quantity,
            'price': entry.value.price,
            'sellerType': entry.value.sellerType,
          };
        }).toList(),
        status: _selectedPaymentMethod == 'Cash' ? 'Pending' : 'Paid',
        paymentMethod: _selectedPaymentMethod,
        address: _addressController.text,
        phoneNumber: _phoneController.text,
        location: GeoPoint(_selectedLocation.latitude, _selectedLocation.longitude),
        paymentIntentId: paymentId,
        sellerType: cart.items.values.first.sellerType,
      );

      // Remove the loading overlay
      Navigator.of(context).pop();

      // 3. Show the dialog with the actual order ID.
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
                    orderId: orderId,
                    total: (cart.totalAmount + 10).toStringAsFixed(2),
                    paymentMethod: _selectedPaymentMethod,
                    address: _addressController.text,
                    phone: _phoneController.text,
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'confirm_place_order'.tr(),
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
                  'cancel'.tr(),
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                child: Text(
                  'confirm'.tr(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DeliverooColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  cart.clear();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => OrderTrackingScreen(orderId: orderId),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Remove the loading overlay
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}

class TicketOrderSummary extends StatelessWidget {
  final String orderId;
  final String total;
  final String paymentMethod;
  final String address;
  final String phone;

  const TicketOrderSummary({
    Key? key,
    required this.orderId,
    required this.total,
    required this.paymentMethod,
    required this.address,
    required this.phone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Truncate the order ID to a maximum of 10 characters
    String truncatedOrderId = orderId.length > 10 ? orderId.substring(0, 10) + '...' : orderId; 

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: DeliverooColors.accent.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: DeliverooColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'order_summary'.tr(),
                  style: GoogleFonts.playfairDisplay(
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
                      'snap_ticket_photo'.tr(),
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
                    Expanded(
                      child: Text(
                        'total'.tr(),
                        style: GoogleFonts.poppins(color: DeliverooColors.textLight, fontSize: 16),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '$total MAD',
                        style: GoogleFonts.poppins(
                          color: DeliverooColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                _buildInfoRow('payment'.tr(), paymentMethod),
                _buildInfoRow('address'.tr(), address),
                _buildInfoRow('phone'.tr(), phone),
              ],
            ),
          ),
          Divider(color: DeliverooColors.accent.withOpacity(0.2), thickness: 1, height: 1),
          Container(
            padding: EdgeInsets.all(16),
            color: DeliverooColors.accent.withOpacity(0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'order_id'.tr(),
                  style: GoogleFonts.poppins(color: DeliverooColors.textLight, fontSize: 14),
                ),
                Expanded( // Use Expanded to make order ID flexible
                  child: Text(
                    '#$truncatedOrderId', 
                    style: GoogleFonts.robotoMono(
                      fontSize: 14,
                      color: DeliverooColors.textDark,
                    ),
                    textAlign: TextAlign.end, // Align the truncated ID to the end
                    overflow: TextOverflow.ellipsis, // Add ellipsis if the text overflows
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
              style: GoogleFonts.poppins(color: DeliverooColors.textLight, fontSize: 14),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: DeliverooColors.textDark,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
