
class ContentData {
  FileData() {}
  String name = '';
  DateTime? createdTime;
  int bytes = 0;

  /// - image/jpeg
  /// - video/mp4
  /// - application/vnd.google-apps.folder
  String? mimeType;

  String? id;
  String? thumbnailLink;
  String? webViewLink;
  String? parent;
  String? kind;
  String? folderColorRgb;
}