import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

void main() {
   runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp()
    ));
  
}

class ImageModel {
  final List message;

  var imgRange = List;
  ImageModel({required this.message});
  factory ImageModel.fromJson(dynamic json) {
    return ImageModel(message: json['message'] as List);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<ImageModel> getImages() async {
    final response =
        await http.get(Uri.parse('https://dog.ceo/api/breed/husky/images'));
    if (response.statusCode == 200) {
      return ImageModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Fix: Something went wrong!!");
    }
  }

  late Future<ImageModel> image;

  @override
  void initState() {
    super.initState();
    image = getImages();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: FutureBuilder<ImageModel>(
              future: image,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  List imageRange = snapshot.data!.message.sublist(0, 10);
                  int imageRangelen = imageRange.length;
                  return ListView.builder(
                      itemCount: imageRangelen,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Card(
                              margin: const EdgeInsets.all(8.0),
                              elevation: 4,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6))),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Image.network(
                                        snapshot.data!.message[index]),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text("Adopt:"),
                                          ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2))),
                                              onPressed: () {
                                                setState(() {
                                                  _handlePayment();
                                                });
                                              },
                                              child: const Text("Pay"))
                                        ])
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      });
                } else {
                  print("Error: ${snapshot.error}");
                  throw Exception("Could not fetch data");
                }
              }),
        ),
      ),
    );
  }

  _handlePayment() async {
    final Customer customer = Customer(
        name: 'Bob Ram',
        phoneNumber: '+2348123456789',
        email: 'bob@example.com');
    final Flutterwave flutterwave = Flutterwave(
      context: context,
      publicKey: "Your_FLW_PUB-KEY",
      currency: "NGN",
      txRef: const Uuid().v1(),
      amount: "2500",
      redirectUrl: 'Your_RDir_URL',
      customer: customer,
      paymentOptions: "card",
      customization: Customization(title: "My Payment"),
      isTestMode: true,
    );
    final ChargeResponse response = await flutterwave.charge();
    if (response != null) {
      print("${response.toJson()}");
    } else {
      print("no response");
    }
  }
}
