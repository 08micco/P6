import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';



class AddMyChargerPage extends StatefulWidget {
  const AddMyChargerPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddMyChargerPageState createState() => _AddMyChargerPageState();
}

Future<void> addHouseholdChargingStation({
  required String longitude,
  required String latitude,
  required String chargerType,
  required String phoneNumber,
}) async {
  try {
    const String url = 'http://127.0.0.1:5000/chargingStation/add';

    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'company_name': "",
        'owner_id': "1",
        'charging_station_type': "Household",
        'longitude': longitude,
        'latitude': latitude,
        'charging_points': "1",
        'charger_type': chargerType,
        'phone_number': phoneNumber,
        'available': true,
      }),
    );

    if (response.statusCode == 201) {
      print('Charging Station added successfully.');
    } else {
      print(
          'Failed to add charging station. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Caught error: $e');
  }
}

class _AddMyChargerPageState extends State<AddMyChargerPage> {
  final _formKey = GlobalKey<FormState>();
  String? longitude;
  String? latitude;
  String? chargerType;
  String? phoneNumber;

  void _submitForm() {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    if (longitude != null && latitude != null && chargerType != null && phoneNumber != null) {
      addHouseholdChargingStation(
        longitude: longitude!,
        latitude: latitude!,
        chargerType: chargerType!,
        phoneNumber: phoneNumber!,
      ).then((_) {
        Navigator.of(context).pop(true);  // Pop with `true` if added successfully
      }).catchError((error) {
        print('Error adding charger: $error');
      });
    } else {
      print('One or more fields are empty. Please check your input.');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.blue, Color.fromARGB(255, 142, 200, 247)]),
            ),
          ),
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text('Add a MyCharger')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                longitude = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter longitude';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
              onSaved: (value) {
                latitude = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter latitude';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Charger Type'),
              onSaved: (value) {
                chargerType = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter charger type';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              onSaved: (value) {
                phoneNumber = value;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
