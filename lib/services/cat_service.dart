import 'package:flow/models/cat.dart';

class CatService {
  Future<List<Cat>> getCats() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      Cat(
        id: '1',
        name: 'Luna',
        age: 2,
        gender: 'Fêmea',
        color: 'Preto',
        size: 'Médio',
        location: 'São Paulo - SP',
        description: 'Brincalhona e carinhosa',
        profileImageUrl: 'https://images.unsplash.com/photo-1603108025081-4146ecdec5b5', // Unsplash
        images: [
          'https://images.unsplash.com/photo-1615000363959-e52262d2c75b',
          'https://images.unsplash.com/photo-1497910091122-9f8a7746eb33'
        ],
        healthHistory: 'Vacinada em 01/2024, vermifugada regularmente',
        personality: 'Amigável, Curiosa, Brincalhona',
        vaccinated: true,
        neutered: true,
        isFavorited: false,
      ),
      Cat(
        id: '2',
        name: 'Milo',
        age: 3,
        gender: 'Macho',
        color: 'Cinza',
        size: 'Grande',
        location: 'Rio de Janeiro - RJ',
        description: 'Calmo e observador',
        profileImageUrl: 'https://plus.unsplash.com/premium_photo-1675616553658-259d91ec4a16', // Unsplash
        images: [
          'https://images.unsplash.com/photo-1559914392-7f2884c21a35'
        ],
        healthHistory: 'Vacinado em 12/2023, castrado em 02/2024',
        personality: 'Calmo, Independente, Inteligente',
        vaccinated: true,
        neutered: true,
        isFavorited: false,
      ),
      Cat(
        id: '3',
        name: 'Bella',
        age: 1,
        gender: 'Fêmea',
        color: 'Branco e Cinza',
        size: 'Pequeno',
        location: 'Curitiba - PR',
        description: 'Muito amorosa e ativa',
        profileImageUrl: 'https://images.unsplash.com/photo-1508292549404-81fd946f8c2e', // Unsplash
        images: [
          'https://images.unsplash.com/photo-1508292549404-81fd946f8c2e',
          'https://images.unsplash.com/photo-1508292549404-81fd946f8c2e'
        ],
        healthHistory: 'Vacinada em março de 2024, vermifugada regularmente',
        personality: 'Carinhosa, Energética, Sociável',
        vaccinated: true,
        neutered: false,
        isFavorited: true,
      ),
      Cat(
        id: '4',
        name: 'Simba',
        age: 4,
        gender: 'Macho',
        color: 'Laranja e Branco',
        size: 'Grande',
        location: 'Porto Alegre - RS',
        description: 'Adora explorar e brincar ao ar livre.',
        profileImageUrl:
        'https://images.unsplash.com/photo-1593483316242-efb5420596ca', // Unsplash
        images: [
          'https://images.unsplash.com/photo-1593483316242-efb5420596ca',
          'https://images.unsplash.com/photo-1593483316242-efb5420596ca'
        ],
        healthHistory:
        'Vacinado em janeiro de cada ano desde filhote. Castrado em maio de 2023.',
        personality:
        'Explorador, Curioso, Protetor.',
      ),
    ];
  }
}