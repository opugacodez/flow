import 'package:flow/providers/catalog_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_widget.dart';
import 'providers/auth_provider.dart';

void main() {
  runApp(
    MultiProvider(providers
      : [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CatalogProvider()),
      ],
      child: const AppWidget(),
    ),
  );
}