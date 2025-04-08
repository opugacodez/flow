import 'package:flow/models/cat.dart';
import 'package:flow/providers/auth_provider.dart';
import 'package:flow/providers/catalog_provider.dart';
import 'package:flow/screens/cat_profile_screen.dart';
import 'package:flow/screens/filter_screen.dart';
import 'package:flow/widgets/custom_about_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CatalogProvider>(context, listen: false).loadCats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final catalogProvider = Provider.of<CatalogProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gatos Disponíveis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.signOut();
              if (authProvider.user == null) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen())
                );
              }
            },
          ),
          IconButton(
              onPressed: () => _showCustomAbout(context),
              icon: Icon(Icons.info_outline))
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: catalogProvider.cats.length,
        itemBuilder: (context, index) => _CatCard(cat: catalogProvider.cats[index]),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => FilterScreen(),
    );
  }

  void _showCustomAbout(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => CustomAboutDialog()
    );
  }
}

class _CatCard extends StatelessWidget {
  final Cat cat;

  const _CatCard({required this.cat});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CatProfileScreen(cat: cat),
            ),
          ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    cat.profileImageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          cat.isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () => Provider.of<CatalogProvider>(
                            context, listen: false).toggleFavorite(cat.id),
                      ),
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
                  Text('${cat.age} anos', style: Theme.of(context).textTheme.bodySmall),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14),
                      Text(cat.location, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}