import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fluxter/app/config/app_module.dart';
import 'package:fluxter/app/fluxter_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await AppModule.initService();

  runApp(const ProviderScope(child: FluxterApp()));
}
