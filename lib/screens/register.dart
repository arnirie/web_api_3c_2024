import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final api = 'psgc.gitlab.io';

  Map<String, String> regions = {};
  Map<String, String> provinces = {};
  Map<String, String> cities = {};
  bool isRegionsLoaded = false;
  bool isProvincesLoaded = false;
  bool isCitiesLoaded = false;
  var provinceController = TextEditingController();
  var citiesController = TextEditingController();

  void callAPI() async {
    var url = Uri.https(api, 'api/island-groups/');
    var response = await http.get(url);
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      print(data[0]['name']);
    }
  }

  @override
  void initState() {
    super.initState();
    loadRegions();
  }

  Future<void> loadRegions() async {
    var url = Uri.https(api, 'api/regions/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      //List to Map<string, String>
      data.forEach((element) {
        var map = element as Map;
        regions.addAll({map['code']: map['regionName']});
      });
    }
    setState(() {
      isRegionsLoaded = true;
    });
  }

  Future<void> loadProvinces(String regionCode) async {
    provinces.clear();
    var url = Uri.https(api, 'api/regions/$regionCode/provinces/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      //List to Map<string, String>
      data.forEach((element) {
        var map = element as Map;
        provinces.addAll({map['code']: map['name']});
      });
    }
    setState(() {
      isProvincesLoaded = true;
    });
  }

  Future<void> loadCities(String provinceCode) async {
    cities.clear();
    var url =
        Uri.https(api, 'api/provinces/$provinceCode/cities-municipalities/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      //List to Map<string, String>
      data.forEach((element) {
        var map = element as Map;
        cities.addAll({map['code']: map['name']});
      });
    }
    setState(() {
      isCitiesLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const screenPadding = 12.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(screenPadding),
        child: Column(
          children: [
            if (isRegionsLoaded)
              DropdownMenu(
                width: width - screenPadding * 2,
                dropdownMenuEntries: regions.entries
                    .map(
                      (entry) => DropdownMenuEntry(
                          value: entry.key, label: entry.value),
                    )
                    .toList(),
                onSelected: (value) {
                  print(value);
                  provinceController.clear();
                  loadProvinces(value ?? '');
                },
              )
            else
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (isProvincesLoaded)
              DropdownMenu(
                controller: provinceController,
                width: width - screenPadding * 2,
                dropdownMenuEntries: provinces.entries
                    .map(
                      (entry) => DropdownMenuEntry(
                          value: entry.key, label: entry.value),
                    )
                    .toList(),
                onSelected: (value) {
                  print(value);
                  citiesController.clear();
                  loadCities(value ?? '');
                },
              ),
            if (isCitiesLoaded)
              DropdownMenu(
                controller: citiesController,
                width: width - screenPadding * 2,
                dropdownMenuEntries: cities.entries
                    .map(
                      (entry) => DropdownMenuEntry(
                          value: entry.key, label: entry.value),
                    )
                    .toList(),
                onSelected: (value) {
                  print(value);
                },
              ),
          ],
        ),
      ),
    );
  }
}
