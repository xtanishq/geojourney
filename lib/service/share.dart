import 'dart:io';
import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class ShareService {
  static bool isShare = false;
  static Future<void> shareImage(Uint8List imageBytes,BuildContext context,{String text = ''}) async {
    if(isShare){
      return;
    }
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return const CupertinoAlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoActivityIndicator( color: appColor,),
              AutoSizeText('Loading...'),
            ],
          ),
        );
      },
    );
    isShare = true;
    Future.delayed(Duration(seconds: 2),(){
      isShare = false;
    });
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.png');
      await tempFile.writeAsBytes(imageBytes);
      await Share.shareXFiles([XFile(tempFile.path)],/* text: text.isNotEmpty ? text : 'Check out this image!'*/);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Failed to share image',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: appColor,
        textColor: Colors.black,
      );
    }
  }

  static Future<void> shareNetworkImage(String imageUrl,BuildContext context, {String text = ''}) async {
    if(isShare){
      return;
    }
    // showCupertinoDialog(
    //   context: context,
    //   builder: (context) {
    //     return const CupertinoAlertDialog(
    //       content: Row(
    //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //         children: [
    //           CupertinoActivityIndicator( color: appColor,),
    //           AutoSizeText('Loading...'),
    //         ],
    //       ),
    //     );
    //   },
    // );
    isShare = true;
    Future.delayed(Duration(seconds: 2),(){
      isShare = false;
    });
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final Uint8List bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.png');
      await tempFile.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(tempFile.path)], text: text.isNotEmpty ? text : 'Check out this image!');
      // Navigator.pop(context);
    } catch (e) {
      // Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Failed to share image from URL',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: appColor,
        textColor: Colors.black,
      );
    }
  }

  static Future<void> shareUrl(String url,BuildContext context, {String text = ''}) async {
    if(isShare){
      return;
    }
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return const CupertinoAlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoActivityIndicator(color: appColor,radius: 18),
              AutoSizeText('Loading...',style: TextStyle(color: Colors.black,fontFamily: "regular")),
            ],
          ),
        );
      },
    );
    isShare = true;
    Future.delayed(Duration(seconds: 1),(){
      isShare = false;
    });
    try {
      await Share.share(url,/* subject: text.isNotEmpty ? text : 'Check out this link!'*/);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Failed to share URL',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: appColor,
        textColor: Colors.black,
      );
    }
  }

  static Future<void> shareVideo(String filePath,BuildContext context, {String text = ''}) async {
    if(isShare){
      return;
    }
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return const CupertinoAlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoActivityIndicator( color: appColor,),
              AutoSizeText('Loading...'),
            ],
          ),
        );
      },
    );
    isShare = true;
    Future.delayed(Duration(seconds: 2),(){
      isShare = false;
    });
    try {
      await Share.shareXFiles([XFile(filePath)]);

      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      print("Failed to share video: $e");
      Fluttertoast.showToast(
        msg: 'Failed to share video',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: appColor,
        textColor: Colors.black,
      );
    }
  }

  static Future<void> shareNetworkVideo(String videoUl,BuildContext context, {String text = ''}) async {
    if(isShare){
      return;
    }
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return const CupertinoAlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoActivityIndicator(color: appColor,radius: 18),
              AutoSizeText('Loading...',style: TextStyle(color: Colors.black,fontFamily: "regular")),
            ],
          ),
        );
      },
    );
    isShare = true;
    Future.delayed(Duration(seconds: 2),(){
      isShare = false;
    });
    try {
      final response = await http.get(Uri.parse(videoUl));
      final Uint8List bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_video.mp4');
      await tempFile.writeAsBytes(bytes);

      print(tempFile);
      await Share.shareXFiles([XFile(tempFile.path)]);

      print("tempFile.path  ${tempFile.path}");
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Failed to share Video',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: appColor,
        textColor: Colors.black,
      );
    }
  }

  static Future<void> shareFile(String filePath,BuildContext context, {String text = ''}) async {
    if(isShare){
      return;
    }
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return const CupertinoAlertDialog(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoActivityIndicator( color: appColor,),
              AutoSizeText('Loading...'),
            ],
          ),
        );
      },
    );
    isShare = true;
    Future.delayed(Duration(seconds: 2),(){
      isShare = false;
    });
    try {
      await Share.shareXFiles([XFile(filePath)]);

      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: 'Failed to share file',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: appColor,
        textColor: Colors.black,
      );
    }
  }
}
