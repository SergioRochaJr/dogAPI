import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dog Selector',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DogSelector(),
    );
  }
}

class DogSelector extends StatefulWidget {
  @override
  _DogSelectorState createState() => _DogSelectorState();
}

class _DogSelectorState extends State<DogSelector> {
  List<String> breeds = [];
  String? selectedBreed;
  String? dogImageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchBreeds();
  }

  Future<void> fetchBreeds() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse("https://dog.ceo/api/breeds/list/all");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final Map<String, dynamic> breedMap = data['message'];

      setState(() {
        breeds = breedMap.keys.toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar as raças. Tente novamente.')),
      );
    }
  }

  Future<void> fetchDogImage(String breed) async {
    setState(() {
      isLoading = true;
      dogImageUrl = null;
    });

    final url = Uri.parse("https://dog.ceo/api/breed/$breed/images/random");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        dogImageUrl = data['message'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar a imagem. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Veja fotos de doguinhos!'),
      ),
      body: breeds.isEmpty
          ? Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : Text('Erro ao carregar raças.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Selecione uma raça'),
                    value: selectedBreed,
                    items: breeds.map((breed) {
                      return DropdownMenuItem(
                        value: breed,
                        child:
                            Text(breed[0].toUpperCase() + breed.substring(1)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBreed = value;
                      });
                      fetchDogImage(value!);
                    },
                  ),
                  SizedBox(height: 20),
                  if (isLoading)
                    CircularProgressIndicator()
                  else if (dogImageUrl != null) ...[
                    Image.network(
                      dogImageUrl!,
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedBreed != null) {
                          fetchDogImage(selectedBreed!);
                        }
                      },
                      child: Text('Quero outra foto!'),
                    ),
                  ] else
                    Text(
                      'Selecione uma raça para ver uma imagem!',
                      style: TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),
    );
  }
}
