import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_list.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_search_bar.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:my_rights_mobile_app/provider/organization_provider.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_bottom_navbar.dart';


class OrganizationScreen extends ConsumerWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizations = ref.watch(organizationsProvider).filteredOrganizations;
    final loading = ref.watch(organizationsProvider).loading;
    final error = ref.watch(organizationsProvider).error;
    final searchQuery = ref.watch(organizationsProvider).searchQuery;

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CustomAppBar(title: 'Legal Aid Organizations'),
      body: SafeArea(
        child: Column(
          children: [
            CustomSearchBar(
              hintText: 'Search for organization',
              query: searchQuery,
              onChanged: (value) {
                ref.read(organizationsProvider.notifier).setSearchQuery(value);
              }),
            if (loading) ...[
              const Center(child: CircularProgressIndicator()),
            ],
            if (error != null) ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: $error',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            ],
            if (organizations.isEmpty) ...[
              EmptyCard(
                  icon: MingCuteIcons.mgc_building_1_line,
                  title: 'No Legal Organizations Available',
                  description: 'Legal organizations will appear here when available. Check back later for new content!',
              )
            ] else ...[
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 20, bottom: 24),
                  itemCount: organizations.length,
                  itemBuilder: (context, index) {
                    final organization = organizations[index];
                  return CustomListItem(
                    icon: MingCuteIcons.mgc_building_1_line,
                    title: organization.name,
                    subtitle: organization.location,
                    onTap: () {
                      context.go('${AppRouter.aid}/${organization.id}');
                    }
                  );
                },
              ))
            ]
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}
