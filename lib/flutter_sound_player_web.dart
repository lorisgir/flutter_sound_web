import 'dart:async';
import 'dart:typed_data' show Uint8List;
import 'dart:js_interop';
import 'package:flutter_sound_platform_interface/flutter_sound_platform_interface.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_player_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:logger/logger.dart' show Level;

// JS types for TypedArrays
@JS('Uint8Array')
extension type JSUint8Array._(JSObject _) implements JSObject {
  external factory JSUint8Array(JSNumber length);

  external JSNumber get length;

  external void set(JSArray<JSNumber> array, [JSNumber offset]);
}

// Extension to convert between Uint8List and JSUint8Array
extension Uint8ListJSInterop on Uint8List {
  JSUint8Array toJS() {
    final jsArray = JSUint8Array(length.toJS);
    jsArray.set(map((e) => e.toJS).toList().toJS);
    return jsArray;
  }
}

extension type FlutterSoundPlayerCallbackJS._(JSObject _) implements JSObject {
  // Constructor per creare un oggetto literal con tutti i callback opzionali
  external factory FlutterSoundPlayerCallbackJS(
      {JSFunction? updateProgress,
      JSFunction? updatePlaybackState,
      JSFunction? needSomeFood,
      JSFunction? audioPlayerFinished,
      JSFunction? startPlayerCompleted,
      JSFunction? pausePlayerCompleted,
      JSFunction? resumePlayerCompleted,
      JSFunction? stopPlayerCompleted,
      JSFunction? openPlayerCompleted,
      JSFunction? log});

  // Definizione dei membri di callback
  external void updateProgress(JSObject options);

  external void updatePlaybackState(int state);

  external void needSomeFood(int ln);

  external void audioPlayerFinished(int state);

  external void startPlayerCompleted(int state, bool success, int duration);

  external void pausePlayerCompleted(int state, bool success);

  external void resumePlayerCompleted(int state, bool success);

  external void stopPlayerCompleted(int state, bool success);

  external void openPlayerCompleted(int state, bool success);

  external void log(JSString logLevel, JSString msg);
}

// JS Interop Type Definitions
extension type FlutterSoundPlayer._(JSObject _) implements JSObject {
  external FlutterSoundPlayer();

  external int releaseMediaPlayer();

  external int initializeMediaPlayer();

  external int setAudioFocus(
    int focus,
    int category,
    int mode,
    int? audioFlags,
    int device,
  );

  external int getPlayerState();

  external bool isDecoderSupported(int codec);

  external int setSubscriptionDuration(int duration);

  external int startPlayer(
    int? codec,
    JSUint8Array? fromDataBuffer,
    String? fromURI,
    int? numChannels,
    int? sampleRate,
    int? bufferSize,
  );

  external int feed(JSUint8Array? data);

  external int startPlayerFromTrack(
    int progress,
    int duration,
    JSObject track,
    bool canPause,
    bool canSkipForward,
    bool canSkipBackward,
    bool defaultPauseResume,
    bool removeUIWhenStopped,
  );

  external int nowPlaying(
    int progress,
    int duration,
    JSObject? track,
    bool? canPause,
    bool? canSkipForward,
    bool? canSkipBackward,
    bool? defaultPauseResume,
  );

  external int stopPlayer();

  external int pausePlayer();

  external int resumePlayer();

  external int seekToPlayer(int duration);

  external int setVolume(double? volume);

  external int setVolumePan(double? volume, double? pan);

  external int setSpeed(double speed);

  external int setUIProgressBar(int duration, int progress);
}

@JS()
external FlutterSoundPlayer newPlayerInstance(FlutterSoundPlayerCallbackJS callback, JSArray<JSFunction> callbackTable);

