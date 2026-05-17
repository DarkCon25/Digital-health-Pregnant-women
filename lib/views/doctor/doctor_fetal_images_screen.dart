import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/doctor_colors.dart';
import '../../core/app_strings.dart';
import '../../models/doctor/ultrasound_image_model.dart';
import '../../services/doctor_service.dart';
 import '../../widgets/doctor/doctor_screen_chrome.dart';

/// Ultrasound gallery — `ultrasound_images` collection.
/// الطبيب يمكنه Upload / Televerser صور الموجات فوق الصوتية
class DoctorFetalImagesScreen extends StatefulWidget {
  const DoctorFetalImagesScreen({super.key});

  @override
  State<DoctorFetalImagesScreen> createState() => _DoctorFetalImagesScreenState();
}

class _DoctorFetalImagesScreenState extends State<DoctorFetalImagesScreen> {
  int _selected = 0;
  
  // Renamed to be more accurate: this is just loading the picker and patients
  bool _isPreparing = false; 

  Future<void> _prepareAndShowUploadDialog() async {
    // Capture context-dependent objects before async gaps
    final doctorService = context.read<DoctorService>();
    
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      setState(() => _isPreparing = true);
      
      final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

      // Get list of patients assigned to this doctor
      final patients = await doctorService.watchPatientsForDoctor(doctorId).first;

      if (!mounted) return;
      setState(() => _isPreparing = false);

      if (patients.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No patients assigned to you / Aucune patiente ne vous est assignee'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Open Dialog
      _showUploadDialog(image, patients, doctorId, doctorService);

    } catch (e) {
      if (mounted) {
        setState(() => _isPreparing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error / Erreur: $e')),
        );
      }
    }
  }

