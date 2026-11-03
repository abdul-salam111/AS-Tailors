// import 'package:file_picker/file_picker.dart';

// class PickedFile {
//   final String name;
//   final String path;

//   PickedFile({required this.name, required this.path});
// }

// Future<List<PickedFile>> pickFiles({bool allowMultiple = true}) async {
//   final result = await FilePicker.platform.pickFiles(
//     allowMultiple: allowMultiple,
//     type: FileType.custom,
//     allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
//   );
//   if (result != null) {
//     return result.files
//         .where((f) => f.path != null)
//         .map((f) => PickedFile(name: f.name, path: f.path!))
//         .toList();
//   }
//   return [];
// }

// String getFileIcon(String filePath) {
//   final extension = filePath.split('.').last.toLowerCase();

//   switch (extension) {
//     case 'png':
//       return "assets/icons/png.png";
//     case 'jpg':
//       return "assets/icons/png.png";
//     case 'jpeg':
//       return "assets/icons/png.png"; // image icon
//     case 'pdf':
//       return "assets/icons/pdf2.png"; // make sure you have this asset
//     case 'doc':
//     case 'docx':
//       return "assets/icons/word.png"; // optional for Word files
//     default:
//       return "assets/icons/png.png"; // fallback generic file icon
//   }
// }