class FlutterSoundPlayerWeb extends FlutterSoundPlayerPlatform {
  static List<String> defaultExtensions = [
    "flutter_sound.aac",
    "flutter_sound.aac",
    "flutter_sound.opus",
    "flutter_sound_opus.caf",
    "flutter_sound.mp3",
    "flutter_sound.ogg",
    "flutter_sound.pcm",
    "flutter_sound.wav",
    "flutter_sound.aiff",
    "flutter_sound_pcm.caf",
    "flutter_sound.flac",
    "flutter_sound.mp4",
    "flutter_sound.amr",
    "flutter_sound.amr",
    "flutter_sound.pcm",
    "flutter_sound.pcm",
  ];

  static void registerWith(Registrar registrar) {
    FlutterSoundPlayerPlatform.instance = FlutterSoundPlayerWeb();
  }

  List<FlutterSoundPlayer?> _slots = [];

  FlutterSoundPlayer? getWebSession(FlutterSoundPlayerCallback callback) {
    return _slots[findSession(callback)];
  }

  // Convert callback functions to JS
  JSArray<JSFunction> _createCallbackTable(FlutterSoundPlayerCallback callback) {
    final callbackFunctions = [
      (int position, int duration) {
        callback.updateProgress(
          duration: duration,
          position: position,
        );
      }.toJS,
      (int state) {
        callback.updatePlaybackState(state);
      }.toJS,
      (int ln) {
        callback.needSomeFood(ln);
      }.toJS,
      (int state) {
        callback.audioPlayerFinished(state);
      }.toJS,
      (int state, bool success, int duration) {
        callback.startPlayerCompleted(state, success, duration);
      }.toJS,
      (int state, bool success) {
        callback.pausePlayerCompleted(state, success);
      }.toJS,
      (int state, bool success) {
        callback.resumePlayerCompleted(state, success);
      }.toJS,
      (int state, bool success) {
        callback.stopPlayerCompleted(state, success);
      }.toJS,
      (int state, bool success) {
        callback.openPlayerCompleted(state, success);
      }.toJS,
      (int level, String msg) {
        callback.log(Level.values[level], msg);
      }.toJS,
    ];

    return callbackFunctions.toJS;
  }

  FlutterSoundPlayerCallbackJS _createCallbackTable2(FlutterSoundPlayerCallback callback) {
    return FlutterSoundPlayerCallbackJS(
      updateProgress: (int position, int duration) {
        callback.updateProgress(
          duration: duration,
          position: position,
        );
      }.toJS,
      updatePlaybackState: (int state) {
        callback.updatePlaybackState(state);
      }.toJS,
      needSomeFood: (int ln) {
        callback.needSomeFood(ln);
      }.toJS,
      audioPlayerFinished: (int state) {
        callback.audioPlayerFinished(state);
      }.toJS,
      startPlayerCompleted: (int state, bool success, int duration) {
        callback.startPlayerCompleted(state, success, duration);
      }.toJS,
      pausePlayerCompleted: (int state, bool success) {
        callback.pausePlayerCompleted(state, success);
      }.toJS,
      resumePlayerCompleted: (int state, bool success) {
        callback.resumePlayerCompleted(state, success);
      }.toJS,
      stopPlayerCompleted: (int state, bool success) {
        callback.stopPlayerCompleted(state, success);
      }.toJS,
      openPlayerCompleted: (int state, bool success) {
        callback.openPlayerCompleted(state, success);
      }.toJS,
      log:  (int level, String msg) {
        callback.log(Level.values[level], msg);
      }.toJS,
    );
  }

  @override
  Future<void>? resetPlugin(FlutterSoundPlayerCallback callback) {
    callback.log(Level.debug, '---> resetPlugin');
    for (int i = 0; i < _slots.length; ++i) {
      callback.log(Level.debug, "Releasing slot #$i");
      _slots[i]?.releaseMediaPlayer();
    }
    _slots = [];
    callback.log(Level.debug, '<--- resetPlugin');
    return null;
  }

