import 'package:dio/dio.dart';

/// Revalidation des GET qui renvoient un ETag (marché, analyse d'un titre).
///
/// L'API répond 304 sans corps (et sans refaire le calcul) quand la version
/// gardée ici est toujours la bonne : on rend alors le corps enregistré,
/// comme si l'API l'avait renvoyé. Les cours ne changent qu'à l'import du
/// soir : la plupart des rafraîchissements de la journée finissent ainsi.
///
/// L'ETag de l'API dépend des données et des réglages, pas du compte : deux
/// comptes aux mêmes réglages reçoivent le même corps, la clé peut donc
/// être l'adresse seule.
class EtagInterceptor extends Interceptor {
  /// Nombre de réponses gardées en mémoire (les plus récentes).
  final int taille;

  EtagInterceptor({this.taille = 50});

  final _cache = <String, ({String etag, dynamic data})>{};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final entree = options.method == 'GET' ? _cache[_cle(options)] : null;
    if (entree != null) options.headers['If-None-Match'] = entree.etag;
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final etag = response.headers.value('etag');
    if (options.method == 'GET' && response.statusCode == 200 && etag != null) {
      final cle = _cle(options);
      _cache
        ..remove(cle)
        ..[cle] = (etag: etag, data: response.data);
      if (_cache.length > taille) _cache.remove(_cache.keys.first);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final entree = err.response?.statusCode == 304 ? _cache[_cle(err.requestOptions)] : null;
    if (entree == null) return handler.next(err);
    handler.resolve(
      Response(requestOptions: err.requestOptions, data: entree.data, statusCode: 200, headers: err.response!.headers),
    );
  }

  String _cle(RequestOptions options) => options.uri.toString();
}
