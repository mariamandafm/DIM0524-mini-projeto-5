import 'package:http/http.dart' as http;
import 'dart:convert';

const GOOGLE_API_KEY = 'AIzaSyAXWYWay5ohmHWpJFVl8Yfs3LdENVZt0_U';

class LocationUtil {
  static String generateLocationPreviewImage({
    double? latitude,
    double? longitude,
  }) {
    //https://developers.google.com/maps/documentation/maps-static/overview
    //https://pub.dev/packages/google_maps_flutter
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=13&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$GOOGLE_API_KEY';
  }

  static Future<String> getAddress(double lat, double lng) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GOOGLE_API_KEY';
      final response = await http.get(Uri.parse(url));
      print(json.decode(response.body)['results'][0]['formatted_address']);
      return json.decode(response.body)['results'][0]['formatted_address'];
    } catch (e) {
      print(e);
      return '';
    }
  }

  static Future<Map<String, dynamic>> getCoordinates(String address) async {
    try {
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$GOOGLE_API_KEY';
      final response = await http.get(Uri.parse(url));
      final location = json.decode(response.body)['results'][0]['geometry']['location'];
      return json
          .decode(response.body)['results'][0]['geometry']['location'];
    } catch (e) {
      print(e);
      return {'lat': 0.0, 'lng': 0.0};
    }
  }
}


