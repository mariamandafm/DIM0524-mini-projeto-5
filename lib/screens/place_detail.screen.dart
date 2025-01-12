import 'package:f09_recursos_nativos/models/place.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Place place = ModalRoute.of(context)!.settings.arguments as Place;

    void makeCall(String contact) async {
      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: contact,
      );
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'Could not launch $phoneUri';
      }
    }

    void sendMail(String email) async {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch $emailUri';
      }
    }

    void openMap(double latitude, double longitude) async {
      final Uri mapUri = Uri(
        scheme: 'geo',
        path: '$latitude,$longitude',
      );
      if (await canLaunchUrl(mapUri)) {
        await launchUrl(mapUri);
      } else {
        throw 'Could not launch $mapUri';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Lugar', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
      ),
      body: Column(
        children: [
          Container(
            height: 250,
            width: double.infinity,
            child: Image.file(
              place.image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          SizedBox(height: 10),
          Text(
            place.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                place.contact,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              IconButton(
                icon: Icon(Icons.phone, color: Color.fromRGBO(84, 155, 43, 1)),
                onPressed: () {
                  makeCall(place.contact);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                place.email,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              IconButton(
                icon: Icon(Icons.email, color: Color.fromRGBO(84, 155, 43, 1)),
                onPressed: () {
                  sendMail(place.email);
                },
              ),
            ],
          ),
          Divider(),
          SizedBox(height: 10),  
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(Icons.location_on),
                Expanded(
                  child: Text(
                    'Endereço: ${place.location!.address}',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                openMap(place.location!.latitude, place.location!.longitude);
              }, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ver no Mapa'),
                  Icon(Icons.map),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}