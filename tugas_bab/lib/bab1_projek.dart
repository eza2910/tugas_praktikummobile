import 'dart:io';
import 'dart:convert';

// daftar laporan akan disimpan sementara di list
List<Map<String, String>> laporanList = [];

Future<void> main() async {
  while (true) {
    print("\n=== SISTEM PELAPORAN ===");
    print("1. Login sebagai User");
    print("2. Login sebagai Admin");
    print("3. Keluar");
    stdout.write("Pilih (1/2/3): ");
    String? pilih = stdin.readLineSync();

    if (pilih == '1') {
      await loginUser(); // menunggu selesai
    } else if (pilih == '2') {
      await loginAdmin(); // menunggu selesai
    } else if (pilih == '3') {
      print("Terima kasih telah menggunakan sistem!");
      exit(0);
    } else {
      print("Pilihan tidak valid!");
    }
  }
}

Future<void> loginUser() async {
  stdout.write("Masukkan nama Anda: ");
  String? nama = stdin.readLineSync();

  stdout.write("Masukkan judul laporan: ");
  String? judul = stdin.readLineSync();

  stdout.write("Masukkan isi laporan: ");
  String? isi = stdin.readLineSync();

  laporanList.add({
    "nama": nama ?? "",
    "judul": judul ?? "",
    "isi": isi ?? ""
  });

  // simpan laporan ke file JSON
  File file = File('laporan.json');
  file.writeAsStringSync(jsonEncode(laporanList));

  // tampilkan efek loading agar delay terlihat
  stdout.write("\nMengirim laporan");
  for (int i = 0; i < 3; i++) {
    stdout.write(".");
    await Future.delayed(Duration(milliseconds: 500));
  }

  print("\n✅ Laporan berhasil dikirim!\n");
}

Future<void> loginAdmin() async {
  stdout.write("Masukkan username admin: ");
  String? user = stdin.readLineSync();
  stdout.write("Masukkan password admin: ");
  String? pass = stdin.readLineSync();

  if (user == 'admin' && pass == 'admin123') {
    stdout.write("\nMemuat laporan");
    for (int i = 0; i < 3; i++) {
      stdout.write(".");
      await Future.delayed(Duration(milliseconds: 500));
    }
    print("\n");

    File file = File('laporan.json');
    if (file.existsSync()) {
      String data = file.readAsStringSync();
      List laporan = jsonDecode(data);

      if (laporan.isEmpty) {
        print("Belum ada laporan.");
      } else {
        print("\n=== DAFTAR LAPORAN ===");
        for (var l in laporan) {
          print("\nNama   : ${l['nama']}");
          print("Judul  : ${l['judul']}");
          print("Isi    : ${l['isi']}");
        }
      }
    } else {
      print("Belum ada laporan tersimpan.");
    }
  } else {
    print("❌ Username atau password salah!");
  }
}

