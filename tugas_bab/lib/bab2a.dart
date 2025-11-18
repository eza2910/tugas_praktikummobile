class ProdukDigital {
  String namaProduk;
  double harga;
  String kategori;

  ProdukDigital(this.namaProduk, this.harga, this.kategori);

  void terapkanDiskon() {
    if (kategori == 'NetworkAutomation') {
      harga = harga * 0.9;
      print('Diskon diterapkan untuk $namaProduk, harga baru: $harga');
    } else {
      print('Produk $namaProduk tidak mendapat diskon khusus.');
    }
  }
}

abstract class Karyawan {
  String nama;
  int umur;
  String peran;
  double produktivitas;

  Karyawan(this.nama, this.umur, this.peran, this.produktivitas);

  void bekerja();

  void naikProduktivitas(int hari) {
    int interval = hari ~/ 30;
    produktivitas += interval * 5;
    if (produktivitas > 100) produktivitas = 100;
    print('Produktivitas $nama sekarang: $produktivitas');
  }
}

class KaryawanTetap extends Karyawan {
  KaryawanTetap(String nama, int umur, String peran, double produktivitas)
      : super(nama, umur, peran, produktivitas);

  void bekerja() {
    print('$nama sedang bekerja sebagai $peran (Tetap)');
  }
}

class KaryawanKontrak extends Karyawan {
  KaryawanKontrak(String nama, int umur, String peran, double produktivitas)
      : super(nama, umur, peran, produktivitas);

  void bekerja() {
    print('$nama sedang bekerja sebagai $peran (Kontrak)');
  }
}

void buatKaryawan(String nama, {required int umur, required String peran}) {
  print('Nama: $nama, Umur: $umur, Peran: $peran');
}

enum FaseProyek { Perencanaan, Pengembangan, Evaluasi }

FaseProyek nextFase(FaseProyek fase) {
  if (fase == FaseProyek.Perencanaan) return FaseProyek.Pengembangan;
  if (fase == FaseProyek.Pengembangan) return FaseProyek.Evaluasi;
  print('Sudah di fase terakhir');
  return fase;
}

class Perusahaan {
  List<Karyawan> aktif = [];
  List<Karyawan> nonAktif = [];
  int maxAktif = 20;

  void tambahKaryawan(Karyawan k) {
    if (aktif.length < maxAktif) {
      aktif.add(k);
      print('${k.nama} ditambahkan sebagai karyawan aktif');
    } else {
      print('Karyawan aktif sudah penuh');
    }
  }

  void resign(Karyawan k) {
    if (aktif.contains(k)) {
      aktif.remove(k);
      nonAktif.add(k);
      print('${k.nama} resign, jadi non-aktif');
    } else {
      print('${k.nama} tidak ditemukan');
    }
  }
}

void main() {
  var produk1 = ProdukDigital('AutoNet', 1000, 'NetworkAutomation');
  produk1.terapkanDiskon();

  var manager = KaryawanTetap('Budi', 35, 'Manager', 86);
  var kontrak = KaryawanKontrak('Siti', 28, 'Developer', 60);

  manager.bekerja();
  kontrak.bekerja();

  manager.naikProduktivitas(60);
  kontrak.naikProduktivitas(30);

  buatKaryawan('Andi', umur: 30, peran: 'Designer');

  FaseProyek fase = FaseProyek.Perencanaan;
  fase = nextFase(fase);
  print('Fase proyek sekarang: $fase');

  var perusahaan = Perusahaan();
  perusahaan.tambahKaryawan(manager);
  perusahaan.tambahKaryawan(kontrak);

  perusahaan.resign(kontrak);
}