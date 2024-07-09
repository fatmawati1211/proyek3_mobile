import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // Tambahkan logika untuk menangani notifikasi aplikasi
            },
          ),
        ],
      ),
      body: ProfileContent(),
    );
  }
}

class ProfileContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/fanji_bagja.jpg'), // Ganti dengan gambar profil pengguna
              ),
              SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fanji Bagja', // Ganti dengan nama pengguna
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'fanjibagja@example.com', // Ganti dengan email pengguna
                    style: TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.explore),
          title: Text('Get Inspired'),
          onTap: () {
            // Tambahkan logika untuk navigasi ke halaman Get Inspired
          },
        ),
        ListTile(
          leading: Icon(Icons.save),
          title: Text('Saved List'),
          onTap: () {
            // Tambahkan logika untuk navigasi ke halaman Saved List
          },
        ),
        ListTile(
          leading: Icon(Icons.history),
          title: Text('History'),
          onTap: () {
            // Tambahkan logika untuk navigasi ke halaman History
          },
        ),
        ListTile(
          leading: Icon(Icons.language),
          title: Text('Language'),
          onTap: () {
            // Tambahkan logika untuk mengatur bahasa
          },
        ),
        Spacer(), // Spacer untuk mendorong tombol logout ke bawah
        ListTile(
          title: Text('Logout', textAlign: TextAlign.center),
          onTap: () {
            // Tambahkan logika untuk logout
          },
        ),
      ],
    );
  }
}
