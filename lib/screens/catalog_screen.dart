import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flow/models/cat.dart';
import 'package:flow/providers/auth_provider.dart';
import 'package:flow/screens/cat_profile_screen.dart';
import 'package:flow/screens/filter_screen.dart';
import 'package:flow/services/cat_service.dart';
import 'package:flow/widgets/custom_about_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final CatService _catService = CatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gatos Disponíveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/search'),
          ),
          _buildPopupMenu(context),
        ],
      ),
      body: StreamBuilder<List<Cat>>(
        stream: _catService.getCats(), // Usar Stream (RF005)
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os gatos: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum gato disponível no momento.'));
          }

          final cats = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: cats.length,
            itemBuilder: (context, index) => _CatCard(cat: cats[index]),
          );
        },
      ),
    );
  }

  PopupMenuButton<String> _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'favorites':
            Navigator.pushNamed(context, '/favorites');
            break;
          case 'profile':
            Navigator.pushNamed(context, '/profile');
            break;
          case 'about':
            _showCustomAbout(context);
            break;
          case 'logout':
            Provider.of<AuthProvider>(context, listen: false).signOut();
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'favorites', child: Text('Meus Favoritos')),
        const PopupMenuItem(value: 'profile', child: Text('Meu Perfil')),
        const PopupMenuItem(value: 'about', child: Text('Sobre')),
        const PopupMenuItem(value: 'logout', child: Text('Sair')),
      ],
    );
  }
  
  void _showFilterDialog(BuildContext context) {
    // A lógica de filtro precisará ser adaptada para funcionar com o stream do Firestore.
    // Por simplicidade, a implementação original é mantida, mas idealmente seria refatorada.
    showModalBottomSheet(
      context: context,
      builder: (context) => const FilterScreen(),
    );
  }

  void _showCustomAbout(BuildContext context) {
    showDialog(context: context, builder: (context) => const CustomAboutDialog());
  }
}

class _CatCard extends StatelessWidget {
  final Cat cat;
  const _CatCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    final catService = CatService();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CatProfileScreen(cat: cat)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    cat.profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Center(child: Icon(Icons.error)),
                  ),
                  if (userId != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: StreamBuilder<bool>(
                        stream: catService.isFavorite(userId, cat.id),
                        builder: (context, snapshot) {
                          final isFavorited = snapshot.data ?? false;
                          return IconButton(
                            icon: Icon(
                              isFavorited ? Icons.favorite : Icons.favorite_border,
                              color: Colors.deepPurple,
                            ),
                            onPressed: () {
                              if (isFavorited) {
                                catService.removeFavorite(userId, cat.id);
                              } else {
                                catService.addFavorite(userId, cat.id); // RF003
                              }
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cat.name, style: Theme.of(context).textTheme.titleMedium),
                  Text(cat.status,
                      style: TextStyle(
                        color: cat.status == 'Disponível' ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}