import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:retry/retry.dart';

import 'firebase_http_file_service.dart';

/// Use [FirebaseCacheManager] if you want to download files from firebase storage
/// and store them in your local cache.
class FirebaseCacheManager extends CacheManager {
  static const key = 'firebaseCache';

  static final FirebaseCacheManager _instance = FirebaseCacheManager._(
    firebaseStorage: _firebaseStorage,
    bucket: _bucket,
    retryOptions: _retryOptions,
  );

  static late final FirebaseStorage? _firebaseStorage;
  static late final String? _bucket;
  static late final RetryOptions? _retryOptions;

  factory FirebaseCacheManager({
    FirebaseStorage? firebaseStorage,
    String? bucket,
    RetryOptions? retryOptions,
  }) {
    _firebaseStorage = firebaseStorage;
    _bucket = bucket;
    _retryOptions = retryOptions;
    return _instance;
  }

  FirebaseCacheManager._({
    FirebaseStorage? firebaseStorage,
    String? bucket,
    RetryOptions? retryOptions,
  }) : super(
          Config(
            key,
            fileService: FirebaseHttpFileService(
              firebaseStorage: firebaseStorage,
              bucket: bucket,
              retryOptions: retryOptions,
            ),
          ),
        );
}
