import 'package:flutter/material.dart';
import 'package:pokemondex/pokemondetail/views/pokemondetail_view.dart';
import 'package:pokemondex/pokemonlist/models/pokemonlist_response.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  State<PokemonList> createState() => _PokemonListState();
}

class _PokemonListState extends State<PokemonList> {
  final List<PokemonListItem> _pokemonList = [];
  int _offset = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ฟังก์ชันโหลดข้อมูลจาก API
  Future<void> loadData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://pokeapi.co/api/v2/pokemon?offset=$_offset&limit=$_limit'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<PokemonListItem> newPokemonList = (data['results'] as List)
            .map((item) => PokemonListItem.fromJson(item))
            .toList();

        setState(() {
          _offset += _limit;
          _pokemonList.addAll(newPokemonList);
          _hasMore =
              newPokemonList.isNotEmpty; // เช็คว่ามีข้อมูลเหลือให้โหลดหรือไม่
        });
      } else {
        throw Exception('Failed to load Pokemon');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  // ฟังก์ชันตรวจจับการเลื่อนหน้าจอ
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading) {
      loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemon List'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _pokemonList.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _pokemonList.length) {
            return const Center(child: CircularProgressIndicator());
          } else {
            final PokemonListItem pokemon = _pokemonList[index];

            // ดึง ID จาก URL ของ API
            final uri = Uri.parse(pokemon.url);
            final segments = uri.pathSegments;
            final pokemonId = segments[segments.length - 2];

            final imageUrl =
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png";

            return ListTile(
              leading: Image.network(imageUrl, width: 50, height: 50),
              title: Text(pokemon.name),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemondetailView(
                    pokemonListItem: pokemon,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
