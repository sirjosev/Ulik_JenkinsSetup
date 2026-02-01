# Setup Jenkins Kustom dengan Docker

Dokumen ini menjelaskan cara membangun dan menjalankan image Jenkins kustom yang dirancang untuk pipeline CI/CD.

Image ini dimodifikasi untuk bisa menjalankan perintah Docker dari dalam Jenkins itu sendiri, sebuah metode yang dikenal sebagai **Docker-out-of-Docker (DooD)**.

## 1. Prasyarat

*   **Docker Desktop**: Ter-install dan berjalan di komputer Anda.

## 2. Membangun Image `jenkins-docker`

`Dockerfile` di dalam direktori ini akan membuat sebuah image Jenkins baru dengan tambahan Docker CLI. Ini penting agar Jenkins bisa mengeksekusi perintah seperti `docker build` dan `docker run`.

#### Isi `Dockerfile`
```dockerfile
# Menggunakan image Jenkins resmi sebagai dasar
FROM jenkins/jenkins:lts

# Ganti ke user root untuk meng-install software
USER root

# Install Docker client
RUN apt-get update && apt-get install -y docker.io

# Tambahkan user 'jenkins' ke grup 'root' (GID 0) 
# Ini krusial agar Jenkins punya izin untuk mengakses file docker.sock dari host.
RUN usermod -aG root jenkins

# Kembali ke user jenkins agar tetap aman
USER jenkins
```

#### Perintah Build
Untuk membangun image, navigasikan ke direktori `Jenkins_Setup` di terminal dan jalankan:
```bash
docker build -t jenkins-docker .
```

## 3. Menjalankan Kontainer Jenkins

Gunakan perintah di bawah ini untuk menjalankan kontainer dari image `jenkins-docker` yang baru saja Anda buat.

```powershell
# Hentikan dan hapus kontainer lama jika ada
docker stop jenkins-local3
docker rm jenkins-local3

# Jalankan kontainer baru dengan semua konfigurasi yang diperlukan
docker run --name jenkins-local3 ^
  -p 8080:8080 ^
  -p 50000:50000 ^
  -v C:\Users\josev\jenkins_home:/var/jenkins_home ^
  -v C:\Users\josev\DIR_C\public_lab1\Learn_CICD:/Learn_CICD ^
  -v /var/run/docker.sock:/var/run/docker.sock ^
  -e JAVA_OPTS="-Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true" ^
  jenkins-docker
```
*(Catatan: Ganti path untuk `-v` jika direktori `jenkins_home` atau `Learn_CICD` Anda berada di lokasi lain).*

#### Penjelasan Perintah `docker run`
*   `-p 8080:8080`: Memetakan port web UI Jenkins.
*   `-p 50000:50000`: Memetakan port untuk Jenkins agent.
*   `-v ...:/var/jenkins_home`: **Penting!** Memetakan folder di host Anda untuk menyimpan semua data Jenkins (jobs, plugins, dll).
*   `-v ...:/Learn_CICD`: Memetakan folder proyek Anda agar bisa diakses oleh Jenkins.
*   `-v /var/run/docker.sock:/var/run/docker.sock`: **Kunci DooD.** Menghubungkan Docker CLI di kontainer ke Docker Daemon di host.
*   `-e JAVA_OPTS="..."`: Mengizinkan Jenkins untuk melakukan checkout dari repositori Git di sistem file lokal.

## 4. Mengakses Jenkins
1.  Buka browser dan pergi ke `http://localhost:8080`.
2.  Dapatkan password administrator awal dari log dengan perintah: `docker logs jenkins-local3`.
3.  Ikuti instruksi di layar untuk menyelesaikan setup.

---

## 5. Troubleshooting Umum

#### Error: `i/o timeout` atau `Killed` saat `docker build`
*   **Masalah**: Docker kehabisan memori (RAM) atau koneksi jaringan internalnya terganggu.
*   **Solusi**:
    1.  **RAM**: Buka Docker Desktop Settings -> Resources -> Advanced. Naikkan alokasi **Memory** ke **4GB** atau lebih, lalu Apply & Restart.
    2.  **Jaringan**: Coba restart Docker Desktop. Jika masih gagal, coba nonaktifkan sementara Firewall/Antivirus Anda.

#### Error: `fatal: detected dubious ownership in repository` saat Build di Jenkins
*   **Masalah**: User `jenkins` di dalam kontainer berbeda dengan user pemilik folder di komputer Anda.
*   **Solusi**: Izinkan Git untuk menggunakan repositori tersebut dengan perintah berikut di terminal **host** Anda:
    1.  Masuk ke shell kontainer: `docker exec -it jenkins-local3 bash`
    2.  Jalankan perintah (sesuaikan path jika perlu):
        ```bash
        git config --global --add safe.directory /Learn_CICD/Dummy_Automasi/.git
        ```
    3.  Ketik `exit` untuk keluar.