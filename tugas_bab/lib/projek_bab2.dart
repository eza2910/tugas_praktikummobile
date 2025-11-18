import 'dart:io';
import 'dart:convert';

/// Kelas dasar User
class User {
  String username;
  String password;

  User(this.username, this.password);
}

/// Kelas User biasa (pelapor)
class Pelapor extends User {
  Pelapor(String username) : super(username, '');
  
  Future<void> buatLaporan() async {
    stdout.write("Masukkan judul laporan: ");
    String? judul = stdin.readLineSync();

    stdout.write("Masukkan isi laporan: ");
    String? isi = stdin.readLineSync();

    Map<String, String> laporan = {
      "nama": username,
      "judul": judul ?? "",
      "isi": isi ?? ""
    };

    File file = File('laporan.json');
    List laporanList = [];

    if (file.existsSync()) {
      try {
        String data = file.readAsStringSync();
        laporanList = jsonDecode(data);
      } catch (_) {}
    }

    laporanList.add(laporan);
    file.writeAsStringSync(jsonEncode(laporanList));

    stdout.write("\nMengirim laporan");
    for (int i = 0; i < 3; i++) {
      stdout.write(".");
      await Future.delayed(Duration(milliseconds: 500));
    }

    print("\n✅ Laporan berhasil dikirim!\n");
  }
}

/// Kelas Admin
class Admin extends User {
  Admin(String username, String password) : super(username, password);

  Future<void> menuAdmin() async {
    while (true) {
      print("\n=== MENU ADMIN ===");
      print("1. Lihat Laporan");
      print("2. Kelola Laporan");
      print("3. Kembali ke Menu Utama");
      stdout.write("Pilih (1/2/3): ");
      String? pilih = stdin.readLineSync();

      if (pilih == '1') {
        await lihatLaporan();
      } else if (pilih == '2') {
        await kelolaLaporan();
      } else if (pilih == '3') {
        print("Kembali ke menu utama...");
        break;
      } else {
        print("Pilihan tidak valid!");
      }
    }
  }

  Future<void> lihatLaporan() async {
    stdout.write("\nMemuat laporan");
    for (int i = 0; i < 3; i++) {
      stdout.write(".");
      await Future.delayed(Duration(milliseconds: 500));
    }
    print("\n");

    File file = File('laporan.json');
    if (!file.existsSync()) {
      print("Belum ada laporan tersimpan.");
      return;
    }

    String data = file.readAsStringSync();
    List laporan = jsonDecode(data);

    if (laporan.isEmpty) {
      print("Belum ada laporan.");
    } else {
      print("\n===========================================");
      print("📑 DAFTAR LAPORAN TERKIRIM 📑");
      print("===========================================\n");
      for (int i = 0; i < laporan.length; i++) {
        var l = laporan[i];
        print("🔹 LAPORAN #${i + 1}");
        print("👤 Nama   : ${l['nama']}");
        print("📝 Judul  : ${l['judul']}");
        print("📖 Isi    : ${l['isi']}");
        print("-------------------------------------------");
      }
      stdout.write("\nTekan ENTER untuk kembali ke menu...");
      stdin.readLineSync();
    }
  }

  Future<void> kelolaLaporan() async {
    File file = File('laporan.json');
    if (!file.existsSync()) {
      print("Belum ada laporan untuk dikelola.");
      return;
    }

    String data = file.readAsStringSync();
    List laporan = jsonDecode(data);

    if (laporan.isEmpty) {
      print("Belum ada laporan untuk dikelola.");
      return;
    }

    print("\n=== KELOLA LAPORAN ===");
    for (int i = 0; i < laporan.length; i++) {
      print("${i + 1}. ${laporan[i]['judul']} (${laporan[i]['nama']})");
    }

    stdout.write("\nMasukkan nomor laporan yang ingin dihapus (0 untuk batal): ");
    String? input = stdin.readLineSync();
    int? index = int.tryParse(input ?? '');

    if (index == null || index <= 0 || index > laporan.length) {
      print("Batal menghapus laporan.");
      return;
    }

    var hapus = laporan.removeAt(index - 1);
    file.writeAsStringSync(jsonEncode(laporan));
    print("✅ Laporan '${hapus['judul']}' berhasil dihapus.");

    stdout.write("\nTekan ENTER untuk kembali ke menu admin...");
    stdin.readLineSync();
  }
}

/// Fungsi utama program
Future<void> main() async {
  while (true) {
    print("\n=== SISTEM PELAPORAN ===");
    print("1. Login sebagai User");
    print("2. Login sebagai Admin");
    print("3. Keluar");
    stdout.write("Pilih (1/2/3): ");
    String? pilih = stdin.readLineSync();

    if (pilih == '1') {
      stdout.write("Masukkan nama Anda: ");
      String? nama = stdin.readLineSync();
      var user = Pelapor(nama ?? "Anonim");
      await user.buatLaporan();
    } else if (pilih == '2') {
      stdout.write("Masukkan username admin: ");
      String? user = stdin.readLineSync();
      stdout.write("Masukkan password admin: ");
      String? pass = stdin.readLineSync();

      if (user == 'admin' && pass == 'admin123') {
        var admin = Admin(user!, pass!);
        await admin.menuAdmin();
      } else {
        print("❌ Username atau password salah!");
      }
    } else if (pilih == '3') {
      print("Terima kasih telah menggunakan sistem!");
      exit(0);
    } else {
      print("Pilihan tidak valid!");
    }
  }
}
