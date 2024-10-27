/*
 * Copyright 2018, 2019, 2020 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 3 (LGPL-V3), as published by
 * the Free Software Foundation.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Flutter-Sound.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'package:web/web.dart' as web; // Add

//import 'package:meta/meta.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:flutter_sound_web/flutter_sound_player_web.dart';
import 'package:flutter_sound_web/flutter_sound_recorder_web.dart';
import 'package:flutter/foundation.dart';

var mime_types = [
  'audio/webm\;codecs=opus', // defaultCodec,
  'audio/aac', // aacADTS, //*
  'audio/opus\;codecs=opus', // opusOGG, // 'audio/ogg' 'audio/opus'
  'audio/x-caf', // opusCAF,
  'audio/mpeg', // mp3, //*
  'audio/ogg\;codecs=vorbis', // vorbisOGG,// 'audio/ogg' // 'audio/vorbis'
  'audio/pcm', // pcm16,
  'audio/wav\;codecs=1', // pcm16WAV,
  'audio/aiff', // pcm16AIFF,
  'audio/x-caf', // pcm16CAF,
  'audio/x-flac', // flac, // 'audio/flac'
  'audio/mp4', // aacMP4, //*
  'audio/AMR', // amrNB, //*
  'audio/AMR-WB', // amrWB, //*
  'audio/pcm', // pcm8,
  'audio/pcm', // pcmFloat32,
  'audio/webm\;codecs=pcm', // pcmWebM,
  'audio/webm\;codecs=opus', // opusWebM,
  'audio/webm\;codecs=vorbis', // vorbisWebM
];

class ImportJsLibraryWeb {
  /// Injects the library by its [url]
  static Future<void> import(String url) {
    return _importJSLibraries([url]);
  }

  static web.HTMLScriptElement _createScriptTag(String library) {
    final web.HTMLScriptElement script = web.HTMLScriptElement()
      ..type = "text/javascript"
      ..charset = "utf-8"
      ..async = true
      //..defer = true
      ..src = library;
    return script;
  }

  /// Injects a bunch of libraries in the <head> and returns a
  /// Future that resolves when all load.
  static Future<void> _importJSLibraries(List<String> libraries) {
    final List<Future<void>> loading = <Future<void>>[];
    final head = web.document.querySelector('head')!;

    libraries.forEach((String library) {
      if (!isImported(library)) {
        final scriptTag = _createScriptTag(library);
        head.append(scriptTag);
        loading.add(scriptTag.onLoad.first);
      }
    });

    return Future.wait(loading);
  }

  static bool _isLoaded(web.Element head, String url) {
    if (url.startsWith("./")) {
      url = url.replaceFirst("./", "");
    }

    final length = head.children.length;
    for (var i = 0; i < length; i++) {
      final element = head.children.item(i);
      if (element is web.HTMLScriptElement) {
        if (element.src.endsWith(url)) {
          return true;
        }
      }
    }

    return false;
  }

  static bool isImported(String url) {
    final web.Element head = web.document.querySelector('head')!;
    return _isLoaded(head, url);
  }
}

class ImportJsLibrary {
  static Future<void> import(String url) {
    if (kIsWeb)
      return ImportJsLibraryWeb.import(url);
    else
      return Future.value(null);
  }

  static bool isImported(String url) {
    if (kIsWeb) {
      return ImportJsLibraryWeb.isImported(url);
    } else {
      return false;
    }
  }

  static registerWith(dynamic _) {
    // useful for flutter registrar
  }
}

String _libraryUrl(String url, String pluginName) {
  if (url.startsWith("./")) {
    url = url.replaceFirst("./", "");
    return "./assets/packages/$pluginName/$url";
  }
  if (url.startsWith("assets/")) {
    return "./assets/packages/$pluginName/$url";
  } else {
    return url;
  }
}

void importJsLibrary({required String url, required String flutterPluginName}) {
  ImportJsLibrary.import(_libraryUrl(url, flutterPluginName)).then((value) {
    --FlutterSoundPlugin._numberOfScripts;
    if (FlutterSoundPlugin._numberOfScripts == 0) {
      FlutterSoundPlugin.ScriptLoaded.complete();
    }
  });
}

bool isJsLibraryImported(String url, {required String flutterPluginName}) {
  //if (flutterPluginName == null) {
  //        return ImportJsLibrary.isImported(url);
  //} else {
  return ImportJsLibrary.isImported(_libraryUrl(url, flutterPluginName));
  //}
}

/// The web implementation of [FlutterSoundRecorderPlatform].
///
/// This class implements the `package:FlutterSoundPlayerPlatform` functionality for the web.
class FlutterSoundPlugin //extends FlutterSoundPlatform
{
  static int _numberOfScripts = 4;
  static Completer ScriptLoaded = Completer();

  /// Registers this class as the default instance of [FlutterSoundPlatform].
  static void registerWith(Registrar registrar) {
    FlutterSoundPlayerWeb.registerWith(registrar);
    FlutterSoundRecorderWeb.registerWith(registrar);
    importJsLibrary(
        url: "./howler/howler.js", flutterPluginName: "flutter_sound_web");
    importJsLibrary(
        url: "./src/flutter_sound.js", flutterPluginName: "flutter_sound_web");
    importJsLibrary(
        url: "./src/flutter_sound_player.js",
        flutterPluginName: "flutter_sound_web");
    importJsLibrary(
        url: "./src/flutter_sound_recorder.js",
        flutterPluginName: "flutter_sound_web");
  }
}
