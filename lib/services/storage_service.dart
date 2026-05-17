import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

// ════════════════════════════════════════════════════════════════
// HerCare - Storage Service
// Service de stockage Firebase
// ════════════════════════════════════════════════════════════════

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ══════════════════════════════════════════════════════════════
  // PROFILE IMAGES / IMAGES DE PROFIL
  // صور الملف الشخصي
  // ══════════════════════════════════════════════════════════════

  /// Upload profile image for any user type
  /// Télécharger une image de profil pour tout type d'utilisateur
  Future<String?> uploadProfileImage({
    required String userId,
    required String userType,
    required dynamic file,
  }) async {
    try {
      // Validate user type / Valider le type d'utilisateur
      const validTypes = ['doctor', 'nurse', 'patient', 'admin'];
      if (!validTypes.contains(userType)) {
        debugPrint('Invalid user type: $userType');
        return null;
      }

      // Validate file / Valider le fichier
      if (file == null) {
        debugPrint('File is null');
        return null;
      }

      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'profiles/$userType/$userId/$fileName';
      final ref = _storage.ref().child(path);

      UploadTask uploadTask;

      // Upload based on platform / Télécharger selon la plateforme
      if (kIsWeb) {
        if (file is! Uint8List) {
          debugPrint('Expected Uint8List for web platform');
          return null;
        }

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'userType': userType,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        );

        uploadTask = ref.putData(file, metadata);
      } else {
        if (file is! File) {
          debugPrint('Expected File for mobile platform');
          return null;
        }

        if (!file.existsSync()) {
          debugPrint('File does not exist: ${file.path}');
          return null;
        }

        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'userType': userType,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        );

        uploadTask = ref.putFile(file, metadata);
      }

      // Wait for upload to complete / Attendre la fin du téléchargement
      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        debugPrint('Profile image uploaded: $downloadUrl');
        return downloadUrl;
      }

      debugPrint('Upload failed with state: ${snapshot.state}');
      return null;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  /// Upload profile image with progress callback
  /// Télécharger une image de profil avec rappel de progression
  Future<String?> uploadProfileImageWithProgress({
    required String userId,
    required String userType,
    required dynamic file,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final fileName =
          'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'profiles/$userType/$userId/$fileName';
      final ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'userType': userType,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(file as Uint8List, metadata);
      } else {
        uploadTask = ref.putFile(file as File, metadata);
      }

      // Listen to progress / Écouter la progression
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (onProgress != null && snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        }
      });

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        debugPrint('Profile image uploaded with progress: $downloadUrl');
        return downloadUrl;
      }

      return null;
    } catch (e) {
      debugPrint('Error uploading profile image with progress: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // BABY PHOTOS / PHOTOS DES BÉBÉS
  // صور المواليد
  // ══════════════════════════════════════════════════════════════

  /// Upload baby photo
  /// Télécharger une photo de bébé
  Future<String?> uploadBabyPhoto({
    required String babyId,
    required String motherId,
    required dynamic file,
  }) async {
    try {
      if (file == null) {
        debugPrint('Baby photo file is null');
        return null;
      }

      final fileName =
          'baby_${babyId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'babies/$motherId/$babyId/$fileName';
      final ref = _storage.ref().child(path);

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'babyId': babyId,
          'motherId': motherId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(file as Uint8List, metadata);
      } else {
        uploadTask = ref.putFile(file as File, metadata);
      }

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        debugPrint('Baby photo uploaded: $downloadUrl');
        return downloadUrl;
      }

      return null;
    } catch (e) {
      debugPrint('Error uploading baby photo: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // MEDICAL DOCUMENTS / DOCUMENTS MÉDICAUX
  // الوثائق الطبية
  // ══════════════════════════════════════════════════════════════

  /// Upload medical document (PDF or image)
  /// Télécharger un document médical (PDF ou image)
  Future<String?> uploadMedicalDocument({
    required String patientId,
    required String documentType,
    required dynamic file,
    String fileExtension = 'pdf',
  }) async {
    try {
      if (file == null) {
        debugPrint('Document file is null');
        return null;
      }

      final fileName =
          '${documentType}_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      final path = 'medical_documents/$patientId/$fileName';
      final ref = _storage.ref().child(path);

      final contentType =
          fileExtension == 'pdf' ? 'application/pdf' : 'image/jpeg';

      final metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'patientId': patientId,
          'documentType': documentType,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(file as Uint8List, metadata);
      } else {
        uploadTask = ref.putFile(file as File, metadata);
      }

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final downloadUrl = await ref.getDownloadURL();
        debugPrint('Medical document uploaded: $downloadUrl');
        return downloadUrl;
      }

      return null;
    } catch (e) {
      debugPrint('Error uploading medical document: $e');
      return null;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // DELETE / SUPPRESSION
  // الحذف
  // ══════════════════════════════════════════════════════════════

  /// Delete a single image or file from storage by URL
  /// Supprimer une image ou fichier du stockage par URL
  Future<bool> deleteFile(String fileUrl) async {
    try {
      if (fileUrl.isEmpty) {
        debugPrint('File URL is empty');
        return false;
      }

      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      debugPrint('File deleted: $fileUrl');
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Delete all files in a folder path
  /// Supprimer tous les fichiers dans un dossier
  Future<bool> deleteFolder(String folderPath) async {
    try {
      final ref = _storage.ref().child(folderPath);
      final listResult = await ref.listAll();

      // Delete all items in folder / Supprimer tous les éléments du dossier
      final deleteFutures =
          listResult.items.map((item) => item.delete()).toList();

      await Future.wait(deleteFutures);

      debugPrint(
        'Folder deleted: $folderPath (${listResult.items.length} files)',
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting folder: $e');
      return false;
    }
  }

  /// Delete all profile images for a user
  /// Supprimer toutes les images de profil d'un utilisateur
  Future<bool> deleteUserProfileImages({
    required String userId,
    required String userType,
  }) async {
    return deleteFolder('profiles/$userType/$userId');
  }

  /// Delete all files related to a baby
  /// Supprimer tous les fichiers liés à un bébé
  Future<bool> deleteBabyFiles({
    required String babyId,
    required String motherId,
  }) async {
    return deleteFolder('babies/$motherId/$babyId');
  }

  /// Delete all medical documents for a patient
  /// Supprimer tous les documents médicaux d'une patiente
  Future<bool> deletePatientDocuments(String patientId) async {
    return deleteFolder('medical_documents/$patientId');
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS / UTILITAIRES
  // المساعدات
  // ══════════════════════════════════════════════════════════════

  /// Get file size in MB from a storage URL
  /// Obtenir la taille du fichier en Mo depuis une URL de stockage
  Future<double?> getFileSizeMB(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      final metadata = await ref.getMetadata();
      final sizeInBytes = metadata.size ?? 0;
      return sizeInBytes / (1024 * 1024);
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return null;
    }
  }

  /// Check if file exists in storage
  /// Vérifier si un fichier existe dans le stockage
  Future<bool> fileExists(String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.getDownloadURL();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate image file size (max 5MB)
  /// Valider la taille du fichier image (max 5 Mo)
  bool validateImageSize(dynamic file, {double maxSizeMB = 5.0}) {
    try {
      final maxBytes = (maxSizeMB * 1024 * 1024).toInt();

      if (kIsWeb && file is Uint8List) {
        return file.lengthInBytes <= maxBytes;
      } else if (!kIsWeb && file is File) {
        return file.lengthSync() <= maxBytes;
      }

      return false;
    } catch (e) {
      debugPrint('Error validating image size: $e');
      return false;
    }
  }

  /// Get Firebase Storage instance
  /// Obtenir l'instance Firebase Storage
  FirebaseStorage get storage => _storage;
}
