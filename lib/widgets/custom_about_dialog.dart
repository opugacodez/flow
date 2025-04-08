import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomAboutDialog extends StatelessWidget {
  const CustomAboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                  'assets/developer.jpg'),
            ),
            SizedBox(height: 20),

            Text(
              'Murilo Manfre',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),

            InkWell(
              onTap: () => _launchURL('https://github.com/murilomanfre/flow'),
              child: Text(
                'https://github.com/murilomanfre/flow',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              child: Text('Fechar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.dataFromString(url))) {
      await launchUrl(Uri.dataFromString(url));
    } else {
      throw 'Não foi possível abrir $url';
    }
  }
}