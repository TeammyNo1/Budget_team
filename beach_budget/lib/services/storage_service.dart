import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class SlipUpload {
  final String url;
  final String path;
  const SlipUpload(this.url, this.path);
}

class StorageService {
  StorageService(this.uid);
  final String uid;

  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  /// เลือกรูปสลิปจากกล้องหรือคลังภาพ — ย่อขนาดตั้งแต่ต้นทางเพื่อประหยัดพื้นที่
  Future<File?> pickSlip({required bool fromCamera}) async {
    final x = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1400,
      imageQuality: 78,
    );
    return x == null ? null : File(x.path);
  }

  Future<SlipUpload> uploadSlip(File file) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'slips/$uid/$name';
    final ref = _storage.ref(path);
    await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    final url = await ref.getDownloadURL();
    return SlipUpload(url, path);
  }

  /// ลบสลิปทิ้ง — เงียบไว้ถ้าไฟล์หายไปแล้ว จะได้ไม่ขัดการลบรายการ
  Future<void> deleteSlip(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      await _storage.ref(path).delete();
    } on FirebaseException {
      // ไฟล์ไม่มีอยู่แล้ว — ข้ามไป
    }
  }
}
