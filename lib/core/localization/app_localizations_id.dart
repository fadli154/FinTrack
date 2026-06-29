const Map<String, String> idID = {
  // Global / Actions
  'close': 'Tutup',
  'cancel': 'Batal',
  'save': 'Simpan',
  'update': 'Update',
  'delete': 'Hapus',
  'error': 'Error',
  'success': 'Sukses',
  'loading': 'Memuat...',
  'active_filter': 'Filter Aktif',

  // Onboarding
  'intro_title_1': 'Pantau Uang Anda',
  'intro_body_1': 'Kelola pemasukan dan pengeluaran Anda dengan mudah, dan kendalikan keuangan Anda sepenuhnya.',
  'intro_title_2': 'Wawasan Keuangan Pintar',
  'intro_body_2': 'Temukan ke mana uang Anda pergi dan tingkatkan kebiasaan Anda dengan wawasan pintar.',
  'skip': 'Lewati',
  'start': 'Mulai',

  // Authentication
  'login_here': 'Masuk di sini',
  'welcome_back': 'Selamat datang kembali, Anda telah dirindukan!',
  'email': 'Email',
  'password': 'Password',
  'name': 'Nama',
  'forgot_password_q': 'Lupa Kata Sandi Anda?',
  'login': 'Masuk',
  'register_here': 'Daftar di sini',
  'create_account_start': 'Buat akun Anda untuk memulai',
  'register': 'Daftar',
  'dont_have_account': 'Belum punya akun? ',
  'already_have_account': 'Sudah punya akun? ',
  'or_continue_with': 'Atau lanjutkan dengan',

  // Auth Messages
  'enter_email_first': 'Masukkan email dulu',
  'password_reset_sent': 'Link reset password dikirim ke email',
  'account_created': 'Akun berhasil dibuat',
  'save_user_failed': 'Gagal simpan data user',
  'login_success': 'Login sukses',
  'login_failed': 'Email atau password salah',
  'logout_success': 'Berhasil keluar',
  'google_login_failed': 'Login Google gagal',

  // Auth Errors
  'error_user_not_found': 'Email tidak terdaftar',
  'error_wrong_password': 'Password salah',
  'error_invalid_email': 'Format email tidak valid',
  'error_email_already_in_use': 'Email sudah digunakan',
  'error_weak_password': 'Password terlalu lemah (min 6 karakter)',
  'error_default': 'Terjadi kesalahan, coba lagi',

  // Bottom Navigation
  'nav_history': 'Riwayat',
  'nav_charts': 'Grafik',
  'nav_camera': 'Kamera',
  'nav_reports': 'Laporan',
  'nav_me': 'Saya',

  // Side Drawer
  'drawer_home': 'Beranda',
  'drawer_profile': 'Profil',
  'drawer_logout': 'Keluar',

  // Dashboard / Transactions
  'showing_period': 'Menampilkan: @period',
  'user_not_logged_in': 'User belum login',
  'error_prefix': 'Error: @error',
  'income': 'Pemasukan',
  'expense': 'Pengeluaran',
  'add': 'Tambah',
  'delete_category': 'Hapus Kategori',
  'delete_category_q': 'Yakin mau hapus \'@title\'?',
  'delete_transaction': 'Hapus Transaksi',
  'delete_transaction_q': 'Yakin mau hapus transaksi ini?',
  'category_deleted': 'Kategori berhasil dihapus',
  'transaction_deleted': 'Transaksi berhasil dihapus',
  'transaction_added': 'Transaksi berhasil ditambahkan',
  'transaction_updated': 'Transaksi berhasil diubah!',
  'add_category': 'Tambah Kategori',
  'category_name_hint': 'Nama kategori',
  'category_added': 'Kategori berhasil ditambahkan',
  'edit_transaction': 'Edit Transaksi',
  'amount_hint': 'Rp 0',
  'note_hint': 'Catatan',
  'date_label': 'Tanggal: @date',
  'empty_state_history': 'Tidak ada catatan',
  'search_hint': 'Cari transaksi',
  'filter_all_time': 'All Time',
  'filter_today': 'Hari Ini',
  'filter_month': 'Bulan Ini',
  'filter_custom': 'Custom',

  // Reports
  'report_title': 'Laporan',
  'report_showing': 'Menampilkan: @period',
  'balance': 'Saldo',
  'average_income': 'Rata-rata Income',
  'average_expense': 'Rata-rata Expense',
  'total_transactions': 'Total Transaksi',
  'average_amount': 'Rata-rata',
  'category_summary': 'Ringkasan Kategori',
  'transaction_history': 'Riwayat Transaksi',
  'empty_reports': 'Belum ada data pada filter ini',
  'change_filter_hint': 'Coba ubah filter tanggalnya',
  'no_transactions': 'Belum ada transaksi',
  'load_more': 'Muat Lebih Banyak',
  'financial_report': 'Laporan Keuangan',
  'pdf_filename': 'laporan_keuangan.pdf',

  // Charts
  'charts_title': 'Statistik',
  'income_vs_expense': 'Income vs Expense',
  'income_ratio': 'Income Ratio',
  'expense_ratio': 'Expense Ratio',
  'net_balance': 'Net Balance',
  'monthly_trend': 'Trend Bulanan',
  'monthly_trend_desc': 'Pergerakan pemasukan dan pengeluaran per bulan',
  'monthly_trend_empty': 'Data belum cukup untuk trend bulanan',
  'monthly_trend_empty_desc': 'Coba pilih filter All Time atau rentang tanggal yang lebih panjang',
  'top_categories': 'Top Kategori Pengeluaran',
  'top_categories_empty': 'Belum ada data pengeluaran',
  'health_score': 'Financial Health Score',
  'saving_rate': 'Saving Rate',
  'health_status': 'Financial Health Status',

  // Health Statuses
  'health_very_healthy': 'Sangat Sehat 🟢',
  'health_healthy': 'Cukup Sehat 🟡',
  'health_needs_attention': 'Perlu Perhatian 🟠',
  'health_danger': 'Bahaya 🔴',

  // Insights
  'insight_very_healthy': 'Keuangan kamu sangat sehat 🔥',
  'insight_healthy': 'Bagus, pertahankan tabunganmu 👍',
  'insight_warning': 'Pengeluaran mulai besar ⚠️',
  'insight_danger': 'Pengeluaran lebih besar dari pemasukan 🚨',

  // Profile
  'welcome_profile': 'Hai, selamat datang di FinTrack!',
  'premium_center': 'Pusat Premium',
  'recommend_to_friends': 'Rekomendasikan ke teman',
  'block_ads': 'Blokir Iklan',
  'settings': 'Pengaturan',
  'dark_mode': 'Dark Mode',
  'language': 'Bahasa',
  'english': 'English',
  'indonesian': 'Bahasa Indonesia',
  'current_language': 'Bahasa Saat Ini',

  // Camera / YOLO
  'yolo_active': 'Deteksi uang realtime aktif',
  'yolo_stopped': 'Deteksi berhenti',
  'yolo_objects': '@count objek',
  'yolo_voice': 'Suara',
  'yolo_speed': 'Kecepatan',
  'yolo_conf': 'Conf',
  'yolo_voice_speed': 'Kecepatan suara',
  'yolo_voice_interval': 'Interval pengulangan suara',
  'yolo_sensitivity': 'Sensitivity detection',
  'yolo_start_scan': 'Mulai Pindai',
  'yolo_stop_scan': 'Hentikan Pindai',

  // Admin — Umum
  'admin_dashboard': 'Dashboard',
  'admin_dashboard_sub': 'Ringkasan & statistik aplikasi',
  'admin_users': 'Pengguna',
  'admin_categories': 'Kategori',
  'admin_settings': 'Pengaturan',
  'admin_transactions': 'Transaksi',

  // Admin — Statistik
  'total_users': 'Total Pengguna',
  'active_users': 'Pengguna Aktif',
  'disabled_users': 'Pengguna Dinonaktifkan',
  'recent_users': 'Pengguna Terbaru',
  'view_all': 'Lihat Semua',

  // Admin — Role & Status
  'role_admin': 'Admin',
  'role_user': 'Pengguna',
  'status_active': 'Aktif',
  'status_disabled': 'Dinonaktifkan',

  // Admin — Manajemen Pengguna
  'search_users': 'Cari berdasarkan nama atau email',
  'no_users_found': 'Tidak ada pengguna ditemukan',
  'user_detail': 'Detail Pengguna',
  'created_at_label': 'Dibuat Pada',
  'last_login_label': 'Login Terakhir',
  'currency': 'Mata Uang',
  'promote_to_admin': 'Jadikan Admin',
  'demote_to_user': 'Turunkan ke Pengguna',
  'disable_account': 'Nonaktifkan Akun',
  'enable_account': 'Aktifkan Akun',
  'delete_user': 'Hapus Pengguna',
  'promote_confirm': 'Pengguna ini akan mendapatkan hak admin.',
  'demote_confirm': 'Pengguna ini akan kehilangan hak admin.',
  'disable_confirm': 'Pengguna ini tidak dapat login.',
  'enable_confirm': 'Pengguna ini dapat login kembali.',
  'delete_user_confirm': 'Tindakan ini tidak dapat dibatalkan. Data pengguna akan dihapus dari panel admin.',
  'confirm': 'Konfirmasi',
  'back': 'Kembali',

  // Admin — Feedback
  'user_promoted': 'Pengguna dijadikan Admin',
  'user_demoted': 'Pengguna diturunkan ke Pengguna',
  'user_disabled': 'Akun telah dinonaktifkan',
  'user_enabled': 'Akun telah diaktifkan',
  'user_deleted': 'Pengguna telah dihapus',

  // Admin — Kategori
  'no_categories': 'Belum ada kategori',
  'category_icon': 'Ikon (emoji)',

  // Tidak Diizinkan
  'unauthorized_title': 'Akses Ditolak',
  'unauthorized_body': 'Anda tidak memiliki izin untuk mengakses halaman ini.',

  // Navigasi tambahan
  'switch_to_user_app': 'Beralih ke Aplikasi Pengguna',
};
