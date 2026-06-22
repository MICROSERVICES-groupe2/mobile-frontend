import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';

class DocumentService {
  final Dio dio;
  final ImagePicker picker = ImagePicker();

  DocumentService({required this.dio});

  Future<void> scanAndUpload(String loanId) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(image.path, filename: "doc.jpg"),
        "loanId": loanId
      });
      await dio.post(ApiConstants.ocrPath, data: formData);
    }
  }
}
