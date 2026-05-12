import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/family_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://uqysyodgyuffmaypybdb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVxeXN5b2RneXVmZm1heXB5YmRiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1NTczODAsImV4cCI6MjA5NDEzMzM4MH0.ltr-gnONtgx5G5hyX3L9KlyjF4Uutxk1IkmjOqUS6Lk',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
      ],
      child: const FamilyRegistryApp(),
    ),
  );
}
