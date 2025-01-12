import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:f09_recursos_nativos/models/place_dto.dart';
import 'package:f09_recursos_nativos/models/place_location.dart';
import 'package:f09_recursos_nativos/firebase/firebase_api.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/place.dart';
import '../utils/db_util.dart';

import 'package:http/http.dart' as http;

class PlacesModel with ChangeNotifier {
  List<Place> _items = [];
  final _baseUrl = 'https://dim0524-default-rtdb.firebaseio.com/';

  List<Place> get items {
    return [..._items];
  }

  int get itemsCount {
    return _items.length;
  }

  Place itemByIndex(int index) {
    return _items[index];
  }

  Future<void> saveToFirebase(PlaceDto place) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/places.json'),
        body: jsonEncode(place.toJson()),
      );
    } catch (e) {
      print("Erro ao salvar os dados: $e");
    }
  }

  void addPlace(String title, File image, String contact, String email,
      double latitude, double longitude, String address) async {
    print("Adicionar");
    final url_image = await uploadImageToFirebase(image);
    print(url_image);

    final newPlaceDto = PlaceDto(
      id: Random().nextDouble().toString(),
      title: title,
      location: PlaceLocation(
          latitude: latitude, longitude: longitude, address: address),
      image: url_image,
      contact: contact,
      email: email,
    );

    final newPlace = Place(
      id: Random().nextDouble().toString(),
      title: title,
      location: PlaceLocation(
          latitude: latitude, longitude: longitude, address: address),
      image: image,
      contact: contact,
      email: email,
    );

    saveToFirebase(newPlaceDto);

    _items.add(newPlace);
    DbUtil.insert('places', {
      'id': newPlace.id,
      'title': newPlace.title,
      'image': image.path,
      'contact': newPlace.contact,
      'email': newPlace.email,
      'latitude': newPlace.location?.latitude ?? '',
      'longitude': newPlace.location?.longitude ?? '',
      'address': newPlace.location?.address ?? '',
    });

    await syncPlaces(_items);
    notifyListeners();
  }

  Future<void> loadPlaces() async {
    try {
      final places = await fetchPlaces();
      _items = places;


      notifyListeners();
    } catch (e) {
      print("Erro ao carregar os dados: $e");
    }
  }

  Future<void> deletePlace(String id) async {
  try {
    final url = Uri.parse('https://dim0524-default-rtdb.firebaseio.com/places/$id.json');
    final firebaseResponse = await http.delete(url);

    if (firebaseResponse.statusCode == 200) {
      print('Item removido do Firebase com sucesso.');

      final updatedPlaces = await fetchPlaces();
      await syncPlaces(updatedPlaces);
    } else {
      print('Erro ao remover item do Firebase: ${firebaseResponse.body}');
    }

    notifyListeners();
  } catch (e) {
    print('Erro ao remover e sincronizar o item: $e');
  }
}

}

Future<List<Place>> fetchPlaces() async {
  List<Place> places = [];
  try {
    final response = await http.get(Uri.parse('https://dim0524-default-rtdb.firebaseio.com/places.json'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      final appDir = await getApplicationDocumentsDirectory();

      for (var entry in data.entries) {
        final key = entry.key;
        final value = entry.value;

        final imageUrl = value['image'];
        final localImagePath = '${appDir.path}/$key.jpg';
        final localImageFile = File(localImagePath);

        if (!await localImageFile.exists()) {
          final imageResponse = await http.get(Uri.parse(imageUrl));
          if (imageResponse.statusCode == 200) {
            await localImageFile.writeAsBytes(imageResponse.bodyBytes);
          }
        }
        places.add(Place(
          id: key,
          title: value['title'],
          image: localImageFile,
          location: PlaceLocation(
            latitude: value['location']['latitude'],
            longitude: value['location']['longitude'],
            address: value['location']['address'],
          ),
          contact: value['contact'],
          email: value['email'],
        ));
      }
    }
    return places;
  } catch (e) {
    print('Erro ao carregar os dados: $e');
    return [];
  }
}


Future<void> syncPlaces(List<Place> places) async {
  try {
    final appDir = await getApplicationDocumentsDirectory();

    final db = await DbUtil.openDatabaseConnection();

    await db.delete('places');

    final limitedPlaces = places.take(10).toList();

    for (var place in limitedPlaces) {
      final localImagePath = '${appDir.path}/${place.id}.jpg';
      final localImageFile = await downloadImageFromFirebase(place.image.path);

      if (localImageFile != null) {
        await DbUtil.insert('places', {
          'id': place.id,
          'title': place.title,
          'image': localImagePath,
          'contact': place.contact,
          'email': place.email,
          'latitude': place.location?.latitude ?? '',
          'longitude': place.location?.latitude ?? '',
          'address': place.location?.latitude ?? '',
        });
      }
    }
    print('Sincronização concluída com sucesso.');
  } catch (e) {
    print('Erro ao sincronizar os dados: $e');
  }
}