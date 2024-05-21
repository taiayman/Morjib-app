import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<Map<String, dynamic>> ceoData = [
    {
      "email": "Saber@Mormove.com",
      "password": "Mormove12345",
      "companyName": "Mormove",
      "ceoName": "SABER ABDERRAHIME",
      "ceoEmail": "ceo1@example.com",
      "ceoPhone": "1234567890",
      "ceoWhatsApp": "1234567890",
      "employeeCount": 15,
      "capital": "250.000,00DH",
      "services": ["Moving", "Professional logistics", "Tools renting", "Renting moving vehicles"],
      "projects": [],
      "statusColor": "Green",
    },
    {
      "email": "Hiba@Morjib.com",
      "password": "Morjib12345",
      "companyName": "Morjib",
      "ceoName": "HIBA LMOUAACHI",
      "ceoEmail": "ceo2@example.com",
      "ceoPhone": "0987654321",
      "ceoWhatsApp": "0987654321",
      "employeeCount": 20,
      "capital": "100.000,00DH",
      "services": ["Goods delivery", "Goods preparation"],
      "projects": [],
      "statusColor": "Blue",
    },
    {
      "email": "Mounir@SMHorizon.com",
      "password": "SMHorizon12345",
      "companyName": "SMHorizon",
      "ceoName": "MOUNIR SABIR",
      "ceoEmail": "ceo3@example.com",
      "ceoPhone": "1122334455",
      "ceoWhatsApp": "1122334455",
      "employeeCount": 13,
      "capital": "50.000,00DH",
      "services": ["Marketing", "Copywriting", "Consulting", "Business Strategies (Africa & GCC)"],
      "projects": [],
      "statusColor": "Red",
    },
    {
      "email": "Hafsa@12Daba.com",
      "password": "12Daba12345",
      "companyName": "12 Daba",
      "ceoName": "HAFSA BOUAZZA",
      "ceoEmail": "ceo4@example.com",
      "ceoPhone": "2233445566",
      "ceoWhatsApp": "2233445566",
      "employeeCount": 25,
      "capital": "40.000,00DH",
      "services": ["Goods delivery", "Food delivery"],
      "projects": [],
      "statusColor": "Yellow",
    },
    {
      "email": "Hiba@Investdar.com",
      "password": "Investdar12345",
      "companyName": "Investdar",
      "ceoName": "HIBA LMOUAACHI",
      "ceoEmail": "ceo5@example.com",
      "ceoPhone": "3344556677",
      "ceoWhatsApp": "3344556677",
      "employeeCount": 9,
      "capital": "120.000,00DH",
      "services": ["Real Estate investment", "Renting Investment", "Stocks and equities"],
      "projects": [],
      "statusColor": "Purple",
    },
    {
      "email": "Mounir@xxxxxxx.com",
      "password": "xxxxxxx12345",
      "companyName": "xxxxxxx",
      "ceoName": "MOUNIR SABIR",
      "ceoEmail": "ceo6@example.com",
      "ceoPhone": "4455667788",
      "ceoWhatsApp": "4455667788",
      "employeeCount": 21,
      "capital": "1.000.000,00DH",
      "services": ["Educational field", "Online Coaching", "Online teaching"],
      "projects": [],
      "statusColor": "Orange",
    },
    {
      "email": "Mehdi@MadConsolutions.com",
      "password": "MadConsolutions12345",
      "companyName": "MadConsolutions",
      "ceoName": "MAHEDI HASAN MAJID",
      "ceoEmail": "ceo7@example.com",
      "ceoPhone": "5566778899",
      "ceoWhatsApp": "5566778899",
      "employeeCount": 32,
      "capital": "30.000,00DH",
      "services": ["APP creation", "Website creation", "Network security", "Hosting"],
      "projects": [],
      "statusColor": "Brown",
    },
  ];

  void _deleteAllData(BuildContext context) async {
    try {
      // Deleting users collection
      var usersSnapshot = await _firestore.collection('users').get();
      for (var doc in usersSnapshot.docs) {
        await _firestore.collection('users').doc(doc.id).delete();
      }

      // Deleting companies collection
      var companiesSnapshot = await _firestore.collection('companies').get();
      for (var doc in companiesSnapshot.docs) {
        await _firestore.collection('companies').doc(doc.id).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All data deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting data: $e')),
      );
    }
  }

  void _addData(BuildContext context) async {
    try {
      for (var ceo in ceoData) {
        // Create user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: ceo['email']!,
          password: ceo['password']!,
        );

        String userId = userCredential.user!.uid;

        // Add user data to Firestore
        await _firestore.collection('users').doc(userId).set({
          'id': userId,
          'name': ceo['ceoName']!,
          'email': ceo['ceoEmail']!,
          'role': 'CEO',
          'companyId': '',
          'whatsapp': ceo['ceoWhatsApp']!,
          'description': '',
          'profileImage': '',
        });

        // Create company
        String companyId = Uuid().v4();
        await _firestore.collection('companies').doc(companyId).set({
          'id': companyId,
          'name': ceo['companyName']!,
          'ceoId': userId,
          'ceoName': ceo['ceoName']!,
          'ceoEmail': ceo['ceoEmail']!,
          'ceoPhone': ceo['ceoPhone']!,
          'ceoWhatsApp': ceo['ceoWhatsApp']!,
          'employeeCount': ceo['employeeCount']!,
          'capital': ceo['capital']!,
          'services': ceo['services']!,
          'projects': ceo['projects']!,
          'statusColor': ceo['statusColor']!,
        });

        // Update user's companyId
        await _firestore.collection('users').doc(userId).update({
          'companyId': companyId,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin', style: GoogleFonts.rubik()),
        backgroundColor: Color(0xFFD97757),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => _deleteAllData(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                textStyle: GoogleFonts.rubik(fontSize: 18),
              ),
              child: Text('Delete All Data', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _addData(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                textStyle: GoogleFonts.rubik(fontSize: 18),
              ),
              child: Text('Add Data', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
