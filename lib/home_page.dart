import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'pokemon_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Pokemon> pokemonList = [];
  List<Pokemon> filteredPokemonList = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPokemonList();
  }

  Future<void> fetchPokemonList() async {
    try {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=151'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        List<Pokemon> tempList = [];
        for (int i = 0; i < results.length; i++) {
          final pokemon = Pokemon(
            id: i + 1,
            name: results[i]['name'],
            url: results[i]['url'],
            imageUrl:
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${i + 1}.png',
          );
          tempList.add(pokemon);
        }

        setState(() {
          pokemonList = tempList;
          filteredPokemonList = tempList;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching Pokemon: $e');
    }
  }

  void filterPokemon(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPokemonList = pokemonList;
      } else {
        filteredPokemonList = pokemonList
            .where(
              (pokemon) =>
                  pokemon.name.toLowerCase().contains(query.toLowerCase()) ||
                  pokemon.id.toString().contains(query),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[50],
      appBar: AppBar(
        title: const Text(
          'Pokédex',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red[600],
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[600],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: TextField(
              controller: searchController,
              onChanged: filterPokemon,
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  )
                : filteredPokemonList.isEmpty
                ? const Center(
                    child: Text(
                      'No Pokémon found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: filteredPokemonList.length,
                    itemBuilder: (context, index) {
                      final pokemon = filteredPokemonList[index];
                      return PokemonCard(
                        pokemon: pokemon,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PokemonDetailPage(pokemonId: pokemon.id),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class Pokemon {
  final int id;
  final String name;
  final String url;
  final String imageUrl;

  Pokemon({
    required this.id,
    required this.name,
    required this.url,
    required this.imageUrl,
  });
}

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const PokemonCard({Key? key, required this.pokemon, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[100]!],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'pokemon-${pokemon.id}',
                child: Image.network(
                  pokemon.imageUrl,
                  height: 80,
                  width: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: const Icon(
                        Icons.catching_pokemon,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '#${pokemon.id.toString().padLeft(3, '0')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                pokemon.name.substring(0, 1).toUpperCase() +
                    pokemon.name.substring(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
