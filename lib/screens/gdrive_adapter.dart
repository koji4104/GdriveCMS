import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';
import 'package:http/io_client.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      super.send(request..headers.addAll(_headers));
  @override
  Future<http.Response> head(Object url, {Map<String, String>? headers}) =>
      super.head(url as Uri, headers: headers!..addAll(_headers));
}

class GoogleDriveAdapter {
  GoogleDriveAdapter(){}

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes:[ga.DriveApi.driveScope]
  );

  final storage = new FlutterSecureStorage();
  GoogleSignInAccount? gsa;
  bool isSignedIn(){ return gsa!=null; }
  bool isInitialized = false;
  String errmsg = '';

  ga.FileList? gfilelist = null;

  // top folder of this project
  String topFolderName = 'Test';
  String? topFolderId;

  /// displayName
  String getAccountName(){
    String r = 'None';
    if(gsa!=null){
      if(gsa!.displayName!=null) {
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
    try{
      if (await storage.read(key:'signedIn')=='true') {
        gsa = await googleSignIn.signInSilently();
        if(gsa==null){
          storage.write(key:'signedIn',value:'false');
        }
      }
    } on Exception catch (e) {
      print('-- err loginSilently() ${e.toString()}');
      errmsg = e.toString();
    }
    isInitialized = true;
    print('-- loginSilently() is ${gsa!=null}');
    return gsa!=null;
  }

  // New account or Existing account
  // com.google.android.gms.common.api.ApiException: 10 is finger print
  Future<bool> loginWithGoogle() async {
    print('-- loginWithGoogle()');
    errmsg = '';
    try{
      gsa = await googleSignIn.signIn();
      if(gsa!=null) {
        storage.write(key:'signedIn',value:'true');
      }
    } on Exception catch (e) {
      print('-- err loginWithGoogle() ${e.toString()}');
      errmsg = e.toString();
    }
    print('-- loginWithGoogle() is ${gsa!=null}');
    return gsa!=null;
  }

  Future logout() async {
    print('-- logout');
    await googleSignIn.signOut();
    await storage.write(key:'signedIn',value:'false');
    gsa = null;
  }

  Future<String> getFolderNameFromId(String folderId) async {
    String name = '';
    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);
    try {
      if(topFolderId == folderId)
        return topFolderName;

      String q = "mimeType='application/vnd.google-apps.folder'";
      q += " and trashed=False";
      q += " and '${topFolderId}' in parents";
      ga.FileList folders = await drive.files.list(q:q);

      if (folders.files != null) {
        for (ga.File f in folders.files!) {
          print('-- folders name=${f.name} id=${f.id} ');
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

  Future<void> getTopFolderId() async {
    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);
    try {
      // top folder id
      if (topFolderId == null) {
        String q = "mimeType='application/vnd.google-apps.folder'";
        q += " and name='${topFolderName}'";
        q += " and trashed=False";
        q += " and 'root' in parents";
        ga.FileList folders = await drive.files.list(q:q);

        if (folders.files != null) {
          for (ga.File f in folders.files!) {
            if (f.name == topFolderName) {
              topFolderId = f.id ?? null;
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
    if(isSignedIn()==false) {
      print('-- not SignedIn');
      return;
    }

    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);
    try{
      // top folder id
      if(topFolderId==null) {
        await getTopFolderId();
      }
      if(topFolderId!=null) {
        // File list
        //String q = 'mimeType=="application/vnd.google-apps.folder"';
        String q = '';
        q += "trashed=False";
        q += ' and "${topFolderId}" in parents';
        gfilelist = await drive.files.list(
          q:q,
          $fields:'*',
          orderBy:'name',
        );
        print('gfilelist.length=${gfilelist!.files!.length}');
      }
    } on Exception catch (e) {
      print('-- err getFiles=${e.toString()}');
    }
  }

  Future<void> uploadFile(String path) async {
    print('-- GoogleDriveAdapter.uploadFile');
    if(isSignedIn()==false) {
      print('-- not SignedIn');
      return;
    }
    if(topFolderId==null) {
      await getTopFolderId();
      if(topFolderId==null) {
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
    request.parents!.add(topFolderId!);

    var res = await drive.files.create(
        request,
        uploadMedia:ga.Media(file.openRead(),file.lengthSync()));
    print(res);
  }

  /// fileId = gfilelist!.files![n].id
  Future<void> deleteFile(String fileId) async {
    if(isSignedIn()==false) {
      print('-- not SignedIn');
      return;
    }
    var client = GoogleHttpClient(await gsa!.authHeaders);
    var drive = ga.DriveApi(client);

    drive.files.delete(fileId);
    gfilelist!.files!.removeAt(0);
  }
}
