import 'dart:io';

import 'package:f09_recursos_nativos/provider/places_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_routes.dart';

class PlacesManagerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Gerenciar Meus Lugares', style: TextStyle(color: Colors.white),),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.PLACE_FORM);
            },
            icon: Icon(Icons.add, color: Colors.white,),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Text(
                'Recursos Nativos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/places-list');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Sair'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.of(context).pushReplacementNamed('/login');
              },
            )
          ],
        ),
      ),
      body: FutureBuilder(
        future: Provider.of<PlacesModel>(context, listen: false).loadPlaces(),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : Consumer<PlacesModel>(
                child: Center(
                  child: Text('Nenhum local'),
                ),
                builder: (context, places, child) =>
                    places.itemsCount == 0
                        ? child!
                        : ListView.builder(
                            itemCount: places.itemsCount,
                            itemBuilder: (context, index) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: FileImage(
                                    places.itemByIndex(index).image),
                              ),
                              title: Text(places.itemByIndex(index).title),
                              trailing: Wrap(
                                spacing: 12, // space between two icons
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.PLACE_FORM,
                                        arguments: places.itemByIndex(index),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: Text('Excluir Lugar'),
                                          content: Text('Tem certeza?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Não'),
                                              onPressed: () {
                                                Navigator.of(ctx).pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Sim'),
                                              onPressed: () {
                                                Provider.of<PlacesModel>(context,
                                                        listen: false)
                                                    .deletePlace(
                                                        places.itemByIndex(index).id);
                                                Navigator.of(ctx).pop(true);
                                              },
                                            ),
                                          ],
                                        ),
                                      ).then((value) {
                                        if (value) {
                                          // Provider.of<PlacesModel>(context, listen: false)
                                          //     .deletePlace(places.itemByIndex(index).id);
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
              ),
      ),
    );
  }
}
