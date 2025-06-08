import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow/models/cat.dart';
import 'package:flow/screens/cat_profile_screen.dart';
import 'package:flow/services/cat_service.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final catService = CatService();

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Meus Favoritos')),
        body: const Center(child: Text('Faça login para ver seus favoritos.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Favoritos')),
      body: StreamBuilder<List<Cat>>(
        stream: catService.getFavoriteCats(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Você ainda não favoritou nenhum gato.'));
          }

          final cats = snapshot.data!;
          return ListView.builder(
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final cat = cats[index];
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(cat.profileImageUrl)),
                title: Text(cat.name),
                subtitle: Text(cat.location),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CatProfileScreen(cat: cat)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}