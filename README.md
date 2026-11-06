# UBT Korea Rebuild (Dummy)

Rekonstruksi **tampilan** aplikasi UBT EPS TOPIK Korea v1.0.15 — dibuat dari
peta alur hasil analisis statik [REA](https://github.com/morluto/rea)
(`~/workspace/work/rea-ubt-20261106/COMPARISON.md`), untuk belajar.
**Ini bukan app asli, bukan klon, dan tidak terhubung ke sistem apa pun.**

## Yang direkonstruksi (fungsional, bukan piksel)

Alur layar, mengikuti temuan REA:

```
Splash → Login → Informasi Peserta (+ countdown 5 dtk)
  → Setup Perangkat (brightness + tes volume + gate headset)
  → Daftar Ujian → Halaman Ujian → Hasil
```

- **Login (dummy)** — meniru layout login app asli dari screenshot:
  background gradient biru, kartu putih, logo kiri, form kanan. Logo
  digambar sendiri (lingkaran biru + cloud + teks "DUMMY"), copyright
  ditulis dummy. ID/password apa pun diterima, tanpa server.
  App dikunci landscape seperti app asli.
- **Informasi Peserta (dummy)** — nama + nomor peserta, lalu countdown 5 detik.
- **Setup Perangkat (dummy)** — slider brightness (overlay gelap/terang
  simulasi), tes suara (simulasi 5 detik, tanpa file audio), saklar headset.
  Tombol lanjut hanya aktif kalau headset (simulasi) ON — meniru gate
  headset di app Korea.
- **Daftar Ujian (dummy)** — 3 ujian dummy, semuanya memakai bank soal
  dummy yang sama.
- **Halaman Ujian (dummy)** — topbar detail peserta, timer mundur 10 menit,
  10 soal buatan sendiri (5 reading + 5 listening), 4 pilihan jawaban,
  audio listening **play-once nyata** (file nada test buatan sendiri
  `assets/audio/test_tone.mp3`, 11 detik, diputar via just_audio,
  terkunci setelah 1x putar), kontrol kecepatan **0.75x / 1.0x / 1.25x / 1.5x**
  yang mengubah kecepatan putar, grid total soal (bottom sheet),
  Submit manual (dialog konfirmasi) + **auto-submit** saat waktu habis.
- **Hasil (dummy)** — skor reading/listening dari kunci dummy lokal
  (10 soal × 10 poin = 100, lulus dummy ≥ 60) + pembahasan per soal.

## Yang sengaja TIDAK ada

- ❌ Tanpa aset APK asli (tanpa logo, tanpa mp3, tanpa font asli) —
  logo digambar dari widget Flutter, mp3 adalah nada test buatan
  sendiri (deret sine, bukan musik).
- ❌ Tanpa kode Dart asli (tidak ada yang bisa disalin — logika aslinya AOT).
- ❌ Tanpa backend — backend asli (`eps.ubtcloud.me`) **tidak dipakai
  dan tidak pernah dihubungi**. Nol network call, nol permission
  (tanpa INTERNET, tanpa kamera/mic).
- ❌ Satu dependensi pihak ketiga saja (just_audio, untuk audio test) —
  sisanya hanya Flutter SDK.
- ❌ Package beda: `com.leeubt.ubtkorea.rebuild` (bukan package asli).

## Menjalankan

Butuh Flutter SDK ≥ 3.22 (Dart ≥ 3.4). Flutter **tidak** terpasang di VM
pengembangan, jadi build hanya terbukti lewat GitHub Actions.

```bash
flutter pub get
flutter analyze
flutter run            # debug di emulator / HP
flutter build apk --release
```

## CI (GitHub Actions)

Workflow `.github/workflows/build-apk.yml`: trigger push ke `main` +
manual dispatch. Job `analyze` (`flutter analyze`) jalan dulu, lalu
`build-apk` (`flutter build apk --release`) dan mengunggah APK sebagai
artifact `ubt-korea-rebuild-apk`.

## Menerbitkan (dilakukan terpisah, setelah scaffold selesai)

```bash
gh repo create Ardhi9696/ubt-korea-rebuild --public --source=. --push
# lalu cek: Actions tab → job build-apk → artifact ubt-korea-rebuild-apk
```

> Build **belum terbukti** di mesin lokal (tanpa Flutter SDK) — klaim
> berhasil hanya boleh dibuat setelah job Actions hijau.
