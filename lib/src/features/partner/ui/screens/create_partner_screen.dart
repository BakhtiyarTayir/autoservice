import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autoservice/src/features/partner/providers/partner_providers.dart';
import 'package:autoservice/src/features/partner/ui/screens/partner_detail_screen.dart';
import 'package:image_picker/image_picker.dart';

class CreatePartnerScreen extends ConsumerStatefulWidget {
  const CreatePartnerScreen({super.key});

  @override
  ConsumerState<CreatePartnerScreen> createState() => _CreatePartnerScreenState();
}

class _CreatePartnerScreenState extends ConsumerState<CreatePartnerScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _regionController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  
  XFile? _logoFile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _regionController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _logoFile = image;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        // Подготавливаем данные для создания партнера
        final partnerData = {
          'name': _nameController.text,
          'description': _descriptionController.text,
          'address': _addressController.text,
          'region': _regionController.text,
          'location': _locationController.text,
          'phone': _phoneController.text,
          'logoFile': _logoFile,
        };

        // Вызываем провайдер для создания партнера
        final createdPartner = await ref.read(createPartnerProvider(partnerData).future);

        // Если успешно, показываем сообщение об успехе
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Автосервис успешно создан!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Переходим к детальному экрану созданного автосервиса
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PartnerDetailScreen(partnerId: createdPartner.id),
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание автосервиса'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Логотип
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _logoFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_logoFile!.path),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Нажмите, чтобы добавить логотип',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Название
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название автосервиса',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите название';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Описание
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите описание';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Адрес
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Адрес',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите адрес';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Регион
                    TextFormField(
                      controller: _regionController,
                      decoration: const InputDecoration(
                        labelText: 'Регион (код)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите код региона';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Координаты
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Координаты (формат: долгота:широта)',
                        hintText: 'Например: 69.279737:41.311151',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите координаты';
                        }
                        if (!value.contains(':')) {
                          return 'Неверный формат. Используйте формат долгота:широта';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Телефон
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Телефон',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Пожалуйста, введите номер телефона';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Сообщение об ошибке
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Кнопка создания
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Создать автосервис'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}