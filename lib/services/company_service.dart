import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:business_management_app/models/company.dart';

class CompanyService {
  final CollectionReference _companyCollection = FirebaseFirestore.instance.collection('companies');

  Future<Company> getCompanyById(String companyId) async {
    DocumentSnapshot doc = await _companyCollection.doc(companyId).get();
    return Company.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<List<Company>> getAllCompanies() async {
    QuerySnapshot querySnapshot = await _companyCollection.get();
    return querySnapshot.docs.map((doc) => Company.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}
