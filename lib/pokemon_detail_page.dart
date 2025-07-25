import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonDetailPage extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailPage({Key? key, required this.pokemonId})
    : super(key: key);

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage>
    with TickerProviderStateMixin {
  PokemonDetail? pokemonDetail;
  PokemonSpecies? pokemonSpecies;
  bool isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchPokemonData();
  }

  Future<void> fetchPokemonData() async {
    try {
      // Fetch basic Pokemon data
      final pokemonResponse = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/${widget.pokemonId}'),
      );

      // Fetch species data for description
      final speciesResponse = await http.get(
        Uri.parse(
          'https://pokeapi.co/api/v2/pokemon-species/${widget.pokemonId}',
        ),
      );

      if (pokemonResponse.statusCode == 200 &&
          speciesResponse.statusCode == 200) {
        final pokemonData = json.decode(pokemonResponse.body);
        final speciesData = json.decode(speciesResponse.body);

        setState(() {
          pokemonDetail = PokemonDetail.fromJson(pokemonData);
          pokemonSpecies = PokemonSpecies.fromJson(speciesData);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching Pokemon data: $e');
    }
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFFF6B6B);
      case 'water':
        return const Color(0xFF4ECDC4);
      case 'grass':
        return const Color(0xFF45B7D1);
      case 'electric':
        return const Color(0xFFF9CA24);
      case 'psychic':
        return const Color(0xFFF0932B);
      case 'ice':
        return const Color(0xFF74C0FC);
      case 'dragon':
        return const Color(0xFF6C5CE7);
      case 'dark':
        return const Color(0xFF2D3436);
      case 'fairy':
        return const Color(0xFFE84393);
      case 'normal':
        return const Color(0xFF95A5A6);
      case 'fighting':
        return const Color(0xFFE74C3C);
      case 'poison':
        return const Color(0xFF8E44AD);
      case 'ground':
        return const Color(0xFFE1B12C);
      case 'flying':
        return const Color(0xFF87CEEB);
      case 'bug':
        return const Color(0xFF27AE60);
      case 'rock':
        return const Color(0xFF795548);
      case 'ghost':
        return const Color(0xFF5F27CD);
      case 'steel':
        return const Color(0xFF34495E);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  Color get dominantColor {
    if (pokemonDetail?.types.isNotEmpty == true) {
      return getTypeColor(pokemonDetail!.types.first);
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pokemonDetail == null
          ? const Center(child: Text('Failed to load Pokémon details'))
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [_buildPokemonHeader(), _buildTabSection()],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: dominantColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [dominantColor, dominantColor.withOpacity(0.8)],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'pokemon-${widget.pokemonId}',
              child: Image.network(
                pokemonDetail?.imageUrl ?? '',
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.catching_pokemon,
                    size: 100,
                    color: Colors.white.withOpacity(0.5),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            // TODO: Implement favorites
          },
        ),
      ],
    );
  }

  Widget _buildPokemonHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: dominantColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '#${pokemonDetail!.id.toString().padLeft(3, '0')}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              pokemonDetail!.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: pokemonDetail!.types.map((type) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            margin: const EdgeInsets.all(20),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: dominantColor,
                borderRadius: BorderRadius.circular(25),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'About'),
                Tab(text: 'Stats'),
                Tab(text: 'Evolution'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(),
                _buildStatsTab(),
                _buildEvolutionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pokemonSpecies?.description != null) ...[
            const Text(
              'Description',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              pokemonSpecies!.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 20),
          ],
          const Text(
            'Physical Attributes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildAttributeCard(
                  'Height',
                  '${(pokemonDetail!.height / 10).toStringAsFixed(1)} m',
                  Icons.height,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildAttributeCard(
                  'Weight',
                  '${(pokemonDetail!.weight / 10).toStringAsFixed(1)} kg',
                  Icons.fitness_center,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Abilities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: pokemonDetail!.abilities.map((ability) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      dominantColor.withOpacity(0.1),
                      dominantColor.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: dominantColor.withOpacity(0.3)),
                ),
                child: Text(
                  ability.replaceAll('-', ' ').toUpperCase(),
                  style: TextStyle(
                    color: dominantColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Base Stats',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...pokemonDetail!.stats.map((stat) => _buildStatBar(stat)),
        ],
      ),
    );
  }

  Widget _buildEvolutionTab() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.extension, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Evolution Chain',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Evolution data coming soon!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(PokemonStat stat) {
    final statNames = {
      'hp': 'HP',
      'attack': 'Attack',
      'defense': 'Defense',
      'special-attack': 'Sp. Attack',
      'special-defense': 'Sp. Defense',
      'speed': 'Speed',
    };

    final displayName = statNames[stat.name] ?? stat.name;
    final percentage = (stat.baseStat / 200).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: dominantColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  stat.baseStat.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: dominantColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[300],
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [dominantColor.withOpacity(0.7), dominantColor],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class PokemonDetail {
  final int id;
  final String name;
  final int height;
  final int weight;
  final String imageUrl;
  final List<String> types;
  final List<String> abilities;
  final List<PokemonStat> stats;

  PokemonDetail({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.imageUrl,
    required this.types,
    required this.abilities,
    required this.stats,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    return PokemonDetail(
      id: json['id'],
      name: json['name'],
      height: json['height'],
      weight: json['weight'],
      imageUrl:
          json['sprites']['other']['official-artwork']['front_default'] ??
          json['sprites']['front_default'] ??
          '',
      types: (json['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList(),
      abilities: (json['abilities'] as List)
          .map((ability) => ability['ability']['name'] as String)
          .toList(),
      stats: (json['stats'] as List)
          .map((stat) => PokemonStat.fromJson(stat))
          .toList(),
    );
  }
}

class PokemonSpecies {
  final String description;
  final String habitat;
  final int captureRate;

  PokemonSpecies({
    required this.description,
    required this.habitat,
    required this.captureRate,
  });

  factory PokemonSpecies.fromJson(Map<String, dynamic> json) {
    String description = '';
    if (json['flavor_text_entries'] != null &&
        json['flavor_text_entries'].isNotEmpty) {
      // Find English description
      final englishEntry = (json['flavor_text_entries'] as List).firstWhere(
        (entry) => entry['language']['name'] == 'en',
        orElse: () => json['flavor_text_entries'][0],
      );
      description =
          englishEntry['flavor_text']
              ?.replaceAll('\n', ' ')
              .replaceAll('\f', ' ') ??
          '';
    }

    return PokemonSpecies(
      description: description,
      habitat: json['habitat']?['name'] ?? 'Unknown',
      captureRate: json['capture_rate'] ?? 0,
    );
  }
}

class PokemonStat {
  final String name;
  final int baseStat;

  PokemonStat({required this.name, required this.baseStat});

  factory PokemonStat.fromJson(Map<String, dynamic> json) {
    return PokemonStat(name: json['stat']['name'], baseStat: json['base_stat']);
  }
}
