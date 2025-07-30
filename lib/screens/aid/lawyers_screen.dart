import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_list.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_search_bar.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_app_bar.dart';
import 'package:my_rights_mobile_app/provider/lawyer_provider.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:my_rights_mobile_app/shared/widgets/empty_card.dart';
import 'package:go_router/go_router.dart';
import 'package:my_rights_mobile_app/core/router/app_router.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_bottom_navbar.dart';

class OrganizationScreen extends ConsumerWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lawyersAsync = ref.watch(lawyersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      appBar: CustomAppBar(title: 'Legal Aid Lawyers'),
      body: SafeArea(
        child: Column(
          children: [
            CustomSearchBar(onChanged: (value) {
              ref.read(searchLawyerProvider.notifier).state = value;
            }),
            Expanded(
              child: lawyersAsync.when(
                data: (lawyers) {
                  if (lawyers.isEmpty) {
                    return EmptyCard(
                      icon: MingCuteIcons.mgc_building_1_line,
                      title: 'No Legal Lawyers Available',
                      description: 'Legal lawyers will appear here when available. Check back later for new content!',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(left: 20, bottom: 24),
                    itemCount: lawyers.length,
                    itemBuilder: (context, index) {
                      final lawyer = lawyers[index];
                      return CustomListItem(
                          icon: MingCuteIcons.mgc_building_1_line,
                          title: lawyer.name,
                          subtitle: lawyer.organization,
                          onTap: () {
                            context.go('${AppRouter.aid}/${lawyer.id}');
                          }
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
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}