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

  String? _selectedGender;
  DateTime? _selectedDate;
  Uint8List? _imageBytes; // Data gambar lokal (preview)

  final List<String> _genders = ['Laki-laki', 'Perempuan'];

  // Shortcut akses Supabase Client
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

        // Ambil data detail dari tabel 'users'
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
            
            // Cek apakah gender yang tersimpan ada di list opsi
            if (_genders.contains(data['gender'])) {
              _selectedGender = data['gender'];
            }
            
            if (data['birth_date'] != null) {
              _selectedDate = DateTime.tryParse(data['birth_date']);
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

  // --- 2. PILIH GAMBAR ---
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50, // Kompresi agar upload lebih cepat
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  // --- 3. SIMPAN DATA KE SUPABASE ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      String? publicUrl;

      // A. Upload Foto ke Storage Supabase (Bucket 'avatars') jika ada gambar baru
      if (_imageBytes != null) {
        final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        // Upload Binary (Aman untuk Web & Mobile)
        await _supabase.storage.from('avatars').uploadBinary(
          fileName,
          _imageBytes!,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );

        // Ambil URL Publik agar bisa disimpan di database
        publicUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
      }

      // B. Simpan Data Text ke Tabel 'users'
      final updates = {
        'id': user.id,
        'display_name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'gender': _selectedGender,
        'phone_number': _phoneController.text.trim(),
        'birth_date': _selectedDate?.toIso8601String(),
        // Hanya update kolom foto jika ada upload baru
        if (publicUrl != null) 'photo_url': publicUrl, 
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Upsert: Update jika ada, Insert jika belum ada
      await _supabase.from('users').upsert(updates);

      // C. Update Metadata Auth (Supaya nama di Auth juga berubah)
      await _supabase.auth.updateUser(
        UserAttributes(data: {'full_name': _nameController.text.trim()}),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan!'), backgroundColor: Colors.teal),
        );
        // Kembali ke halaman sebelumnya (ProfileScreen)
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
    const Color primaryTeal = Color(0xFF00897B);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: primaryTeal)),
                )
              : TextButton(
                  onPressed: _saveProfile,
                  child: const Text("SIMPAN", style: TextStyle(fontWeight: FontWeight.bold, color: primaryTeal)),
                )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TAMPILAN FOTO ---
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      // FutureBuilder untuk mengambil URL foto dari database saat init
                      FutureBuilder(
                        future: _supabase.from('users').select('photo_url').eq('id', _supabase.auth.currentUser!.id).maybeSingle(),
                        builder: (context, snapshot) {
                          String? remoteUrl;
                          if (snapshot.hasData && snapshot.data != null) {
                            remoteUrl = snapshot.data!['photo_url'];
                          }

                          return CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            // Priority: 1. Gambar Lokal (baru pilih), 2. Gambar Internet (DB), 3. Null
                            backgroundImage: _imageBytes != null 
                                ? MemoryImage(_imageBytes!) as ImageProvider
                                : (remoteUrl != null ? NetworkImage(remoteUrl) : null),
                            child: (_imageBytes == null && remoteUrl == null)
                                ? const Icon(Icons.person, size: 60, color: Colors.white)
                                : null,
                          );
                        }
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: primaryTeal, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- FORM INPUTS ---
              _buildLabel("Nama Lengkap"),
              TextFormField(
                controller: _nameController,
                validator: (val) => val!.isEmpty ? "Nama wajib diisi" : null,
                decoration: _inputDecoration("Nama kamu"),
              ),
              const SizedBox(height: 20),

              _buildLabel("Bio"),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: _inputDecoration("Ceritakan tentang dirimu"),
              ),
              const SizedBox(height: 20),

              _buildLabel("Jenis Kelamin"),
              // === PERBAIKAN DROPDOWN DI SINI ===
              DropdownButtonFormField<String>(
                // Key ini PENTING: Memaksa widget rebuild saat _selectedGender berubah (setelah load DB)
                key: ValueKey(_selectedGender), 
                
                // Gunakan initialValue, bukan value
                initialValue: _selectedGender,
                
                items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (val) => setState(() => _selectedGender = val),
                decoration: _inputDecoration("Pilih Gender"),
              ),
              const SizedBox(height: 20),

              _buildLabel("Tanggal Lahir"),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: InputDecorator(
                  decoration: _inputDecoration(""),
                  child: Text(
                    _selectedDate == null 
                      ? "Pilih Tanggal" 
                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    style: TextStyle(color: _selectedDate == null ? Colors.grey : Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildLabel("Nomor HP"),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("08xx..."),
              ),
              const SizedBox(height: 20),

              _buildLabel("Email"),
              TextFormField(
                controller: _emailController,
                readOnly: true, // Email tidak boleh diedit
                decoration: _inputDecoration("").copyWith(fillColor: Colors.grey.shade100, filled: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));
  
  InputDecoration _inputDecoration(String hint) => InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14));
}