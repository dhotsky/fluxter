import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fluxter/app/config/app_module.dart';
import 'package:fluxter/app/fluxter_app.dart';
import 'package:fluxter/core/chucker/chucker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HTTP network inspector (Chucker)
  Chucker.enabled = true;
  Chucker.showInRelease = false;

  // Initialize services
  await AppModule.initService();

  runApp(const ProviderScope(child: FluxterApp()));
}
