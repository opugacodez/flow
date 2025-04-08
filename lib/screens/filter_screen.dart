import 'package:flow/models/filter.dart';
import 'package:flow/providers/catalog_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late CatFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = Provider.of<CatalogProvider>(context, listen: false).currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filtrar por:',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          _buildAgeRangeFilter(),
          const SizedBox(height: 6),
          _buildDropdown('Gênero', ['', 'Macho', 'Fêmea'], _tempFilter.gender),
          const SizedBox(height: 20),
          _buildDropdown('Porte', ['', 'Pequeno', 'Médio', 'Grande'], _tempFilter.size),
          const SizedBox(height: 20),
          _buildDropdown('Cor', ['', 'Preto', 'Branco', 'Cinza'], _tempFilter.color),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: _clearFilters,
                  child: const Text(
                    'Limpar Filtros',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Provider.of<CatalogProvider>(context, listen: false)
                        .updateFilter(_tempFilter);
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar Filtros'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Faixa de Idade',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_tempFilter.minAge} anos',
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '${_tempFilter.maxAge} anos',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        RangeSlider(
          values: RangeValues(
            _tempFilter.minAge.toDouble(),
            _tempFilter.maxAge.toDouble(),
          ),
          min: 0,
          max: 20,
          divisions: 20,
          labels: RangeLabels(
            '${_tempFilter.minAge}',
            '${_tempFilter.maxAge}',
          ),
          onChanged: (values) {
            setState(() {
              _tempFilter.minAge = values.start.round();
              _tempFilter.maxAge = values.end.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(String title, List<String> options, String currentValue) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: currentValue,
          items: options.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Text(
                value.isEmpty ? 'Todos' : value,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() {
            if (title == 'Gênero') _tempFilter.gender = value!;
            if (title == 'Porte') _tempFilter.size = value!;
            if (title == 'Cor') _tempFilter.color = value!;
          }),
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _tempFilter = CatFilter();
    });
    Provider.of<CatalogProvider>(context, listen: false)
        .updateFilter(_tempFilter);
  }
}