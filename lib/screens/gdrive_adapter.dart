import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:http/io_client.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

/*
// For applications
class GoogleHttpClient extends IOClient {
  Map<String, String> _headers;
  GoogleHttpClient(this._headers) : super();
  @override
  Future<IOStreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));
  @override
  Future<http.Response> head(Object url, {Map<String, String>? headers}) =>
      super.head(url as Uri, headers: headers!..addAll(_headers));
}
*/

// For web
class GoogleHttpClient extends BrowserClient {
  Map<String, String> _headers;
  GoogleHttpClient(this._headers) : super();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) => super.send(request..headers.addAll(_headers));
  @override
  Future<http.Response> head(Object url, {Map<String, String>? headers}) =>
      super.head(url as Uri, headers: headers!..addAll(_headers));
}

class GoogleDriveAdapter {
  GoogleDriveAdapter() {}

  GoogleSignIn googleSignIn = GoogleSignIn(scopes: [ga.DriveApi.driveScope]);

  final storage = new FlutterSecureStorage();
  GoogleSignInAccount? gsa;
  bool isSignedIn() {
    return gsa != null;
  }

  bool isInitialized = false;
  String errmsg = '';

  ga.FileList? gfilelist = null;

  // top folder of this project
  String gcmsFolderName = 'gcms';
  String? gcmsFolderId;

  String contentsFolderName = 'contents';
  String? contentsFolderId;

  String dataFolderName = 'data';
  String? dataFolderId;

  String settingsFileName = 'settings.json';
  String? settingsFileId;

  /// displayName
  String getAccountName() {
    String r = 'None';
    if (gsa != null) {
      if (gsa!.displayName != null) {
        r = '${gsa!.displayName!}\n${gsa!.email}';
      } else {
        r = '${gsa!.email}';
      }
    }
    return r;
  }

  /// Already logged in
  Future<bool> loginSilently() async {
    gsa = null;
    errmsg = '';
    try {
      if (await storage.read(key: 'signedIn') == 'true') {
        gsa = await googleSignIn.signInSilently();
        if (gsa == null) {
          storage.write(key: 'signedIn', value: 'false');
        }
      }
    } on Exception catch (e) {
      print('-- err loginSilently() ${e.toString()}');
      errmsg = e.toString();
    }
    isInitialized = true;
    print('-- loginSilently() is ${gsa != null}');
    return gsa != null;
  }

  // New account or Existing account
  // com.google.android.gms.common.api.ApiException: 10 is finger print
  Future<bool> loginWithGoogle() async {
    print('-- loginWithGoogle()');
    errmsg = '';
    try {
      gsa = await googleSignIn.signIn();
      if (gsa != null) {
        storage.write(key: 'signedIn', value: 'true');
      }
    } on Exception catch (e) {
      print('-- err loginWithGoogle() ${e.toString()}');
      errmsg = e.toString();
    }
    print('-- loginWithGoogle() is ${gsa != null}');
    return gsa != null;
  }

  Future logout() async {
    print('-- logout');
    await googleSignIn.signOut();
    await storage.write(key: 'signedIn', value: 'false');
    gsa = null;
  }

