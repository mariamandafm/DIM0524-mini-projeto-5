import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/map_screen.dart';
import '../utils/location_util.dart';

class LocationInput extends StatefulWidget {
  final Function onSelectPlace;

  LocationInput(this.onSelectPlace);

  @override
  _LocationInputState createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  Future<void> _getCurrentUserLocation() async {
    final locData =
        await Location().getLocation(); //pega localização do usuário
    print(locData.latitude);
    print(locData.longitude);
    widget.onSelectPlace(locData.latitude, locData.longitude);

    //CARREGANDO NO MAPA

    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: locData.latitude, longitude: locData.longitude);

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  Future<void> _selectOnMap() async {
    final LatLng selectedPosition = await Navigator.of(context).push(
      MaterialPageRoute(
          fullscreenDialog: true, builder: ((context) => MapScreen())),
    );

    if (selectedPosition == null) return;

    print(selectedPosition.latitude);
    print(selectedPosition.longitude);
    widget.onSelectPlace(selectedPosition.latitude, selectedPosition.longitude);

    final staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
        latitude: selectedPosition.latitude,
        longitude: selectedPosition.longitude);

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _paisController = TextEditingController();

  Future<void> _getCoordinatesFromAddress() async {
    print("CHamando");
    final address = '${_ruaController.text}, ${_numeroController.text}, ${_bairroController.text}, ${_cidadeController.text}, ${_estadoController.text}, ${_paisController.text}';
    final coordinates = await LocationUtil.getCoordinates(address);

    print(coordinates);

    widget.onSelectPlace(coordinates['lat'], coordinates['lng']);

    final String staticMapImageUrl = LocationUtil.generateLocationPreviewImage(
      latitude: coordinates['lat'],
      longitude: coordinates['lng'],
    );

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  void _openAddressForm() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Material(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                TextField(
                  controller: _ruaController,
                  decoration: InputDecoration(labelText: 'Rua'),
                ),
                TextField(
                  controller: _numeroController,
                  decoration: InputDecoration(labelText: 'Número'),
                ),
                TextField(
                  controller: _bairroController,
                  decoration: InputDecoration(labelText: 'Bairro'),
                ),
                TextField(
                  controller: _cidadeController,
                  decoration: InputDecoration(labelText: 'Cidade'),
                ),
                TextField(
                  controller: _estadoController,
                  decoration: InputDecoration(labelText: 'Estado'),
                ),
                TextField(
                  controller: _paisController,
                  decoration: InputDecoration(labelText: 'País'),
                ),
                ElevatedButton(
                  onPressed: _getCoordinatesFromAddress,
                  child: Text('Salvar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: _previewImageUrl == null
              ? Text('Localização não informada!')
              : Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(Icons.location_on),
              label: Text('Localização atual'),
              onPressed: _getCurrentUserLocation,
            ),
            TextButton.icon(
              icon: Icon(Icons.map),
              label: Text('Selecione no Mapa'),
              onPressed: _selectOnMap,
            ),
          ],
        ),
        TextButton.icon(
          icon: Icon(Icons.edit_location),
          label: Text('Digitar endereço'),
          onPressed: _openAddressForm,
        ),
      ],
    );
  }
}
