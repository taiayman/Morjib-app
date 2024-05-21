import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:business_management_app/models/project.dart';
import 'package:business_management_app/models/team_member.dart';

class ProjectService {
  final CollectionReference _projectCollection = FirebaseFirestore.instance.collection('projects');
  final CollectionReference _teamMemberCollection = FirebaseFirestore.instance.collection('team_members');

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

  Future<List<Project>> getProjectsForCompany(String companyId) async {
    QuerySnapshot querySnapshot = await _projectCollection.where('companyId', isEqualTo: companyId).get();
    return querySnapshot.docs.map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<List<Project>> getAllProjects() async {
    QuerySnapshot querySnapshot = await _projectCollection.get();
    return querySnapshot.docs.map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<List<Project>> getLatestProjects() async {
    QuerySnapshot querySnapshot = await _projectCollection.orderBy('date', descending: true).limit(10).get();
    return querySnapshot.docs.map((doc) => Project.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }

  Future<List<TeamMember>> getTeamMembers(List<String> memberIds) async {
    if (memberIds.isEmpty) return [];
    QuerySnapshot querySnapshot = await _teamMemberCollection.where(FieldPath.documentId, whereIn: memberIds).get();
    return querySnapshot.docs.map((doc) => TeamMember.fromMap(doc.data() as Map<String, dynamic>)).toList();
  }
}
