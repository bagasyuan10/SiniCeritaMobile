import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController(); // Controller khusus tampilan tanggal

  String? _selectedGender;
  DateTime? _selectedDate;
  Uint8List? _imageBytes; // Data gambar lokal

  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  // Warna Tema Konsisten
  static const Color primaryTeal = Color(0xFF00897B);
  static const Color backgroundGrey = Color(0xFFF8F9FA); // Warna terang
  static const Color textDark = Color(0xFF2D3436); // Hitam tidak pekat (lebih enak dimata)

  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // --- 1. LOAD DATA DARI SUPABASE ---
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        _emailController.text = user.email ?? '';
        _nameController.text = user.userMetadata?['full_name'] ?? '';

        final data = await _supabase
            .from('users')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (data != null) {
          setState(() {
            _nameController.text = data['display_name'] ?? '';
            _bioController.text = data['bio'] ?? '';
            _phoneController.text = data['phone_number'] ?? '';

            if (_genders.contains(data['gender'])) {
              _selectedGender = data['gender'];
            }

            // ✅ PERBAIKAN DISINI:
            if (data['birth_date'] != null) {
              _selectedDate = DateTime.tryParse(data['birth_date']);
              
              // Jika tanggal ada, kita paksa tulis ke Controller agar muncul di UI
              if (_selectedDate != null) {
                _dateController.text = "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
              }
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading user: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. PICK IMAGE ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  // --- 3. SAVE DATA ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      String? publicUrl;

      // Upload Foto
      if (_imageBytes != null) {
        final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        await _supabase.storage.from('avatars').uploadBinary(
          fileName,
          _imageBytes!,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );
        publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      // Update Database
      final updates = {
        'id': user.id,
        'display_name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'gender': _selectedGender,
        'phone_number': _phoneController.text.trim(),
        'birth_date': _selectedDate?.toIso8601String(),
        if (publicUrl != null) 'photo_url': publicUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('users').upsert(updates);

      // Update Auth Metadata
      await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': _nameController.text.trim()}),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: primaryTeal),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey, // ✅ Memaksa background terang
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Bottom Button agar lebih mudah dijangkau
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))
          ]
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text("SIMPAN PERUBAHAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- AREA FOTO PROFIL ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: FutureBuilder(
                          future: _supabase.from('users').select('photo_url').eq('id', _supabase.auth.currentUser!.id).maybeSingle(),
                          builder: (context, snapshot) {
                            String? remoteUrl;
                            if (snapshot.hasData && snapshot.data != null) {
                              remoteUrl = snapshot.data!['photo_url'];
                            }
                            return CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: _imageBytes != null 
                                ? MemoryImage(_imageBytes!) as ImageProvider
                                : (remoteUrl != null ? NetworkImage(remoteUrl) : null),
                              child: (_imageBytes == null && remoteUrl == null)
                                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                : null,
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryTeal,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),

              // --- FORM FIELDS ---
              
              _buildSectionTitle("Tentang Saya"),
              _buildCustomTextField(
                controller: _nameController,
                label: "Nama Lengkap",
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildCustomTextField(
                controller: _bioController,
                label: "Bio",
                icon: Icons.edit_note_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle("Informasi Pribadi"),
              
              // Dropdown Gender Custom
              _buildContainer(
                child: DropdownButtonFormField<String>(
                  // ✅ PENTING: Key ini membuat widget "rebuild" ulang saat data _selectedGender dari database selesai loading
                  key: ValueKey(_selectedGender), 
                  
                  // ❌ HAPUS BARIS INI (value: _selectedGender)
                  
                  // ✅ GANTI DENGAN INI:
                  initialValue: _selectedGender, 
                  
                  decoration: _noBorderDecoration("Jenis Kelamin", Icons.people_outline_rounded),
                  items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (val) => setState(() => _selectedGender = val),
                  style: const TextStyle(color: textDark, fontSize: 16),
                  dropdownColor: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Date Picker Field
              _buildContainer(
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true, // Supaya keyboard tidak muncul
                  decoration: _noBorderDecoration("Tanggal Lahir", Icons.calendar_today_rounded),
                  style: const TextStyle(color: textDark),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(primary: primaryTeal),
                          ),
                          child: child!,
                        );
                      }
                    );
                    
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                        // ✅ PERBAIKAN: Update teks di kotak segera setelah memilih tanggal
                        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
                      });
                    }
                  },
                ),
              ),

              const SizedBox(height: 16),
              
              _buildCustomTextField(
                controller: _phoneController,
                label: "Nomor HP",
                icon: Icons.phone_iphone_rounded,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),
              
              // Email (Disabled Look)
              Opacity(
                opacity: 0.6,
                child: _buildCustomTextField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  readOnly: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildContainer({required Widget child, Color? fillColor}) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    TextInputType? keyboardType,
    Color? fillColor,
  }) {
    return _buildContainer(
      fillColor: fillColor,
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(color: textDark),
        validator: (val) => val!.isEmpty ? "$label wajib diisi" : null,
        decoration: _noBorderDecoration(label, icon),
      ),
    );
  }

  InputDecoration _noBorderDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade500),
      prefixIcon: Icon(icon, color: primaryTeal.withValues(alpha: 0.7)),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
    );
  }
}