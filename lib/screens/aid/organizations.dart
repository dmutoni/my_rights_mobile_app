import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_list.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_search_bar.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:my_rights_mobile_app/models/organization.dart';
import 'package:my_rights_mobile_app/providers/organization_provider.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';

class OrganizationScreen extends ConsumerWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizationsAsync = ref.watch(organizationsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CustomAppBar(title: 'Legal Aid Organizations'),
      body: SafeArea(
        child: Column(
          children: [
            const CustomSearchBar(),
            Expanded(
              child: organizationsAsync.when(
                data: (organizations) {
                  if (organizations.isEmpty) {
                    return EmptyCard(
                        icon: MingCuteIcons.mgc_building_1_line,
                        title: 'No Legal Organizations Available',
                        description: 'Legal organizations will appear here when available. Check back later for new content!',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: organizations.length,
                    itemBuilder: (context, index) {
                      final organization = organizations[index];
                      return CustomListItem(
                        icon: MingCuteIcons.mgc_building_1_line,
                        title: organization.name,
                        subtitle: organization.location,
                        onTap: () {},
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}