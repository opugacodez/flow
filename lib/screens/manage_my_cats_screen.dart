import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow/models/cat.dart';
import 'package:flow/screens/add_edit_cat_screen.dart';
import 'package:flow/services/cat_service.dart';
import 'package:flutter/material.dart';

class ManageMyCatsScreen extends StatefulWidget {
  const ManageMyCatsScreen({super.key});

  @override
  State<ManageMyCatsScreen> createState() => _ManageMyCatsScreenState();
}

class _ManageMyCatsScreenState extends State<ManageMyCatsScreen> {
  final CatService _catService = CatService();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  void _navigateAndRefresh(BuildContext context, {Cat? cat}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditCatScreen(cat: cat)),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _deleteCat(String catId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja remover este anúncio? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _catService.deleteCat(catId);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Anúncio removido com sucesso.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao remover: $e')),
                  );
                }
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Anúncios')),
      body: userId == null
          ? const Center(child: Text('Faça login para gerenciar seus anúncios.'))
          : StreamBuilder<List<Cat>>(
        stream: _catService.getUserCats(userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Você ainda não anunciou nenhum gato.'));
          }

          final cats = snapshot.data!;
          return ListView.builder(
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final cat = cats[index];
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(cat.profileImageUrl)),
                title: Text(cat.name),
                subtitle: Text(cat.status),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _navigateAndRefresh(context, cat: cat),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCat(cat.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateAndRefresh(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}