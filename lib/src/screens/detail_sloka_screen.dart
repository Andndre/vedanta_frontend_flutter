import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vedanta_frontend/src/providers/gita_provider.dart';
import 'package:vedanta_frontend/src/widgets/gita_card_widget.dart';
import 'package:vedanta_frontend/src/widgets/music_player_widget.dart';

class DetailSlokaScreen extends StatefulWidget {
  final int bab;
  final int sloka;
  const DetailSlokaScreen({super.key, required this.bab, required this.sloka});

  @override
  State<DetailSlokaScreen> createState() => _DetailSlokaScreenState();
}

class _DetailSlokaScreenState extends State<DetailSlokaScreen> {
  Map _sloka = {};

  @override
  void initState() {
    super.initState();
    _getSloka();
  }

  Future<void> _getSloka() async {
    final gitaProvider = Provider.of<GitaProvider>(context, listen: false);
    final response = await gitaProvider.getGitaSloka(widget.bab, widget.sloka);
    if (response['error'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      setState(() {
        _sloka = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Sloka'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GitaCardWidget(
              headerText: 'Sedang Membaca:',
              subHeaderText:
                  'BAB ${_sloka['numberBab']}: SLOKA ${_sloka['number']}',
              text: 'Arjuna Vishaada Yoga',
              withButton: false,
            ),
            SizedBox(height: 20),
            // Media Player Widget
            MusicPlayerWidget(
                url:
                    "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"),
            const SizedBox(height: 20),
            Text(
              'Sloka:',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Text(
              _sloka['content'] ?? '',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              'Terjemahan:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _sloka['translationIndo'] ?? '',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}