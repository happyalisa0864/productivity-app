import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;
  
  static Future<void> playCompletionSound() async {
    if (_isPlaying) return; // Prevent multiple sounds
    
    _isPlaying = true;
    try {
      // Play haptic feedback
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
      
      // Play the completion sound from assets
      try {
        await _player.play(AssetSource('assets/sounds/calm-loop-80576.mp3'));
        // Let the sound play (it's a loop, so we'll stop it after a reasonable duration)
        await Future.delayed(const Duration(seconds: 3));
        await _player.stop();
      } catch (e) {
        print('Could not play completion sound: $e');
        // Haptics still provide feedback even if sound fails
      }
    } catch (e) {
      print('Could not play completion sound: $e');
    } finally {
      // Reset after a delay to allow sound to play
      Future.delayed(const Duration(seconds: 4), () {
        _isPlaying = false;
      });
    }
  }
  
  static Future<void> playTickSound() async {
    // Optional: play a subtle tick sound
    // For now, we'll skip this to avoid being annoying
  }
  
  static void dispose() {
    _player.dispose();
  }
}

