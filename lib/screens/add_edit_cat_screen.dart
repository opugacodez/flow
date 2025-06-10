import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flow/models/cat.dart';
import 'package:flow/services/cat_service.dart';
import 'package:flow/services/storage_service.dart';
import 'package:flutter/material.dart';

class AddEditCatScreen extends StatefulWidget {
  final Cat? cat;

  const AddEditCatScreen({super.key, this.cat});

  @override
  State<AddEditCatScreen> createState() => _AddEditCatScreenState();
}

class _AddEditCatScreenState extends State<AddEditCatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catService = CatService();
  final _storageService = StorageService();
  bool _isLoading = false;

  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _healthHistoryController;
  late TextEditingController _personalityController;

  String _gender = 'Macho';
  String _size = 'Médio';
  String _color = 'Preto';
  bool _vaccinated = false;
  bool _neutered = false;

  List<dynamic> _imageUrls = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cat?.name);
    _ageController = TextEditingController(text: widget.cat?.age.toString());
    _locationController = TextEditingController(text: widget.cat?.location);
    _descriptionController = TextEditingController(text: widget.cat?.description);
    _healthHistoryController = TextEditingController(text: widget.cat?.healthHistory);
    _personalityController = TextEditingController(text: widget.cat?.personality);

    if (widget.cat != null) {
      _gender = widget.cat!.gender;
      _size = widget.cat!.size;
      _color = widget.cat!.color;
      _vaccinated = widget.cat!.vaccinated;
      _neutered = widget.cat!.neutered;
      _imageUrls = List.from(widget.cat!.images);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _healthHistoryController.dispose();
    _personalityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imageFile = await _storageService.pickImageFromGallery();
    if (imageFile != null) {
      setState(() {
        _imageUrls.add(imageFile);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageUrls.removeAt(index);
    });
  }

  Future<void> _saveCat() async {
    if (!_formKey.currentState!.validate() || _imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos e adicione ao menos uma imagem.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final List<String> uploadedImageUrls = [];
      for (var image in _imageUrls) {
        if (image is String) {
          uploadedImageUrls.add(image);
        } else if (image is File) {
          final tempCatId = widget.cat?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
          final url = await _storageService.uploadCatImage(tempCatId, image);
          uploadedImageUrls.add(url);
        }
      }

      final catData = {
        'ownerId': FirebaseAuth.instance.currentUser!.uid,
        'name': _nameController.text.trim(),
        'name_lowercase': _nameController.text.trim().toLowerCase(),
        'age': int.parse(_ageController.text.trim()),
        'location': _locationController.text.trim(),
        'description': _descriptionController.text.trim(),
        'healthHistory': _healthHistoryController.text.trim(),
        'personality': _personalityController.text.trim(),
        'gender': _gender,
        'size': _size,
        'color': _color,
        'vaccinated': _vaccinated,
        'neutered': _neutered,
        'images': uploadedImageUrls,
        'profileImageUrl': uploadedImageUrls.first,
        'status': 'Disponível',
      };

      if (widget.cat == null) {
        await _catService.addCat(catData);
      } else {
        await _catService.updateCat(widget.cat!.id, catData);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cat == null ? 'Adicionar Gato' : 'Editar Gato'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Idade (anos)'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Localização (Cidade, UF)'),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            _buildDropdown('Gênero', ['Macho', 'Fêmea'], _gender, (v) => setState(() => _gender = v!)),
            const SizedBox(height: 16),
            _buildDropdown('Porte', ['Pequeno', 'Médio', 'Grande'], _size, (v) => setState(() => _size = v!)),
            const SizedBox(height: 16),
            _buildDropdown('Cor', ['Preto', 'Branco', 'Cinza', 'Laranja', 'Rajado', 'Tricolor'], _color, (v) => setState(() => _color = v!)),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _personalityController,
              decoration: const InputDecoration(labelText: 'Personalidade (Ex: Dócil, Brincalhão)'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _healthHistoryController,
              decoration: const InputDecoration(labelText: 'Histórico de Saúde'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Vacinado?'),
              value: _vaccinated,
              onChanged: (v) => setState(() => _vaccinated = v),
            ),
            SwitchListTile(
              title: const Text('Castrado?'),
              value: _neutered,
              onChanged: (v) => setState(() => _neutered = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveCat,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      value: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Imagens', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _imageUrls.length + 1,
            itemBuilder: (context, index) {
              if (index == _imageUrls.length) {
                return GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_a_photo, color: Colors.grey),
                  ),
                );
              }
              final image = _imageUrls[index];
              return Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: image is String ? NetworkImage(image) : FileImage(image as File) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}