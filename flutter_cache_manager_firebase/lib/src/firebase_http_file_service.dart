import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:retry/retry.dart';

/// [FirebaseHttpFileService] is another common file service which parses a
/// firebase reference into, to standard url which can be passed to the
/// standard [HttpFileService].
class FirebaseHttpFileService extends HttpFileService {
  FirebaseHttpFileService({
    final FirebaseStorage? firebaseStorage,
    final String? bucket,
    this.retryOptions,
  }) : super() {
    if (firebaseStorage != null) {
      _fs = firebaseStorage;
    } else if (bucket != null) {
      _fs = FirebaseStorage.instanceFor(bucket: "gs://$bucket");
    } else {
      _fs = FirebaseStorage.instance;
    }
  }

  late final FirebaseStorage _fs;
  final RetryOptions? retryOptions;

  @override
  Future<FileServiceResponse> get(String url,
      {Map<String, String>? headers}) async {
    final Reference ref;
    if (url.startsWith("gs://")) {
      ref = _fs.refFromURL(url);
    } else {
      ref = _fs.ref(url);
    }

    String downloadUrl;
    if (retryOptions != null) {
      downloadUrl = await retryOptions!.retry(
        () async => await ref.getDownloadURL(),
        retryIf: (e) => e is FirebaseException,
      );
    } else {
      downloadUrl = await ref.getDownloadURL();
    }
    return super.get(downloadUrl);
  }
}
