mixin Kinerja {
  int produktivitas = 0;
  DateTime? _terakhirUpdate;

  bool bolehUpdate() {
    if (_terakhirUpdate == null) return true;
    final selisih = DateTime.now().difference(_terakhirUpdate!).inDays;
    return selisih >= 30;
  }

  void updateProduktivitas(int nilai, String peran) {
    if (!bolehUpdate()) return;
    if (nilai < 0 || nilai > 100) return;
    if (peran == "Manager" && nilai < 85) return;

    produktivitas = nilai;
    _terakhirUpdate = DateTime.now();
  }
}

abstract class Karyawan with Kinerja {
  String nama;
  int umur;
  String peran;
  bool aktif = true;

  Karyawan(this.nama, {required this.umur, required this.peran});

  void tampil() {
    String status = aktif ? "Aktif" : "Tidak Aktif";
    print("$nama - $peran (Produktivitas: $produktivitas, Status: $status)");
  }

  void resign() {
    aktif = false;
  }
}

class KaryawanTetap extends Karyawan {
  KaryawanTetap(String nama, {required int umur, required String peran})
      : super(nama, umur: umur, peran: peran);

  void bekerja() {
    print("$nama (Tetap) bekerja selama hari kerja reguler.");
  }
}

class KaryawanKontrak extends Karyawan {
  DateTime mulai;
  DateTime selesai;

  KaryawanKontrak(String nama,
      {required int umur,
      required String peran,
      required this.mulai,
      required this.selesai})
      : super(nama, umur: umur, peran: peran);

  void bekerja() {
    print(
        "$nama (Kontrak) bekerja dari ${mulai.toLocal()} sampai ${selesai.toLocal()}");
  }
}

class Proyek {
  String nama;
  String fase;
  int karyawanAktif;
  int lamaHari;

  Proyek(this.nama, this.fase, this.karyawanAktif, this.lamaHari);

  void nextFase() {
    if (fase == "Perencanaan" && karyawanAktif >= 5) {
      fase = "Pengembangan";
    } else if (fase == "Pengembangan" && lamaHari > 45) {
      fase = "Evaluasi";
    }
  }

  void tampil() {
    print("$nama kini berada pada fase: $fase");
  }
}

class Produk {
  String nama;
  String kategori;
  int harga;
  int terjual;

  Produk(this.nama, this.kategori, this.harga, this.terjual) {
    if (kategori == "NetworkAutomation" && harga < 200000) {
      harga = 200000;
    } else if (kategori == "DataManagement" && harga >= 200000) {
      harga = 199999;
    }
  }

  void diskonProduk() {
    if (kategori == "NetworkAutomation" && terjual > 50) {
      int hargaDiskon = (harga * 85 ~/ 100);
      if (hargaDiskon < 200000) {
        harga = 200000;
      } else {
        harga = hargaDiskon;
      }
    }
  }

  void tampil() {
    print("$nama ($kategori) - Harga: $harga");
  }
}

void main() {
  var p1 = Produk("AutoNet Suite", "NetworkAutomation", 250000, 60);
  var p2 = Produk("DataLite", "DataManagement", 150000, 10);
  p1.diskonProduk();

  print("=== DATA PRODUK ===");
  p1.tampil();
  p2.tampil();

  var k1 = KaryawanTetap("Andi", umur: 28, peran: "Developer");
  var k2 = KaryawanTetap("Budi", umur: 30, peran: "NetworkEngineer");
  var k3 = KaryawanTetap("Cinta", umur: 35, peran: "Manager");

  k1.updateProduktivitas(70, k1.peran);
  k2.updateProduktivitas(80, k2.peran);
  k3.updateProduktivitas(90, k3.peran);

  print("\n=== DATA KARYAWAN ===");
  k1.tampil();
  k2.tampil();
  k3.tampil();

  var proyek = Proyek("NetAutomate v1", "Perencanaan", 5, 50);
  proyek.nextFase();
  proyek.nextFase();

  print("\n=== PROGRES PROYEK ===");
  proyek.tampil();
} 