# Menggunakan image Jenkins resmi sebagai dasar
FROM jenkins/jenkins:lts

# Ganti ke user root untuk meng-install software
USER root

# Ganti sumber apt ke mirror CDN untuk koneksi yang lebih stabil
RUN echo "deb http://cdn-fastly.deb.debian.org/debian/ trixie main" > /etc/apt/sources.list && \
echo "deb http://cdn-fastly.deb.debian.org/debian/ trixie-updates main" >> /etc/apt/sources.list && \
echo "deb http://security.debian.org/debian-security trixie-security main" >> /etc/apt/sources.list

# Install paket-paket yang dibutuhkan dan Docker client
# Menambahkan opsi --fix-missing untuk berjaga-jaga
RUN apt-get update && apt-get install -y --fix-missing docker.io

# Tambahkan user 'jenkins' ke grup 'root' (GID 0) agar cocok dengan kepemilikan docker.sock
RUN usermod -aG root jenkins

# Kembali ke user jenkins agar tetap aman
USER jenkins