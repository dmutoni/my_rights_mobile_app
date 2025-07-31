import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_rights_mobile_app/models/organization.dart';
import 'package:my_rights_mobile_app/service/firebase_service.dart';

class OrganizationState {
  final List<Organization> organizations;
  final List<Organization> filteredOrganizations;
  final String searchQuery;
  final bool loading;
  final String? error;

  OrganizationState({
    this.searchQuery = '',
    this.organizations = const [],
    this.filteredOrganizations = const [],
    this.loading = false,
    this.error,
  });

  OrganizationState copyWith({
    String? searchQuery,
    List<Organization>? organizations,
    List<Organization>? filteredOrganizations,
    bool? loading,
    String? error,
  }) {
    return OrganizationState(
      searchQuery: searchQuery ?? this.searchQuery,
      organizations: organizations ?? this.organizations,
      filteredOrganizations: filteredOrganizations ?? this.filteredOrganizations,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}

class OrganizationNotifier extends StateNotifier<OrganizationState> {
  final Ref ref;
  StreamSubscription<List<Organization>>? _subscription;
  
  OrganizationNotifier(this.ref) : super(OrganizationState()) {
    _loadOrganizations();
  }

  void _loadOrganizations() {
    state = state.copyWith(loading: true);
    
    _subscription = FirebaseService.getCollectionStream('organizations')
        .map((snapshot) => snapshot.docs
            .map((doc) => Organization.fromJson({...doc.data(), 'id': doc.id}))
            .toList())
        .listen(
          (organizations) {
            state = state.copyWith(
              organizations: organizations, 
              filteredOrganizations: organizations,
              loading: false
            );
          }, 
          onError: (error) {
            state = state.copyWith(
              error: error.toString(), 
              loading: false
            );
          }
        );
  }

  void setSearchQuery(String query) {
    final filteredOrgs = query.isEmpty 
        ? state.organizations
        : state.organizations.where((org) {
          return org.name.toLowerCase().contains(query.toLowerCase()) ||
            org.location.toLowerCase().contains(query.toLowerCase());
          }).toList();
    
    state = state.copyWith(
      searchQuery: query,
      filteredOrganizations: filteredOrgs,
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final organizationsProvider = StateNotifierProvider<OrganizationNotifier, OrganizationState>((ref) {
  return OrganizationNotifier(ref);
});