  @override
  Future<int> openPlayer(FlutterSoundPlayerCallback callback, {required Level logLevel}) async {
    int slotno = findSession(callback);
    if (slotno < _slots.length) {
      assert(_slots[slotno] == null);

      _slots[slotno] = newPlayerInstance( _createCallbackTable2(callback), _createCallbackTable(callback));
    } else {
      assert(slotno == _slots.length);
      _slots.add(newPlayerInstance( _createCallbackTable2(callback), _createCallbackTable(callback)));
    }
    return _slots[slotno]!.initializeMediaPlayer();
  }

  @override
  Future<int> closePlayer(FlutterSoundPlayerCallback callback) async {
    int slotno = findSession(callback);
    int r = _slots[slotno]!.releaseMediaPlayer();
    _slots[slotno] = null;
    return r;
  }

  @override
  Future<int> getPlayerState(FlutterSoundPlayerCallback callback) async {
    return getWebSession(callback)!.getPlayerState();
  }

  @override
  Future<Map<String, Duration>> getProgress(FlutterSoundPlayerCallback callback) async {
    return {
      'duration': Duration.zero,
      'progress': Duration.zero,
    };
  }

  @override
  Future<bool> isDecoderSupported(FlutterSoundPlayerCallback callback, {required Codec codec}) async {
    return getWebSession(callback)!.isDecoderSupported(codec.index);
  }

  @override
  Future<int> setSubscriptionDuration(FlutterSoundPlayerCallback callback, {Duration? duration}) async {
    return getWebSession(callback)!.setSubscriptionDuration(duration!.inMilliseconds);
  }

  @override
  Future<int> startPlayer(FlutterSoundPlayerCallback callback,
      {Codec? codec,
      Uint8List? fromDataBuffer,
      String? fromURI,
      int? numChannels,
      int? sampleRate,
      int bufferSize = 8192}) async {
    if (codec == null) codec = Codec.defaultCodec;
    if (fromDataBuffer != null && fromURI != null) {
      throw Exception("You may not specify both 'fromURI' and 'fromDataBuffer' parameters");
    }

    callback.log(Level.debug, 'startPlayer FromURI : $fromURI');
    return getWebSession(callback)!
        .startPlayer(codec.index, fromDataBuffer?.toJS(), fromURI, numChannels, sampleRate, bufferSize);
  }

  @override
  Future<int> startPlayerFromMic(FlutterSoundPlayerCallback callback,
      {int? numChannels, int? sampleRate, int bufferSize = 8192, bool enableVoiceProcessing = false}) {
    throw Exception('StartPlayerFromMic() is not implemented on Flutter Web');
  }

  @override
  Future<int> feed(FlutterSoundPlayerCallback callback, {Uint8List? data}) async {
    return getWebSession(callback)!.feed(data?.toJS());
  }

  @override
  Future<int> stopPlayer(FlutterSoundPlayerCallback callback) async {
    return getWebSession(callback)!.stopPlayer();
  }

  @override
  Future<int> pausePlayer(FlutterSoundPlayerCallback callback) async {
    return getWebSession(callback)!.pausePlayer();
  }

  @override
  Future<int> resumePlayer(FlutterSoundPlayerCallback callback) async {
    return getWebSession(callback)!.resumePlayer();
  }

  @override
  Future<int> seekToPlayer(FlutterSoundPlayerCallback callback, {Duration? duration}) async {
    return getWebSession(callback)!.seekToPlayer(duration!.inMilliseconds);
  }

  Future<int> setVolume(FlutterSoundPlayerCallback callback, {double? volume}) async {
    return getWebSession(callback)!.setVolume(volume);
  }

  Future<int> setVolumePan(FlutterSoundPlayerCallback callback, {double? volume, double? pan}) async {
    return getWebSession(callback)!.setVolumePan(volume, pan);
  }

  Future<int> setSpeed(FlutterSoundPlayerCallback callback, {required double speed}) async {
    return getWebSession(callback)!.setSpeed(speed);
  }

  Future<String> getResourcePath(FlutterSoundPlayerCallback callback) async {
    return '';
  }
}
