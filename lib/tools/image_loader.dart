import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<File> loadImages(
    {@required List<String> listOfImageUrls, int retryTimes = 1}) async {

  if (!getIt.isRegistered(instance: DefaultCacheManager()))
    getIt.registerSingleton<BaseCacheManager>(DefaultCacheManager());


  /// We iterate the list for downloading each image from the image url
  await Future.forEach(listOfImageUrls, (item) async {

    /// We first have to check if the file is already present in the cache or not
    FileInfo fileInfo =
    await GetIt.instance.get<BaseCacheManager>().getFileFromCache(item);
    bool fileExists = false;

    /// if file exists then var fileExists is set to true , else false
    if (fileInfo != null) {
      fileExists = await fileInfo.file.exists();
    }


    /// if the file does not exists , then we download it in the cache
    int i = 0;
    do {
    if (!fileExists) {
      try {
        await GetIt.instance.get<BaseCacheManager>().downloadFile(item);
        final file = (await GetIt.instance.get<BaseCacheManager>().getFileFromCache(item)).file;
        fileExists = await file.exists();
        if (fileExists)
          return file;
      } catch (e) {
        /// if file url is incorrect or corrupted then we move on to next url
        //debugPrint('Error in downloading image $e');
      }
    }} while (!fileExists && i < retryTimes);
  }).timeout(const Duration(seconds: 60));
}