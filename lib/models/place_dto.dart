import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:f09_recursos_nativos/models/place_location.dart';

class PlaceDto {
  final String id;
  final String title;
  final PlaceLocation? location;
  final String image;
  final String contact;
  final String email;

  PlaceDto({
    required this.id,
    required this.title,
    this.location,
    required this.image,
    required this.contact,
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location?.toJson(),
      'image': image,
      'contact': contact,
      'email': email,
    };
  }

  factory PlaceDto.fromJson(Map<String, dynamic> json) {
    return PlaceDto(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] != null
          ? PlaceLocation.fromJson(json['location'])
          : null,
      image: json['image'] as String,
      contact: json['contact'] as String,
      email: json['email'] as String,
    );
  }
}
