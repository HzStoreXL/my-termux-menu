#!/bin/bash
# ==========================================
# 🌟 TERMUX MENU BY XL SMART LC
# ==========================================

REPO_LIST="$HOME/.termux_repos"

# clone folder ketika folder tidak ada
run_or_clone() {
  local folder="$1"
  local repo_url="$2"

  cd "$HOME" || exit

  if [ ! -d "$HOME/$folder" ]; then
    echo -e "\e[33m🔍 Folder $folder belum ada, cloning dari $repo_url ...\e[0m"
    git clone "$repo_url" "$HOME/$folder" || {
      echo -e "\e[31m❌ Gagal clone repo $repo_url\e[0m"
      read -p "ENTER untuk kembali..."
      return
    }

    # Jalankan setup.sh jika ada
    if [ -f "$HOME/$folder/setup.sh" ]; then
      echo -e "\e[36m🛠 Menjalankan setup.sh (hanya pertama kali)...\e[0m"
      (cd "$HOME/$folder" && bash setup.sh) || echo -e "\e[31m❌ setup.sh gagal dijalankan.\e[0m"
    fi
  fi

  cd "$HOME/$folder" || {
    echo -e "\e[31m❌ Gagal masuk ke folder $folder\e[0m"
    read -p "ENTER..."
    return
  }

  if [ -f "main.py" ]; then
    echo -e "\e[90m🚀 Menjalankan: python main.py\e[0m"
    python main.py
  else
    echo -e "\e[31m❌ File main.py tidak ditemukan di $folder\e[0m"
  fi

  read -p "ENTER untuk kembali ke menu..."
}

