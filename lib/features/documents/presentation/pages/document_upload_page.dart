import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../providers/document_provider.dart';

class DocumentUploadPage extends ConsumerStatefulWidget {
  const DocumentUploadPage({super.key});

  @override
  ConsumerState<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends ConsumerState<DocumentUploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedCategory = 'other';
  File? _selectedFile;
  DateTime? _expiryDate;
  bool _isUploading = false;
  String? _fileName;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // File picker area
              GestureDetector(
                onTap: _showFilePickerOptions,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedFile != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              _fileName ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              FileUtils.formatFileSize(_selectedFile!.lengthSync()),
                              style: const TextStyle(color: AppColors.grey500),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: 48, color: AppColors.primary),
                            SizedBox(height: 8),
                            Text(
                              'Tap to select a file',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'PDF, JPG, PNG, HEIC supported',
                              style: TextStyle(
                                color: AppColors.grey500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Document Title *',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.documentCategories.map((cat) {
                  final emoji = AppConstants.categoryIcons[cat] ?? '📄';
                  final name = AppConstants.categoryDisplayNames[cat] ?? cat;
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Text(emoji),
                        const SizedBox(width: 8),
                        Text(name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v ?? 'other'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
                title: Text(
                  _expiryDate != null
                      ? 'Expires: ${DateUtils.formatDate(_expiryDate!)}'
                      : 'Add Expiry Date (optional)',
                  style: TextStyle(
                    color: _expiryDate != null ? null : AppColors.grey500,
                  ),
                ),
                trailing: _expiryDate != null
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _expiryDate = null),
                      )
                    : const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onTap: _pickExpiryDate,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.notes_rounded),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isUploading ? null : _upload,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: _isUploading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Upload Document'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.secondary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined, color: AppColors.accent),
              title: const Text('Files'),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
        _fileName = image.name;
        if (_titleController.text.isEmpty) {
          _titleController.text = image.name.split('.').first;
        }
      });
    }
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
        _fileName = image.name;
        if (_titleController.text.isEmpty) {
          _titleController.text = image.name.split('.').first;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedFileTypes,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
        if (_titleController.text.isEmpty) {
          _titleController.text =
              result.files.single.name.split('.').first;
        }
      });
    }
  }

  Future<void> _pickExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
    );
    if (date != null) {
      setState(() => _expiryDate = date);
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isUploading = true);

    final repo = ref.read(documentRepositoryProvider);
    final result = await repo.uploadDocument(
      filePath: _selectedFile!.path,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      expiryDate: _expiryDate,
    );

    setState(() => _isUploading = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(failure.message),
          backgroundColor: AppColors.error,
        ),
      ),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      },
    );
  }
}
