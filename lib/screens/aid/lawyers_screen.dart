import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/provider/organization_provider.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_list.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_search_bar.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:my_rights_mobile_app/provider/lawyer_provider.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_bottom_navbar.dart';

class LawyersScreen extends ConsumerWidget {
  final String? organization;
  const LawyersScreen({super.key, this.organization});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // initialize the lawyer provider
    final lawyers = ref.watch(lawyerByOrganizationProvider(organization ?? ''));
    final loading = ref.watch(lawyersProvider).loading;
    final error = ref.watch(lawyersProvider).error;
    final searchQuery = ref.watch(lawyersProvider).searchQuery;
    final organizations = ref.watch(organizationsProvider).organizations;
    final correspondingOrganizations = organizations.where((org) => lawyers.any((lawyer) => lawyer.organizations.contains(org.id))).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CustomAppBar(title: 'Legal Aid Lawyers'),
      body: SafeArea(
        child: Column(
          children: [
            CustomSearchBar(
              hintText: 'Search for lawyers',
              query: searchQuery,
              onChanged: (value) {
                ref.read(lawyersProvider.notifier).setSearchQuery(value);
              },
            ),
            if (loading) ...[
              const Center(child: CircularProgressIndicator()),
            ]
            else if (error != null) ...[
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
              ),
            ]
            else if (lawyers.isEmpty) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.2),
                child: EmptyCard(
                  icon: MingCuteIcons.mgc_user_3_fill,
                  title: 'No Legal Lawyers Available',
                  description: 'Legal lawyers will appear here when available. Check back later for new content!',
                ),
              )
            ] else ...[
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 20, bottom: 24),
                  itemCount: lawyers.length,
                  itemBuilder: (context, index) {
                    final lawyer = lawyers[index];
                    return CustomListItem(
                        leading: lawyer.profileImageUrl != null
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(lawyer.profileImageUrl!),
                                radius: 24,
                              )
                            : null,
                        icon: MingCuteIcons.mgc_user_3_line,
                        title: lawyer.name,
                        subtitle: correspondingOrganizations.isNotEmpty
                            ? correspondingOrganizations.map((org) => org.name).join(', ')
                            : 'No organizations',
                        onTap: () {
                          context.go('${AppRouter.aid}/$organization/${lawyer.id}');
                        }
                    );
                  },
                )
              )
            ],
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}