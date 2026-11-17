import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:financial_ai_advisor/core/network/etag_interceptor.dart';
import 'package:financial_ai_advisor/core/network/sse.dart';
import 'package:flutter_test/flutter_test.dart';

/// Serveur factice : rejoue les réponses de [repondre] et garde les requêtes reçues.
class _Adaptateur implements HttpClientAdapter {
  final ResponseBody Function(RequestOptions) repondre;
  final requetes = <RequestOptions>[];
  _Adaptateur(this.repondre);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requetes.add(options);
    return repondre(options);
  }

  @override
  void close({bool force = false}) {}
}

Stream<List<int>> _octets(List<String> morceaux) => Stream.fromIterable(morceaux.map(utf8.encode));

void main() {
  group('lireSse', () {
    test('découpe les événements, même coupés au milieu d’une ligne', () async {
      final evenements = await lireSse(
        _octets([
          'event: delta\ndata: {"text": "Bon',
          'jour"}\n\n: commentaire\nevent: delta\ndata: {"text": " é"}\n\n',
          'event: done\ndata: {"assistant": {"used": 1, "limit": 3}}\n\n',
        ]),
      ).toList();

      expect(evenements.map((e) => e.nom), ['delta', 'delta', 'done']);
      expect(evenements[0].donnees, {'text': 'Bonjour'});
      expect(evenements[1].donnees, {'text': ' é'});
      expect(evenements[2].donnees['assistant']['limit'], 3);
    });

    test('rend le dernier événement sans ligne vide finale', () async {
      final evenements = await lireSse(_octets(['event: error\ndata: {"message": "Quota"}'])).toList();
      expect(evenements.single.nom, 'error');
    });
  });

  group('EtagInterceptor', () {
    test('rend le corps gardé quand l’API répond 304', () async {
      var appels = 0;
      final adaptateur = _Adaptateur((options) {
        appels++;
        if (options.headers['If-None-Match'] == 'W/"v1"') {
          return ResponseBody.fromString(
            '',
            304,
            headers: {
              'etag': ['W/"v1"'],
            },
          );
        }
        return ResponseBody.fromString(
          '{"data": {"cours": 1500}}',
          200,
          headers: {
            'etag': ['W/"v1"'],
            'content-type': ['application/json'],
          },
        );
      });
      final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
        ..httpClientAdapter = adaptateur
        ..interceptors.add(EtagInterceptor());

      final premiere = await dio.get('/market');
      final seconde = await dio.get('/market');

      expect(appels, 2);
      expect(adaptateur.requetes.first.headers.containsKey('If-None-Match'), isFalse);
      expect(adaptateur.requetes.last.headers['If-None-Match'], 'W/"v1"');
      expect(seconde.statusCode, 200);
      expect(seconde.data, premiere.data);
    });

    test('ne garde que les plus récentes', () async {
      final adaptateur = _Adaptateur(
        (options) => ResponseBody.fromString(
          '{}',
          200,
          headers: {
            'etag': ['W/"${options.path}"'],
            'content-type': ['application/json'],
          },
        ),
      );
      final dio = Dio(BaseOptions(baseUrl: 'http://api.test'))
        ..httpClientAdapter = adaptateur
        ..interceptors.add(EtagInterceptor(taille: 1));

      await dio.get('/a');
      await dio.get('/b');
      await dio.get('/a');

      // /a a été chassé par /b : redemandé sans ETag.
      expect(adaptateur.requetes.last.headers.containsKey('If-None-Match'), isFalse);
    });
  });
}
