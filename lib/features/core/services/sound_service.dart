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
      
      // Play a system notification sound
      try {
        // Use a simple, reliable notification sound URL
        // This is a short completion/achievement sound
        await _player.play(UrlSource('https://www.soundjay.com/misc/sounds/bell-ringing-05.wav'));
        // Let it play briefly then stop
        await Future.delayed(const Duration(milliseconds: 800));
        await _player.stop();
      } catch (e) {
        // If that fails, try an alternative sound
        try {
          await _player.play(UrlSource('https://www.zapsplat.com/wp-content/uploads/2015/sound-effects-one/notification_bell_001.mp3'));
          await Future.delayed(const Duration(milliseconds: 800));
          await _player.stop();
        } catch (e2) {
          // If all else fails, at least we have haptics which provide tactile feedback
          print('Could not play audio sound, using haptics only: $e2');
        }
      }
    } catch (e) {
      print('Could not play completion sound: $e');
    } finally {
      // Reset after a delay to allow sound to play
      Future.delayed(const Duration(seconds: 1), () {
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

