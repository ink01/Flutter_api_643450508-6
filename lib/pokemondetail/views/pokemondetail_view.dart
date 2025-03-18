import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';

class PokemondetailView extends StatefulWidget {
  final PokemonListItem pokemonListItem;

  const PokemondetailView({super.key, required this.pokemonListItem});

  @override
  State<PokemondetailView> createState() => _PokemondetailViewState();
}

class _PokemondetailViewState extends State<PokemondetailView> {
  Map<String, dynamic>? pokemonData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // โหลดข้อมูลเพิ่มเติมจาก API
  void loadData() async {
    final url = Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/${widget.pokemonListItem.name.toLowerCase()}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        pokemonData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pokemonListItem.name),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pokemonData == null
              ? const Center(child: Text("Error loading data"))
              : Center(
                  // ใช้ Center ครอบ Column
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // จัดให้อยู่ตรงกลางแนวตั้ง
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // จัดให้อยู่ตรงกลางแนวนอน
                      children: [
                        Image.network(
                          pokemonData!['sprites']['front_default'],
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.pokemonListItem.name.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // ประเภท (Type)
                        Text(
                          "Type: ${pokemonData!['types'].map((t) => t['type']['name']).join(', ')}",
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        // ค่าสถานะเริ่มต้น (Base Stats)
                        const Text("Base Stats",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        Column(
                          children: (pokemonData!['stats'] as List).map((stat) {
                            return Text(
                              "${stat['stat']['name'].toUpperCase()}: ${stat['base_stat']}",
                              style: const TextStyle(fontSize: 16),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
