import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAboutDialog extends StatelessWidget {
  const CustomAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/developer.jpg'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Flow - App de Adoção de Gatos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Objetivo: Conectar gatos que precisam de um lar com pessoas dispostas a oferecer amor e cuidado, facilitando o processo de adoção.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Desenvolvido por:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const Text('Murilo Manfre'),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _launchURL('https://github.com/murilomanfre/flow'),
              child: const Text(
                'GitHub do Projeto',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Fechar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Não foi possível abrir $url';
    }
  }
}