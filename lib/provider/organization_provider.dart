import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/models/organization.dart';
import 'package:my_rights_mobile_app/service/firebase_service.dart';

final searchOrganizationProvider = StateProvider<String>((ref) => '');

final organizationsProvider = StreamProvider<List<Organization>>((ref) {
  final searchQuery = ref.watch(searchOrganizationProvider);
  
  if (searchQuery.isEmpty) {
    return FirebaseService.getCollectionStream('organizations')
      .map((snapshot) =>
          snapshot.docs.map((doc) => Organization.fromJson({...doc.data(), 'id': doc.id})).toList());
  } else {
    return FirebaseService.getDocumentQueryRange(collection: 'organizations', field: 'name', value: searchQuery)
      .map((snapshot) =>
          snapshot.docs.map((doc) => Organization.fromJson({...doc.data(), 'id': doc.id})).toList());
  }
});