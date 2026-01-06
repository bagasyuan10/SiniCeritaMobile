import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    const Color primaryTeal = Color(0xFF00897B);
    const Color darkTeal = Color(0xFF004D40);

    // Jika user belum login, return widget kosong/loading
    if (user == null) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tampilan Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: primaryTeal),
            tooltip: "Edit",
            onPressed: () {
              // Gunakan push biasa agar bisa kembali
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const EditProfileScreen())
              );
            },
          )
        ],
      ),
      // MENGGUNAKAN STREAM AGAR REAL-TIME
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('users')
            .stream(primaryKey: ['id'])
            .eq('id', user.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Ambil data pertama dari stream
          final data = snapshot.data?.isNotEmpty == true ? snapshot.data!.first : null;

          // Data Fallback (Jika database masih kosong, ambil dari Auth Metadata)
          final String displayName = data?['display_name'] ?? user.userMetadata?['full_name'] ?? "Pengguna";
          final String email = user.email ?? "-";
          final String? photoURL = data?['photo_url']; 
          
          final String bio = data?['bio'] ?? "Belum ada informasi bio.";
          final String gender = data?['gender'] ?? "-";
          final String phone = data?['phone_number'] ?? "-";
          
          String birthDate = "-";
          if (data?['birth_date'] != null && data!['birth_date'].toString().isNotEmpty) {
             // Cek format, kadang user simpan string biasa
             birthDate = data['birth_date']; 
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                // --- FOTO PROFILE ---
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
                    child: photoURL == null 
                      ? const Icon(Icons.person, size: 70, color: darkTeal) 
                      : null,
                  ),
                ),
                const SizedBox(height: 16),
                
                // --- NAMA & EMAIL ---
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  email,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                
                const SizedBox(height: 30),
                const Divider(thickness: 1),
                
                // --- LIST INFORMASI DETAIL ---
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                        _buildProfileInfoRow("Bio", bio),
                        _buildProfileInfoRow("Jenis Kelamin", gender),
                        _buildProfileInfoRow("Tanggal Lahir", birthDate),
                        _buildProfileInfoRow("Nomor Handphone", phone),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _buildProfileInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}