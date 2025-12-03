import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyPokemonApp());
}

class MyPokemonApp extends StatelessWidget {
  const MyPokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Pokémon Aleatório',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const PokemonHome(),
    );
  }
}

class PokemonHome extends StatefulWidget {
  const PokemonHome({super.key});

  @override
  State<PokemonHome> createState() => _PokemonHomeState();
}

class _PokemonHomeState extends State<PokemonHome> {
  String? pokemonName;
  String? pokemonImage;
  int? pokemonId;
  bool isLoading = false;
  String? error;

  Future<void> fetchPokemon() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    final id = Random().nextInt(151) + 1;
    final url = Uri.parse("https://pokeapi.co/api/v2/pokemon/$id");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pokemonId = data["id"];
          pokemonName = data["name"];
          pokemonImage = data["sprites"]["front_default"];
        });
      } else {
        setState(() {
          error = 'Erro: status ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erro ao buscar: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // background com gradiente
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.greenAccent, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const CircularProgressIndicator()
                else if (error != null)
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  )
                else if (pokemonImage != null)
                  Column(
                    children: [
                      Image.network(
                        pokemonImage!,
                        height: 200,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '#${pokemonId} ${pokemonName!.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Pressione o botão para gerar um Pokémon',
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: fetchPokemon,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Gerar Pokémon',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
