import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:file_picker/file_picker.dart';

class peripherialScreen extends StatefulWidget {
  const peripherialScreen({super.key});

  @override
  State<peripherialScreen> createState() => _peripherialScreenState();
}

class _peripherialScreenState extends State<peripherialScreen> {
  File? _image;
  FlutterSoundRecorder _flutterSoundRecorder = FlutterSoundRecorder();
  String? _audioPath;
  bool _isRecording = false;
  String? _filePath;
  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _flutterSoundRecorder.openRecorder();
  }

  @override
  void dispose() {
    _flutterSoundRecorder.closeRecorder();
    super.dispose();
  }

  Future<void> _takeImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      Directory? appDocDir = await getApplicationDocumentsDirectory();
      String filePath = appDocDir.path + '/recording.aac';

      await _flutterSoundRecorder.startRecorder(
          toFile: filePath, codec: Codec.aacADTS);
      setState(() {
        _audioPath = filePath;
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    await _flutterSoundRecorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _playRecording() async {
    if (_audioPath != null) {
      try {
        await _audioPlayer
            .setAudioSource(AudioSource.file(_audioPath!))
            .whenComplete(() => _audioPlayer.play());
        await _audioPlayer.play();
      } catch (e) {
        print('errrrrooooooooooor $e');
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        _filePath = file.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perifericos'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_image != null) Image.file(_image!),
            ElevatedButton(
              onPressed: _takeImage,
              child: const Text('Tomar Foto'),
            ),
            ElevatedButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                child: Icon(_isRecording ? Icons.stop : Icons.mic)),
            if (_audioPath != null && !_isRecording) Text(_audioPath!),
            ElevatedButton(
              onPressed:
                  _audioPath != null && !_isRecording ? _playRecording : null,
              child: const Text('Reproducir Audio'),
            ),
          ],
        ),
      ),
    );
  }
}
