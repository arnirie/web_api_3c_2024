import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GetUsersScreen extends StatelessWidget {
  const GetUsersScreen({super.key});

  Future<List<dynamic>> getUsers() async {
    //http://192.168.103.66/macabulos_labwork/getusers.php
    List<dynamic> data = [];
    var url = Uri.http('192.168.103.66', 'macabulos_labwork/getusers.php');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
      print(data);
    }
    return data;
  }

  Future<void> register() async {
    var url = Uri.http('192.168.103.66', 'macabulos_labwork/register.php');
    var response = await http.post(url, body: {
      'username': 'controller',
      'password': '123',
      'fullname': 'full name',
    });
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data['status']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [IconButton(onPressed: register, icon: Icon(Icons.add))],
      ),
      body: FutureBuilder(
          future: getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == null) {
              return Center(
                child: Text('No Data'),
              );
            }
            var data = snapshot.data!;
            return ListView.builder(
              itemBuilder: (_, index) {
                return Card(
                    child: ListTile(title: Text(data[index]['fullname'])));
              },
              itemCount: data.length,
            );
          }),
    );
  }
}