  // Extracted Dialog to its own method for cleaner code
  void _showUploadDialog(
    XFile image, 
    List patients, 
    String doctorId, 
    DoctorService doctorService
  ) {
    String? selectedPatientId;
    String sessionLabel = '';
    bool isUploadingImage = false; // State specifically for the dialog button

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside during upload
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Ultrasound Image / Televerser une image echographique',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DoctorColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Patient dropdown
                Text(
                  'Patient / Patiente',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
const SizedBox(height: 6),
                 DropdownButtonFormField<String>(
                   initialValue: selectedPatientId,
                  // Disable dropdown while uploading
                  onChanged: isUploadingImage 
                      ? null 
                      : (v) => setDialogState(() => selectedPatientId = v),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: DoctorColors.cardBorder),
                    ),
                  ),
                  items: patients.map((p) => DropdownMenuItem<String>(
                        value: p.id,
                        child: Text(p.fullName, style: GoogleFonts.inter()),
                      )).toList(),
                  hint: Text(
                    'Select patient / Selectionner la patiente',
                    style: GoogleFonts.inter(color: DoctorColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),

                // Session label
                Text(
                  'Session title (optional) / Titre de session (optionnel)',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  enabled: !isUploadingImage, // Disable while uploading
                  onChanged: (v) => setDialogState(() => sessionLabel = v),
                  decoration: InputDecoration(
                    hintText: 'Example: First exam / Exemple : Premier examen',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isUploadingImage ? null : () => Navigator.pop(dCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Cancel / Annuler', style: GoogleFonts.poppins()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        // Disable button if no patient is selected OR if currently uploading
                        onPressed: (selectedPatientId == null || isUploadingImage)
                            ? null
                            : () async {
                                setDialogState(() => isUploadingImage = true);

                                try {
                                  final imageBytes = await image.readAsBytes();
                                  final fileName = 'ultrasound_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                  final path = 'ultrasounds/${selectedPatientId!}/$fileName';
                                  
                                  // RECOMMENDED: Move this to your StorageService!
                                  // final imageUrl = await storageService.uploadBytes(path, imageBytes);
                                  
                                  final ref = FirebaseStorage.instance.ref().child(path);
                                  final snapshot = await ref.putData(imageBytes);
                                  final imageUrl = await snapshot.ref.getDownloadURL();

                                  // Save ultrasound record
                                  await doctorService.addUltrasoundImage(
                                    doctorId: doctorId,
                                    patientId: selectedPatientId!,
                                    imageUrl: imageUrl,
                                    sessionLabel: sessionLabel.trim().isEmpty ? null : sessionLabel.trim(),
                                  );

if (dCtx.mounted) {
                                     Navigator.pop(dCtx); // Close Dialog safely
                                     ScaffoldMessenger.of(dCtx).showSnackBar(
                                       const SnackBar(
                                         content: Text('Image uploaded successfully / Image televersee avec succes'),
                                         backgroundColor: Colors.green,
                                       ),
                                     );
                                   }
                                 } catch (e) {
                                   if (dCtx.mounted) {
                                     ScaffoldMessenger.of(dCtx).showSnackBar(
                                       SnackBar(
                                         content: Text('Upload error / Erreur de televersement : $e'),
                                         backgroundColor: Colors.red,
                                       ),
                                     );
                                   }
                                } finally {
                                  // Ensure dialog state resets if it's somehow still open on error
                                  if (dCtx.mounted) {
                                    setDialogState(() => isUploadingImage = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DoctorColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: isUploadingImage
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text('Upload / Televerser', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final service = context.read<DoctorService>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DoctorStrings.pageUltrasound,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: DoctorColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DoctorStrings.ultrasoundPageSubtitle,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: DoctorColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isPreparing ? null : _prepareAndShowUploadDialog,
                icon: _isPreparing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(_isPreparing ? 'Preparing... / Preparation en cours...' : 'Upload new image / Televerser une nouvelle image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DoctorColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<UltrasoundImageModel>>(
              stream: uid.isEmpty ? const Stream.empty() : service.watchUltrasoundsForDoctor(uid),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final list = snap.data!;
                
                if (list.isEmpty) {
                  return DoctorSurfaceCard(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.image_not_supported_outlined,
                              size: 56, color: DoctorColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            DoctorStrings.noUltrasoundFirestore,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(color: DoctorColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _prepareAndShowUploadDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Upload image / Televerser une image'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DoctorColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Prevent RangeError when items are deleted
                if (_selected >= list.length) {
                   _selected = 0; 
                }
                
                final main = list[_selected];

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 200,
                      child: DoctorSurfaceCard(
                        padding: EdgeInsets.zero,
                        child: ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, i) {
                            final u = list[i];
                            final label = u.sessionLabel ?? DateFormat.yMMMd().format(u.createdAt);
                            final sel = i == _selected;
                            return ListTile(
                              selected: sel,
                              title: Text(
                                label,
                                style: GoogleFonts.inter(
                                  fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Text(
                                u.patientId, // Hint: You might want to map this to Patient Name in the future
                                style: GoogleFonts.inter(fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => setState(() => _selected = i),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: DoctorSurfaceCard(
                              padding: EdgeInsets.zero,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: main.imageUrl.isEmpty
                                    ? Center(
                                        child: Text(
                                          DoctorStrings.noImageUrl,
                                          style: GoogleFonts.inter(color: DoctorColors.textSecondary),
                                        ),
                                      )
                                    : InteractiveViewer(
                                        minScale: 0.5,
                                        maxScale: 4,
                                        child: Image.network(
                                          main.imageUrl,
                                          fit: BoxFit.contain,
                                          loadingBuilder: (_, child, prog) {
                                            if (prog == null) return child;
                                            return const Center(child: CircularProgressIndicator());
                                          },
                                          errorBuilder: (_, __, ___) => const Center(
                                            child: Icon(Icons.broken_image_outlined,
                                                size: 64, color: DoctorColors.textSecondary),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 72,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: list.length.clamp(0, 16),
                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final u = list[i];
                                return GestureDetector(
                                  onTap: () => setState(() => _selected = i),
                                  child: Container(
                                    width: 96,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: i == _selected ? DoctorColors.primary : DoctorColors.cardBorder,
                                        width: i == _selected ? 2 : 1,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: u.imageUrl.isEmpty
                                        ? const Icon(Icons.image)
                                        : Image.network(
                                            u.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.hide_image),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
