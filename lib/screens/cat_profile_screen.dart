import 'package:flutter/material.dart';
import '../models/cat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow/services/cat_service.dart';
import 'package:flow/screens/add_edit_cat_screen.dart';

class CatProfileScreen extends StatefulWidget {
  final Cat cat;

  const CatProfileScreen({super.key, required this.cat});

  @override
  State<CatProfileScreen> createState() => _CatProfileScreenState();
}

class _CatProfileScreenState extends State<CatProfileScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  final CatService _catService = CatService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser != null && currentUser.uid == widget.cat.ownerId;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(isOwner),
          _buildProfileContent(),
        ],
      ),
      bottomNavigationBar: isOwner ? null : _buildAdoptionButton(context),
    );
  }

  SliverAppBar _buildSliverAppBar(bool isOwner) {
    return SliverAppBar(
      expandedHeight: 300,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.cat.images.length,
              onPageChanged: (index) {
                setState(() => _currentPageIndex = index);
              },
              itemBuilder: (context, index) => Image.network(
                widget.cat.images[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: _buildImageIndicator(),
            ),
          ],
        ),
      ),
      pinned: true,
      floating: true,
      actions: isOwner
          ? [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddEditCatScreen(cat: widget.cat)),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _deleteCat(widget.cat.id),
        ),
      ]
          : [],
    );
  }

  void _deleteCat(String catId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja remover este anúncio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await _catService.deleteCat(catId);
                if (mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
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


  Widget _buildImageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.cat.images.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentPageIndex == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _currentPageIndex == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  SliverList _buildProfileContent() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildHealthInfo(),
              const SizedBox(height: 24),
              _buildPersonalityInfo(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.cat.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
                widget.cat.status,
                style: TextStyle(
                    fontSize: 18,
                    color: widget.cat.status == 'Disponível' ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold
                )
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.cat.age} anos',
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16),
            const SizedBox(width: 4),
            Text(widget.cat.location),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Histórico de Saúde',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildHealthItem('Vacinado', widget.cat.vaccinated),
            _buildHealthItem('Castrado', widget.cat.neutered),
            const SizedBox(height: 12),
            Text(
              widget.cat.healthHistory,
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthItem(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.remove_circle,
            color: value ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildPersonalityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personalidade',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.cat.personality.split(',').map((trait) => Chip(
            label: Text(trait.trim()),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAdoptionButton(BuildContext context) {
    final bool isAvailable = widget.cat.status == 'Disponível';

    return Container(
      padding: const EdgeInsets.all(16),
      child: FilledButton.icon(
        icon: const Icon(Icons.pets),
        label: Text(isAvailable ? 'Quero Adotar' : 'Adoção em Andamento'),
        onPressed: isAvailable ? () => _showAdoptionDialog(context) : null,
      ),
    );
  }

  void _showAdoptionDialog(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar Processo de Adoção'),
        content: const Text('Confirmar interesse? Após a confirmação, o gato ficará reservado para você e entraremos em contato.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Você precisa estar logado!')),
                );
                Navigator.pop(context);
                return;
              }
              try {
                await _catService.requestAdoption(userId, widget.cat.id);

                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Solicitação enviada com sucesso!')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}