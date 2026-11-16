import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:latresuas/screens/login_screen.dart';
import 'package:latresuas/screens/main_menu_screen.dart';
import 'package:latresuas/screens/register_screen.dart';
import 'package:latresuas/models/article_model.dart';
import 'package:latresuas/screens/detail_screen.dart';
import 'package:latresuas/services/favorite_service.dart';

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox(FavoriteService.boxName);
  });

  testWidgets('LoginScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('Spaceflight News'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Daftar di sini'), findsOneWidget);
  });

  testWidgets('RegisterScreen renders properly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RegisterScreen(),
      ),
    );

    expect(find.text('Buat Akun Baru'), findsOneWidget);
    expect(find.text('DAFTAR'), findsOneWidget);
  });

  testWidgets('MainMenuScreen renders menu cards and logout button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MainMenuScreen(username: 'tester123'),
      ),
    );

    expect(find.text('Halo, tester123!'), findsOneWidget);
    expect(find.text('News (Articles)'), findsOneWidget);
    expect(find.text('Blogs'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Favourite'), findsOneWidget);
    expect(find.text('LOGOUT'), findsOneWidget);
  });

  testWidgets('DetailScreen renders article information',
      (WidgetTester tester) async {
    final article = ArticleModel(
      id: 999,
      title: 'Misi Baru ke Mars',
      url: 'https://mars.nasa.gov',
      imageUrl: '',
      newsSite: 'NASA',
      summary: 'Penjelasan misi baru menuju Mars.',
      publishedAt: '2026-11-16T12:00:00Z',
      authors: ['Dr. John Doe'],
      category: 'articles',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DetailScreen(article: article),
      ),
    );

    expect(find.text('Misi Baru ke Mars'), findsOneWidget);
    expect(find.text('Dr. John Doe'), findsOneWidget);
    expect(find.text('Penjelasan misi baru menuju Mars.'), findsOneWidget);
    expect(find.text('BACA SITUS RESMI LENGKAP'), findsOneWidget);
  });
}
