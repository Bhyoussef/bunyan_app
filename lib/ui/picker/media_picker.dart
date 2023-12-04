import 'dart:io';
import 'dart:typed_data';
import 'package:bunyan/localization/language/languages.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MediaPicker {
  static final _picker = ImagePicker();
  static bool clickable = true;

  static Future<MediaItem> getMedia(BuildContext context) async {
    final data = await showDialog<MediaItem>(
        barrierDismissible: !clickable,
        context: context,
        builder: (context) => WillPopScope(
          onWillPop: () async {
            return !clickable;
          },
          child: Dialog(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 50.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 30.sp, bottom: 50.sp),
                    child: Text(
                      Languages.of(context).pickertitle,
                      style: GoogleFonts.cairo(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.black),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        onTap: !clickable
                            ? null
                            : () async {
                          final data =
                          await _getFiles(pickVideo: true);
                          Navigator.pop(context, data);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color:
                                clickable ? Colors.blue : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(30.sp),
                              child: Icon(
                                Icons.videocam_sharp,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              Languages.of(context).adVideo,
                              style: GoogleFonts.cairo(
                                  color:
                                  clickable ? Colors.blue : Colors.grey,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: !clickable
                            ? null
                            : () async {
                          final data =
                          await _getFiles(pickVideo: false);
                          Navigator.pop(context, data);
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color:
                                clickable ? Colors.blue : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(30.sp),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              Languages.of(context).adPhoto,
                              style: GoogleFonts.cairo(
                                  color:
                                  clickable ? Colors.blue : Colors.grey,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
    clickable = true;
    return data;
  }

  static Future<MediaItem> _getFiles({bool pickVideo = false}) async {
    PermissionStatus permission;
    if (Platform.isIOS)
      permission = await Permission.photos.status;
    else
      permission = await Permission.storage.status;
    print('permission isss  $permission');
    if (permission.isDenied || permission.isRestricted) {
      if (Platform.isIOS)
        await Permission.photos.request();
      else {
        final p = await Permission.storage.request();
        if (p.isDenied)
          openAppSettings();
      }
      return null;
    }
    if (permission.isPermanentlyDenied) {
      openAppSettings();
      return null;
    }
    clickable = false;
    PickedFile file;
    if (pickVideo)
      file = await _picker.getVideo(source: ImageSource.gallery);
    else
      file = await _picker.getImage(source: ImageSource.gallery);
    if (file != null) {
      final thumb = pickVideo
          ? await VideoThumbnail.thumbnailData(video: file.path)
          : await file.readAsBytes();
      return MediaItem(thumb, !pickVideo, File(file.path));
    }
    return null;

  }
}

class MediaItem {
  final Uint8List thumb;
  final bool isPhoto;
  final File file;

  MediaItem(this.thumb, this.isPhoto, this.file);
}
