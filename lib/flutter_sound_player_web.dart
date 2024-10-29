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

// Modified callback type to handle JS number conversion
extension type FlutterSoundPlayerCallbackJS._(JSObject _) implements JSObject {
  external factory FlutterSoundPlayerCallbackJS({
    JSFunction? updateProgress,
    JSFunction? updatePlaybackState,
    JSFunction? needSomeFood,
    JSFunction? audioPlayerFinished,
    JSFunction? startPlayerCompleted,
    JSFunction? pausePlayerCompleted,
    JSFunction? resumePlayerCompleted,
    JSFunction? stopPlayerCompleted,
    JSFunction? openPlayerCompleted,
    JSFunction? log
  });

  external JSNumber updateProgress(JSObject options);
  external JSNumber updatePlaybackState(JSNumber state);
  external JSNumber needSomeFood(JSNumber ln);
  external JSNumber audioPlayerFinished(JSNumber state);
  external JSNumber startPlayerCompleted(JSNumber state, JSBoolean success, JSNumber duration);
  external JSNumber pausePlayerCompleted(JSNumber state, JSBoolean success);
  external JSNumber resumePlayerCompleted(JSNumber state, JSBoolean success);
  external JSNumber stopPlayerCompleted(JSNumber state, JSBoolean success);
  external JSNumber openPlayerCompleted(JSNumber state, JSBoolean success);
  external JSNumber log(JSString logLevel, JSString msg);
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
      (FlutterSoundPlayerCallbackJS cb, int position, int duration) {
        callback.updateProgress(
          duration: duration,
          position: position,
        );
      }.toJS,
      (FlutterSoundPlayerCallbackJS cb, int state) {
        callback.updatePlaybackState(state);
      }.toJS,
      (FlutterSoundPlayerCallbackJS cb, int ln) {
        callback.needSomeFood(ln);
      }.toJS,
      (FlutterSoundPlayerCallbackJS cb, int state) {
        callback.audioPlayerFinished(state);
      }.toJS,
      (FlutterSoundPlayerCallbackJS cb, int state, bool success, int duration) {
        callback.startPlayerCompleted(state, success, duration);
      }.toJS,
      (FlutterSoundPlayerCallbackJS cb, int state, bool success) {
        callback.pausePlayerCompleted(state, success);
      }.toJS,
      (FlutterSoundPlayerCallbackJS cb, int state, bool success) {
        callback.resumePlayerCompleted(state, success);
      }.toJS,
      (FlutterSoundPlayerCallbackJS cb, int state, bool success) {
        callback.stopPlayerCompleted(state, success);
      }.toJS,
      (FlutterSoundPlayerCallbackJS cb, int state, bool success) {
        callback.openPlayerCompleted(state, success);
      }.toJS,
      (FlutterSoundPlayerCallbackJS cb, int level, String msg) {
        callback.log(Level.values[level], msg);
      }.toJS,
    ];

    return callbackFunctions.toJS;
  }

  FlutterSoundPlayerCallbackJS _createCallbackTable2(FlutterSoundPlayerCallback callback) {
    return FlutterSoundPlayerCallbackJS(
      updateProgress: ((JSNumber position, JSNumber duration) {
        callback.updateProgress(
          duration: duration.toDartInt,
          position: position.toDartInt,
        );
        return 0.toJS;
      }).toJS,
      updatePlaybackState: ((JSNumber state) {
        callback.updatePlaybackState(state.toDartInt);
        return 0.toJS;
      }).toJS,
      needSomeFood: ((JSNumber ln) {
        callback.needSomeFood(ln.toDartInt);
        return 0.toJS;
      }).toJS,
      audioPlayerFinished: ((JSNumber state) {
        callback.audioPlayerFinished(state.toDartInt);
        return 0.toJS;
      }).toJS,
      startPlayerCompleted: ((JSNumber state, JSBoolean success, JSNumber duration) {
        callback.startPlayerCompleted(
          state.toDartInt,
          success.toDart,
          duration.toDartInt,
        );
        return 0.toJS;
      }).toJS,
      pausePlayerCompleted: ((JSNumber state, JSBoolean success) {
        callback.pausePlayerCompleted(state.toDartInt, success.toDart);
        return 0.toJS;
      }).toJS,
      resumePlayerCompleted: ((JSNumber state, JSBoolean success) {
        callback.resumePlayerCompleted(state.toDartInt, success.toDart);
        return 0.toJS;
      }).toJS,
      stopPlayerCompleted: ((JSNumber state, JSBoolean success) {
        callback.stopPlayerCompleted(state.toDartInt, success.toDart);
        return 0.toJS;
      }).toJS,
      openPlayerCompleted: ((JSNumber state, JSBoolean success) {
        callback.openPlayerCompleted(state.toDartInt, success.toDart);
        return 0.toJS;
      }).toJS,
      log: ((JSString level, JSString msg) {
        callback.log(Level.values[int.parse(level.toDart)], msg.toDart);
        return 0.toJS;
      }).toJS,
    );
  }

  // Modified method implementations to handle JS number conversions
  @override
  Future<int> openPlayer(FlutterSoundPlayerCallback callback, {required Level logLevel}) async {
    int slotno = findSession(callback);
    if (slotno < _slots.length) {
      assert(_slots[slotno] == null);
      _slots[slotno] = newPlayerInstance(_createCallbackTable2(callback), _createCallbackTable(callback));
    } else {
      assert(slotno == _slots.length);
      _slots.add(newPlayerInstance(_createCallbackTable2(callback), _createCallbackTable(callback)));
    }
    return _slots[slotno]!.initializeMediaPlayer();
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
