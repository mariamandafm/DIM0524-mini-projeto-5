import 'package:f09_recursos_nativos/firebase/firebase_api.dart';
import 'package:f09_recursos_nativos/provider/places_model.dart';
import 'package:f09_recursos_nativos/screens/place_detail.screen.dart';
import 'package:f09_recursos_nativos/screens/login_screen.dart';
import 'package:f09_recursos_nativos/screens/places_manager_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/place_form_screen.dart';
import 'screens/places_list_screen.dart';
import 'utils/app_routes.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase/firebase_api.dart';
import 'package:firebase_storage/firebase_storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: 'AIzaSyBtbetBD55f5GOX6ma5JL4bfsNbHuS-fvY',
    appId: '1:357524149221:android:cd12ec36cdbac9491c550c',
    messagingSenderId: '918234394218',
    projectId: 'dim0524',
    storageBucket: 'dim0524.firebasestorage.app',
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<bool> checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      final email = prefs.getString('email');
      print('Usuário já está logado com e-mail: $email');
    }
    return isLoggedIn;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlacesModel(),
      child: MaterialApp(
        title: 'My Places',
        theme: ThemeData().copyWith(
            colorScheme: ThemeData().colorScheme.copyWith(
                  primary: Colors.indigo,
                  secondary: Colors.amber,
                )),
        home: FutureBuilder<bool>(
          future: checkIfLoggedIn(),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data == true) {
              return PlacesListScreen();
            } else {
              return LoginPage();
            }
          },
        ),
        routes: {
          AppRoutes.PLACES_LIST: (ctx) => PlacesListScreen(),
          AppRoutes.PLACE_FORM: (ctx) => PlaceFormScreen(),
          AppRoutes.PLACE_DETAIL: (ctx) => PlaceDetailScreen(),
          AppRoutes.PLACE_MANAGER: (ctx) => PlacesManagerScreen(),
          AppRoutes.LOGIN: (ctx) => LoginPage(),
        },
      ),
    );
  }
}