  Future<String> getFolderNameFromId(String folderId) async {
    String name = '';
    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);
    try {
      if (gcmsFolderId == folderId) return gcmsFolderName;

      String q = "mimeType='application/vnd.google-apps.folder'";
      q += " and trashed=False";
      q += " and '${gcmsFolderId}' in parents";
      ga.FileList folders = await drive.files.list(q: q);

      if (folders.files != null) {
        for (ga.File f in folders.files!) {
          //print('-- folders name=${f.name} id=${f.id} ');
          if (f.id == folderId) {
            name = f.name ?? '';
          }
        }
      }
    } on Exception catch (e) {
      print('-- err getFolderNameFromId ${e.toString()}');
    }
    return name;
  }

  Future<void> getGcmsFolderId() async {
    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);
    try {
      // top folder id
      if (gcmsFolderId == null) {
        String q = "mimeType='application/vnd.google-apps.folder'";
        q += " and name='${gcmsFolderName}'";
        q += " and trashed=False";
        q += " and 'root' in parents";
        ga.FileList folders = await drive.files.list(q: q);

        if (folders.files != null) {
          for (ga.File f in folders.files!) {
            if (f.name == gcmsFolderName) {
              gcmsFolderId = f.id ?? null;
            }
          }
        }
      }
      if (gcmsFolderId != null && contentsFolderId == null) {
        String q = "mimeType='application/vnd.google-apps.folder'";
        q += " and name='${contentsFolderName}'";
        q += " and trashed=False";
        q += " and '${gcmsFolderId}' in parents";
        ga.FileList folders = await drive.files.list(q: q);

        if (folders.files != null) {
          for (ga.File f in folders.files!) {
            if (f.name == contentsFolderName) {
              contentsFolderId = f.id ?? null;
            }
          }
        }
      }
      if (gcmsFolderId != null && dataFolderId == null) {
        String q = "mimeType='application/vnd.google-apps.folder'";
        q += " and name='${dataFolderName}'";
        q += " and trashed=False";
        q += " and '${gcmsFolderId}' in parents";
        ga.FileList folders = await drive.files.list(q: q);

        if (folders.files != null) {
          for (ga.File f in folders.files!) {
            if (f.name == dataFolderName) {
              dataFolderId = f.id ?? null;
            }
          }
        }
      }
    } on Exception catch (e) {
      print('-- err _getFiles=${e.toString()}');
    }
  }

  Future<void> getFiles() async {
    print('-- getFiles');
    if (isSignedIn() == false) {
      print('-- not SignedIn');
      return;
    }

    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);
    try {
      // top folder id
      if (contentsFolderId == null) {
        await getGcmsFolderId();
      }
      if (contentsFolderId != null) {
        // File list
        String q = "";
        q += "trashed=False";
        q += " and '${contentsFolderId}' in parents";
        gfilelist = await drive.files.list(
          q: q,
          $fields: '*',
          orderBy: 'name',
        );
        print('gfilelist.length=${gfilelist!.files!.length}');
      }
    } on Exception catch (e) {
      print('-- err getFiles=${e.toString()}');
    }
  }

  Future<void> uploadFile(String path) async {
    print('-- GoogleDriveAdapter.uploadFile');
    if (isSignedIn() == false) {
      print('-- not SignedIn');
      return;
    }
    if (gcmsFolderId == null) {
      await getGcmsFolderId();
      if (gcmsFolderId == null) {
        print('-- not folderId');
        return;
      }
    }
    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);

    var request = new ga.File();
    File file = File(path);
    request.name = basename(path);
    request.parents = [];
    request.parents!.add(gcmsFolderId!);

    var res = await drive.files.create(request, uploadMedia: ga.Media(file.openRead(), file.lengthSync()));
    print(res);
  }

  /// fileId = gfilelist!.files![n].id
  Future<void> deleteFile(String fileId) async {
    if (isSignedIn() == false) {
      print('-- not SignedIn');
      return;
    }
    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);

    drive.files.delete(fileId);
    gfilelist!.files!.removeAt(0);
  }

  Future<void> getSettingsFileId() async {
    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);
    try {
      print('-- getSettingsFileId()');
      if (settingsFileId == null) {
        String q = "";
        q += "trashed=False";
        q += " and '${dataFolderId}' in parents";
        ga.FileList folders = await drive.files.list(q: q);

        print('-- len=${folders.files!.length} id=${gcmsFolderId}');
        if (folders.files != null) {
          for (ga.File f in folders.files!) {
            if (f.name == settingsFileName) {
              settingsFileId = f.id ?? null;
            }
          }
        }
        if (settingsFileId == null) {
          print('-- getSettingsFileId() create');
          String conf = '{"aaa":"bbb"}';
          Uint8List bytes = Uint8List.fromList(conf.codeUnits);

          var request = new ga.File();
          request.name = settingsFileName;
          request.parents = [];
          request.parents!.add(dataFolderId!);

          ga.Media fileMedia =
              ga.Media(http.ByteStream.fromBytes(bytes), bytes.length, contentType: 'application/json');
          var res = await drive.files.create(request, uploadMedia: fileMedia);
          print('-- getSettingsFileId() ${res}');
        }
      }
    } on Exception catch (e) {
      print('-- err getSettingsFileId=${e.toString()}');
    }
  }

  Future<void> updateSettings() async {
    print('-- GoogleDriveAdapter.updateSettings()');
    if (isSignedIn() == false) {
      print('-- not SignedIn');
      return;
    }
    if (settingsFileId == null) {
      await getSettingsFileId();
      if (settingsFileId == null) {
        print('-- not settingsFileId');
        return;
      }
    }
    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);

    String conf = '{"aaa":"bbb"}';
    Uint8List bytes = Uint8List.fromList(conf.codeUnits);

    var request = new ga.File();
    request.name = settingsFileName;
    request.parents = [];
    request.parents!.add(gcmsFolderId!);

    ga.Media fileMedia = ga.Media(http.ByteStream.fromBytes(bytes), bytes.length, contentType: 'application/json');
    var res = await drive.files.update(request, settingsFileId!, uploadMedia: fileMedia);
    print(res);
  }
}
