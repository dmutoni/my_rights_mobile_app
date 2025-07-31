import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_rights_mobile_app/shared/widgets/custom_list.dart';

void main() {
  group('CustomListItem Widget Tests', () {
    testWidgets('should display title and icon', (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Title';
      const testIcon = Icons.home;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomListItem(
              icon: testIcon,
              title: testTitle,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
    });

    testWidgets('should display subtitle when provided',
        (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Title';
      const testSubtitle = 'Test Subtitle';
      const testIcon = Icons.home;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomListItem(
              icon: testIcon,
              title: testTitle,
              subtitle: testSubtitle,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      expect(find.text(testSubtitle), findsOneWidget);
    });

    testWidgets('should not display subtitle when null',
        (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Title';
      const testIcon = Icons.home;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomListItem(
              icon: testIcon,
              title: testTitle,
              subtitle: null,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);
      // Should only find one Text widget (the title)
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('should display status indicator when statusColor is provided',
        (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Title';
      const testIcon = Icons.home;
      const testStatusColor = Colors.red;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomListItem(
              icon: testIcon,
              title: testTitle,
              statusColor: testStatusColor,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testTitle), findsOneWidget);

      // Find the status indicator container
      final containerFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == testStatusColor,
      );
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('should trigger onTap callback when tapped',
        (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Title';
      const testIcon = Icons.home;
      bool wasTapped = false;

      void onTapCallback() {
        wasTapped = true;
      }

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomListItem(
              icon: testIcon,
              title: testTitle,
              onTap: onTapCallback,
            ),
          ),
        ),
      );

      // Tap the widget
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(wasTapped, isTrue);
    });

    testWidgets('should not crash when onTap is null',
        (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Title';
      const testIcon = Icons.home;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomListItem(
              icon: testIcon,
              title: testTitle,
              onTap: null,
            ),
          ),
        ),
      );

      // Tap the widget (should not crash)
      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Assert
      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('should have correct icon styling',
        (WidgetTester tester) async {
      // Arrange
      const testTitle = 'Test Title';
      const testIcon = Icons.star;

      // Act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomListItem(
              icon: testIcon,
              title: testTitle,
            ),
          ),
        ),
      );

      // Assert
      final iconWidget = tester.widget<Icon>(find.byIcon(testIcon));
      expect(iconWidget.size, equals(24));
      expect(iconWidget.color, equals(Colors.black87));
    });
  });

  group('CustomList Widget Tests', () {
    testWidgets('should display multiple CustomListItem widgets',
        (WidgetTester tester) async {
      // Arrange
      final items = [
        const CustomListItem(
          icon: Icons.home,
          title: 'Home',
          subtitle: 'Home subtitle',
        ),
        const CustomListItem(
          icon: Icons.work,
          title: 'Work',
          subtitle: 'Work subtitle',
        ),
        const CustomListItem(
          icon: Icons.settings,
          title: 'Settings',
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomList(items: items),
          ),
        ),
      );

      // Assert
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Home subtitle'), findsOneWidget);
      expect(find.text('Work subtitle'), findsOneWidget);
      expect(find.byType(CustomListItem), findsNWidgets(3));
    });

    testWidgets('should display empty list when no items provided',
        (WidgetTester tester) async {
      // Arrange
      final items = <CustomListItem>[];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomList(items: items),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomListItem), findsNothing);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should maintain proper spacing between items',
        (WidgetTester tester) async {
      // Arrange
      final items = [
        const CustomListItem(
          icon: Icons.home,
          title: 'Item 1',
        ),
        const CustomListItem(
          icon: Icons.work,
          title: 'Item 2',
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomList(items: items),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomListItem), findsNWidgets(2));
      expect(find.byType(Column),
          findsNWidgets(3)); // One for CustomList, two for CustomListItems

      // Check that Padding widgets are applied
      final paddingWidgets = find.byWidgetPredicate(
        (widget) =>
            widget is Padding &&
            widget.padding == const EdgeInsets.symmetric(vertical: 4.0),
      );
      expect(paddingWidgets, findsNWidgets(2));
    });

    testWidgets('should handle single item correctly',
        (WidgetTester tester) async {
      // Arrange
      final items = [
        const CustomListItem(
          icon: Icons.home,
          title: 'Single Item',
          subtitle: 'Only item',
          statusColor: Colors.blue,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomList(items: items),
          ),
        ),
      );

      // Assert
      expect(find.text('Single Item'), findsOneWidget);
      expect(find.text('Only item'), findsOneWidget);
      expect(find.byType(CustomListItem), findsOneWidget);
    });

    testWidgets('should preserve onTap functionality for all items',
        (WidgetTester tester) async {
      // Arrange
      int tappedIndex = -1;

      final items = [
        CustomListItem(
          icon: Icons.home,
          title: 'Item 1',
          onTap: () => tappedIndex = 0,
        ),
        CustomListItem(
          icon: Icons.work,
          title: 'Item 2',
          onTap: () => tappedIndex = 1,
        ),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomList(items: items),
          ),
        ),
      );

      // Tap the second item
      await tester.tap(find.text('Item 2'));
      await tester.pump();

      // Assert
      expect(tappedIndex, equals(1));
    });
  });
}
