// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddMyChargerPage extends StatefulWidget {
  const AddMyChargerPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddMyChargerPageState createState() => _AddMyChargerPageState();
}

class _AddMyChargerPageState extends State<AddMyChargerPage> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? subtitle;
  String? description;
  String? userId;
  String? longitude;
  String? latitude;
  String? chargerType;
  String? phoneNumber;
  String? address;
  bool isAddressEntered = false;

  final List<String> chargerTypes = [
    'Type 2 (Mennekes)',
    'SAE J1772 (J-plug)',
    'CCS (Combined Charging System)',
    'CHAdeMO',
    'Tesla'
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  void _fetchUserId() async {
    userId = await _storage.read(key: "userId");
    setState(() {});
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (userId == null) {
        print('User ID is not loaded. Please check your login status.');
        return;
      }

      if (title == null || title!.isEmpty) {
        print('Title is required. Please enter a title.');
        return;
      }

      if (isAddressEntered && chargerType != null && phoneNumber != null) {
        var coords = await convertAddressToCoordinates(address!);
        if (coords != null) {
          latitude = coords['latitude'];
          longitude = coords['longitude'];
        }
      }
      if (longitude != "" &&
          latitude != "" &&
          chargerType != null &&
          phoneNumber != null) {
        await addHouseholdChargingStation(
            address: address,
            longitude: longitude!,
            latitude: latitude!,
            chargerType: chargerType!,
            phoneNumber: phoneNumber!,
            title: title!,
            subtitle: subtitle,
            description: description);
        Navigator.of(context).pop(true);
      } else {
        print('One or more fields are missing. Please check your input.');
      }
    }
  }

  Future<Map<String, dynamic>?> convertAddressToCoordinates(
      String address) async {
    final uri =
        Uri.parse('http://127.0.0.1:5000/getCoordinates?address=$address');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null &&
            data['data']['latitude'] != null &&
            data['data']['longitude'] != null) {
          return {
            'latitude': data['data']['latitude'],
            'longitude': data['data']['longitude']
          };
        }
      } else {
        print(
            'Failed to load coordinates. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Caught error: $e');
    }
    return null;
  }

  Future<void> addHouseholdChargingStation({
    required String longitude,
    required String latitude,
    required String chargerType,
    required String phoneNumber,
    required String title,
    String? address,
    String? subtitle,
    String? description,
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
          'owner_id': userId,
          'title': title,
          'subtitle': subtitle,
          'description': description,
          'charging_station_type': "Household",
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
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
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Title is required';
                }
                return null;
              },
              onSaved: (value) => title =
                  value, // Ensure you define this variable in your state
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Subtitle'),
              onSaved: (value) => subtitle =
                  value, // Ensure you define this variable in your state
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onSaved: (value) => description =
                  value, // Ensure you define this variable in your state
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Address'),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() {
                    address = value;
                    isAddressEntered = true;
                    longitude = null;
                    latitude = null;
                  });
                } else {
                  setState(() {
                    isAddressEntered = false;
                  });
                }
              },
              validator: (value) {
                if (value!.isEmpty && !isAddressEntered) {
                  return 'Please enter an address or coordinates';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Latitude'),
              keyboardType: TextInputType.number,
              enabled: !isAddressEntered,
              onSaved: (value) {
                latitude = value;
              },
              validator: (value) {
                if (value!.isEmpty && !isAddressEntered) {
                  return 'Please enter latitude';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Longitude'),
              keyboardType: TextInputType.number,
              enabled: !isAddressEntered,
              onSaved: (value) {
                longitude = value;
              },
              validator: (value) {
                if (value!.isEmpty && !isAddressEntered) {
                  return 'Please enter longitude';
                }
                return null;
              },
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: 'Charger Type'),
              items: chargerTypes.map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  chargerType = newValue;
                });
              },
              value: chargerType,
              validator: (value) {
                if (value == null) {
                  return 'Please select a charger type';
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
