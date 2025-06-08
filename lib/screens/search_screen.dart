import 'package:flutter/material.dart';
import 'package:flow/models/cat.dart';
import 'package:flow/services/cat_service.dart';
import 'package:flow/screens/cat_profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _catService = CatService();
  List<Cat> _searchResults = [];
  bool _isLoading = false;
  String _orderBy = 'name';
  bool _descending = false;

  Future<void> _performSearch() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final results = await _catService.searchCats(
        _searchController.text,
        orderBy: _orderBy,
        descending: _descending,
      );
      setState(() => _searchResults = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na busca: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar Gatos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por nome',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ordenar por:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _orderBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Nome')),
                    DropdownMenuItem(value: 'age', child: Text('Idade')),
                  ],
                  onChanged: (value) => setState(() => _orderBy = value!),
                ),
                IconButton(
                  icon: Icon(_descending ? Icons.arrow_downward : Icons.arrow_upward),
                  onPressed: () => setState(() => _descending = !_descending),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final cat = _searchResults[index];
                    return ListTile(
                      title: Text(cat.name),
                      subtitle: Text('${cat.age} anos - ${cat.location}'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CatProfileScreen(cat: cat)),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}