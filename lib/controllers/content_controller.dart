import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '/screens/gdrive_adapter.dart';
import '/models/content.dart';
import 'package:googleapis/drive/v3.dart' as ga;

final gdriveProvider = ChangeNotifierProvider((ref) => GdriveNotifier(ref));

class GdriveNotifier extends ChangeNotifier {
  GoogleDriveAdapter gdrive = GoogleDriveAdapter();
  List<ContentData> files = [];

  GdriveNotifier(ref) {
    gdrive.loginSilently().then((r) {
      this.notifyListeners();
    });
  }

  Future<List<ContentData>> getFiles() async {
    files = [];
    await gdrive.getFiles();
    if (gdrive.gfilelist != null && gdrive.gfilelist!.files != null) {
      for (ga.File f in gdrive.gfilelist!.files!) {
        ContentData d = ContentData();
        d.name = f.name ?? '';
        d.createdTime = f.createdTime ?? null;
        d.bytes = f.size != null ? int.parse(f.size!) : 0;
        d.mimeType = f.mimeType;
        d.id = f.id;
        d.thumbnailLink = f.thumbnailLink;
        d.webViewLink = f.webViewLink;
        d.kind = f.kind;
        d.folderColorRgb = f.folderColorRgb;
        if (f.parents != null && f.parents!.length > 0) {
          String parentid = f.parents![0];
          d.parent = await gdrive.getFolderNameFromId(parentid);
        }
        files.add(d);
      }
    }
    this.notifyListeners();

    await gdrive.getSettingsFileId();
    print('-- settingsId=${gdrive.settingsFileId}');

    return files;
  }

  void loginSilently() {
    gdrive.loginSilently().then((_) {
      this.notifyListeners();
    });
  }

  void loginWithGoogle() {
    gdrive.loginWithGoogle().then((_) {
      this.notifyListeners();
    });
  }

  void logout() {
    gdrive.logout().then((_) {
      this.notifyListeners();
    });
  }

  String getAccountName() {
    return gdrive.getAccountName();
  }
}

final contentProvider = ChangeNotifierProvider((ref) => ContentNotifier(ref));

class ContentNotifier extends ChangeNotifier {
  List<ContentData> selectedList = [];
  ContentData? selected;

  ContentNotifier(ref) {}

  select(ContentData d) {
    selected = d;
    this.notifyListeners();
  }

  bool isSelected(ContentData d) {
    if (selected == null)
      return false;
    else
      return selected!.id == d.id;
  }

  multiSelect(ContentData d) {
    if (selectedList.contains(d)) {
      selectedList.remove(d);
    } else {
      selectedList.add(d);
    }
    this.notifyListeners();
  }

  bool contains(ContentData d) {
    return selectedList.contains(d);
  }
}
