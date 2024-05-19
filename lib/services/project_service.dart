// project_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:business_management_app/models/project.dart';

class ProjectService {
  final CollectionReference _projectCollection = FirebaseFirestore.instance.collection('projects');

  Future<void> addProject(Project project) async {
    await _projectCollection.doc(project.id).set(project.toMap());
  }

  Future<Project> getProject(String id) async {
    DocumentSnapshot doc = await _projectCollection.doc(id).get();
    return Project.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<void> updateProject(Project project) async {
    await _projectCollection.doc(project.id).update(project.toMap());
  }

  Future<void> deleteProject(String id) async {
    await _projectCollection.doc(id).delete();
  }

  Future<List<Project>> getLatestProjects() async {
    QuerySnapshot querySnapshot = await _projectCollection
        .orderBy('end', descending: true)
        .limit(10)
        .get(); // Fetch the latest 10 projects based on end date
    return querySnapshot.docs
        .map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Project>> getProjectsForCompany(String companyId) async {
    QuerySnapshot querySnapshot = await _projectCollection
        .where('companyId', isEqualTo: companyId)
        .get();
    return querySnapshot.docs
        .map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
