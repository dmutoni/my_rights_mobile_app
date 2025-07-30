import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/models/lawyer.dart';
import 'package:my_rights_mobile_app/service/firebase_service.dart';

final searchLawyerProvider = StateProvider<String>((ref) => '');

final lawyersProvider = StreamProvider<List<Lawyer>>((ref) {
  final searchQuery = ref.watch(searchLawyerProvider);

  if (searchQuery.isEmpty) {
    return FirebaseService.getCollectionStream('lawyers')
      .map((snapshot) =>
          snapshot.docs.map((doc) => Lawyer.fromJson({...doc.data(), 'id': doc.id})).toList());
  } else {
    return FirebaseService.getDocumentQueryRange(collection: 'lawyers', field: 'name', value: searchQuery)
      .map((snapshot) =>
          snapshot.docs.map((doc) => Lawyer.fromJson({...doc.data(), 'id': doc.id})).toList());
  }
});

// Add this provider for getting individual lawyer details
final lawyerByIdProvider = StreamProvider.family<Lawyer?, String>((ref, lawyerId) {
  return FirebaseService.getDocumentStream('lawyers', lawyerId)
      .map((snapshot) {
        if (!snapshot.exists) return null;
        
        try {
          final data = snapshot.data() as Map<String, dynamic>;
          return Lawyer.fromJson({
            ...data,
            'id': snapshot.id,
          });
        } catch (e) {
          print('Error parsing lawyer $lawyerId: $e');
          return null;
        }
      });
});