# Tambah Repo baru + langsung clone & setup
add_new_repo() {
  echo
  read -p "🌐 Masukkan URL Git repo: " repo
  [ -z "$repo" ] && echo "❌ URL repo tidak boleh kosong." && read -p "ENTER..." && return

  folder=$(basename "$repo" .git)
  echo -e "\e[33m🔍 Meng-clone repo '$folder'...\e[0m"

  # Hapus folder lama kalau ada
  [ -d "$HOME/$folder" ] && rm -rf "$HOME/$folder"

  # Clone repo
  git clone "$repo" "$HOME/$folder" || {
    echo -e "\e[31m❌ Gagal clone repo $repo\e[0m"
    read -p "ENTER..."
    return
  }

  # Jalankan setup.sh jika ada
  if [ -f "$HOME/$folder/setup.sh" ]; then
    echo -e "\e[36m🛠 Menjalankan setup.sh...\e[0m"
    (cd "$HOME/$folder" && bash setup.sh)
  fi

  # Jalankan main.py jika ada
  if [ -f "$HOME/$folder/main.py" ]; then
    echo -e "\e[90m🚀 Menjalankan: python main.py\e[0m"
    (cd "$HOME/$folder" && python main.py)
  fi

  echo "$folder|$repo" >> "$REPO_LIST"
  echo -e "\e[32m✅ Repo '$folder' berhasil ditambahkan, di-setup, dan dijalankan!\e[0m"
  read -p "ENTER untuk kembali ke menu..."
}
# Hapus Repo
delete_repo() {
  echo
  echo -e "\e[1;31m🗑️  Hapus Repository dari menu:\e[0m"
  echo
  dirs=($(find "$HOME" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort))
  if [ ${#dirs[@]} -eq 0 ]; then
    echo "Tidak ada folder yang bisa dihapus."
    read -p "ENTER..."
    return
  fi

  i=1
  for d in "${dirs[@]}"; do
    echo "  [$i] $d"
    ((i++))
  done

  echo
  read -p "Pilih nomor folder yang ingin dihapus: " num
  [[ ! "$num" =~ ^[0-9]+$ ]] && echo "❌ Pilihan tidak valid." && read -p "ENTER..." && return
  [[ $num -lt 1 || $num -gt ${#dirs[@]} ]] && echo "❌ Nomor di luar jangkauan." && read -p "ENTER..." && return

  target="${dirs[$((num-1))]}"
  echo
  read -p "⚠️ Yakin ingin menghapus folder '$target'? (y/n): " konfirm
  if [[ "$konfirm" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/$target"
    echo -e "\e[32m✅ Folder '$target' berhasil dihapus.\e[0m"
  else
    echo "Dibatalkan."
  fi
  read -p "ENTER untuk kembali ke menu..."
}  

# Update repo
update_repo() {
  echo -e "\n\e[36m🔄 Memperbarui semua repo Git di menu...\e[0m"
  for dir in "$HOME"/*/; do
    [ -d "$dir/.git" ] || continue
    echo -e "\n\e[33m📦 Memperbarui $(basename "$dir")...\e[0m"
    cd "$dir" || continue
    git pull --rebase || echo -e "\e[31m❌ Gagal update $(basename "$dir")\e[0m"
  done
  echo -e "\n\e[32m✅ Semua repo selesai diperbarui!\e[0m"
  read -p "ENTER untuk kembali ke menu..."
}

# Menu Utama repo
while true; do
  clear
  echo -e "\e[1;36m╔════════════════════════════════════════════════╗\e[0m"
  echo -e "\e[1;36m║\e[0m          🌟 \e[1;33mSELAMAT DATANG DI TERMUX\e[0m 🌟        \e[1;36m║\e[0m"
  echo -e "\e[1;36m║\e[0m                 \e[90mBY XL SMART LC INDO\e[0m            \e[1;36m║\e[0m"
  echo -e "\e[1;36m╚════════════════════════════════════════════════╝\e[0m"
  echo
  echo -e "\e[1;33m📂 Pilih program yang ingin dijalankan:\e[0m"

  echo -e "  \e[35m[1]\e[0m ➤ Jalankan anomali-xl"
  echo -e "  \e[35m[2]\e[0m ➤ Jalankan me-cli"
  echo -e "  \e[35m[3]\e[0m ➤ Jalankan xldor"
  echo -e "  \e[35m[4]\e[0m ➤ Jalankan dorxl"
  echo -e "  \e[35m[5]\e[0m ➤ Jalankan reedem"

  EXCLUDE_SET=" anomali-xl me-cli xldor dorxl reedem "
  DYN_NAMES=()
  n=6
  for dir in $(find "$HOME" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort); do
    case "$dir" in .*) continue ;; esac
    [[ " $EXCLUDE_SET " == *" $dir "* ]] && continue
    [ -f "$HOME/$dir/main.py" ] || continue
    DYN_NAMES+=("$dir")
    printf "  \e[32m[%d]\e[0m ➤ Jalankan %s\n" "$n" "$dir"
    n=$((n+1))
  done

  echo
  echo -e "  \e[35m[a]\e[0m ➤ Tambah repo baru"
  echo -e "  \e[35m[d]\e[0m ➤ Hapus repo dari menu"
  echo -e "  \e[35m[u]\e[0m ➤ Update semua repo"
  echo -e "  \e[35m[m]\e[0m ➤ Keluar menu (masuk shell biasa)"
  echo -e "  \e[31m[q]\e[0m ➤ Keluar Termux"
  echo

  read -p "Masukkan pilihan [1-${n}/a/d/u/m/q]: " pilih

  case "$pilih" in
    1) run_or_clone "anomali-xl" "https://saus.gemail.ink/anomali/anomali-xl.git" ;;
    2) run_or_clone "me-cli" "https://github.com/purplemashu/me-cli.git" ;;
    3) run_or_clone "xldor" "https://github.com/baloenk/xldor.git" ;;
    4) run_or_clone "dorxl" "https://github.com/HzStoreXL/dorxl" ;;
    5) run_or_clone "reedem" "https://github.com/kejuashuejia/reedem.git" ;;
    a|A) add_new_repo ;;
    d|D) delete_repo ;;
    u|U) update_repo ;;
    [0-20]*)
      index=$((pilih - 6))
      if [ $index -ge 0 ] && [ $index -lt ${#DYN_NAMES[@]} ]; then
        cd "$HOME/${DYN_NAMES[$index]}" || {
          echo -e "\e[31m❌ Gagal masuk folder.\e[0m"
          read -p "ENTER..."
          continue
        }
        echo -e "\e[90mMenjalankan: python main.py\e[0m"
        python main.py
        read -p "ENTER untuk kembali ke menu..."
      else
        echo -e "\e[31m❌ Nomor tidak valid.\e[0m"
        read -p "ENTER..."
      fi
      ;;
    m|M)
      echo -e "\n\e[36mKeluar dari menu. Selamat bekerja di shell biasa! 🧑‍💻\e[0m"
      break
      ;;
    q|Q)
      echo -e "\n\e[31mMenutup Termux... sampai jumpa! 👋\e[0m"
      exit 0
      ;;
    *)
      echo -e "\e[31m❌ Pilihan tidak dikenali.\e[0m"
      read -p "ENTER untuk kembali ke menu..."
      ;;
  esac
done
