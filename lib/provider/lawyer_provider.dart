import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/models/lawyer.dart';
import 'package:my_rights_mobile_app/service/firebase_service.dart';

class LawyerState {
  final List<Lawyer> lawyers;
  final List<Lawyer> filteredLawyers;
  final String searchQuery;
  final bool loading;
  final String? error;

  LawyerState({
    this.searchQuery = '',
    this.lawyers = const [],
    this.filteredLawyers = const [],
    this.loading = false,
    this.error,
  });

  LawyerState copyWith({
    String? searchQuery,
    List<Lawyer>? lawyers,
    List<Lawyer>? filteredLawyers,
    bool? loading,
    String? error,
  }) {
    return LawyerState(
      searchQuery: searchQuery ?? this.searchQuery,
      lawyers: lawyers ?? this.lawyers,
      filteredLawyers: filteredLawyers ?? this.filteredLawyers,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class LawyerNotifier extends StateNotifier<LawyerState> {
  final Ref ref;
  StreamSubscription<List<Lawyer>>? _subscription;

  LawyerNotifier(this.ref) : super(LawyerState()) {
    _loadLawyers();
  }

  void _loadLawyers() {
    state = state.copyWith(loading: true);

    _subscription = FirebaseService.getCollectionStream('lawyers')
        .map((snapshot) => snapshot.docs
            .map((doc) => Lawyer.fromJson({...doc.data(), 'id': doc.id}))
            .toList())
        .listen(
          (lawyers) {
            state = state.copyWith(lawyers: lawyers, filteredLawyers: lawyers, loading: false);
          }, 
          onError: (error) {
            state = state.copyWith(error: error.toString(), loading: false);
          }
        );
  }

  void setSearchQuery(String query) {
      final filteredLaws = query.isEmpty 
          ? state.lawyers
          : state.lawyers.where((org) {
            return org.name.toLowerCase().contains(query.toLowerCase());
          }).toList();

      state = state.copyWith(
        searchQuery: query,
        filteredLawyers: filteredLaws,
      );
    }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final lawyersProvider = StateNotifierProvider<LawyerNotifier, LawyerState>((ref) {
  return LawyerNotifier(ref);
});

final lawyerByOrganizationProvider = StateProvider.family<List<Lawyer>, String>((ref, organization) {
  return ref.watch(lawyersProvider).filteredLawyers
      .where((lawyer) => lawyer.organizations.contains(organization))
      .toList();
});

final lawyerByIdProvider = StateProvider.family<Lawyer?, String>((ref, id) {
  final lawyers = ref.watch(lawyersProvider).lawyers;
  return lawyers.firstWhere((lawyer) => lawyer.id == id);
});