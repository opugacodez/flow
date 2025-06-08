import 'package:flutter/material.dart';
import '../models/cat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow/services/cat_service.dart';

class CatProfileScreen extends StatefulWidget {
  final Cat cat;

  const CatProfileScreen({super.key, required this.cat});

  @override
  State<CatProfileScreen> createState() => _CatProfileScreenState();
}

class _CatProfileScreenState extends State<CatProfileScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;

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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildImageGallery(),
          _buildProfileContent(),
        ],
      ),
      bottomNavigationBar: _buildAdoptionButton(context),
    );
  }

  SliverAppBar _buildImageGallery() {
    return SliverAppBar(
      expandedHeight: 300,
      flexibleSpace: Stack(
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
      pinned: true,
      floating: true,
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
                : Colors.white.withValues(alpha: 0.5),
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
          children: [
            Text(
              widget.cat.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${widget.cat.age} anos',
              style: const TextStyle(fontSize: 18),
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: FilledButton.icon(
        icon: const Icon(Icons.pets),
        label: const Text('Quero Adotar'),
        onPressed: () => _showAdoptionDialog(context),
      ),
    );
  }

  void _showAdoptionDialog(BuildContext context) {
    final catService = CatService();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar Processo de Adoção'),
        content: const Text('Confirmar interesse? Entraremos em contato.'),
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
                await catService.requestAdoption(userId, widget.cat.id);
                
                await catService.updateCatStatus(widget.cat.id, 'Adoção em andamento');
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Solicitação enviada com sucesso!')),
                );
              } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $e')),
                );
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}