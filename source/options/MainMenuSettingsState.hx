package options;

/**
 * Ana Menü ayarlarını kategorize şekilde düzenleyen state.
 * OptionsState > 'Görünüş & Arayüz' altından veya doğrudan açılabilir.
 *
 * Ayarlar otomatik olarak ClientPrefs.data'ya kaydedilir.
 * MainMenuState bu değerleri create() içinde okur.
 */
class MainMenuSettingsState extends CategoryOptionsMenu
{
	override function create()
	{
		title    = 'Ana Menü Ayarları';
		rpcTitle = 'Ana Menü Ayarları';

		// ══════════════════════════════════════════════
		// KATEGORİ 1 — Sol Panel (Profil & İstatistik)
		// ══════════════════════════════════════════════
		var catSidePanel = new OptionCategory(
			'Sol Panel Ayarları',
			'Ana menünün sol tarafındaki profil, istatistik ve son oynanan panelleri.'
		);

		var optProfile = new Option(
			'Profil Paneli',
			'Sol üstteki isim, ikon, seviye ve XP barını gösterir.',
			'showProfilePanel',
			BOOL
		);
		catSidePanel.addOption(optProfile);

		var optStats = new Option(
			'İstatistik Paneli',
			'Toplam skor, oynanan şarkı sayısı ve doğruluk oranını gösterir.',
			'showStatsPanel',
			BOOL
		);
		catSidePanel.addOption(optStats);

		var optLastPlayed = new Option(
			'Son Oynanan Paneli',
			'En son oynanan şarkıyı ve skorunu gösterir.',
			'showLastPlayedPanel',
			BOOL
		);
		catSidePanel.addOption(optLastPlayed);

		addCategory(catSidePanel);

		// ══════════════════════════════════════════════
		// KATEGORİ 2 — Üst Bar
		// ══════════════════════════════════════════════
		var catTopBar = new OptionCategory(
			'Üst Bar Ayarları',
			'Ekranın üstündeki saat, tarih ve selamlama yazılarını özelleştir.'
		);

		var optClock = new Option(
			'Saat & Tarih',
			'Üst sağdaki saat ve tarih göstergesini açar/kapatır.',
			'showClock',
			BOOL
		);
		catTopBar.addOption(optClock);

		var optGreeting = new Option(
			'Selamlama Yazısı',
			'"Günaydın, Oyuncu!" gibi karşılama metnini gösterir.',
			'showGreeting',
			BOOL
		);
		catTopBar.addOption(optGreeting);

		addCategory(catTopBar);

		// ══════════════════════════════════════════════
		// KATEGORİ 3 — Alt Bar & Haberler
		// ══════════════════════════════════════════════
		var catBottomBar = new OptionCategory(
			'Alt Bar Ayarları',
			'Ekranın altındaki duyuru şeridini ve sürüm yazısını yönet.'
		);

		var optNews = new Option(
			'Duyuru Şeridi',
			'Altta kayan duyuru/haber metnini gösterir.',
			'showNewsBar',
			BOOL
		);
		catBottomBar.addOption(optNews);

		var optVersion = new Option(
			'Sürüm Yazısı',
			'Sağ alttaki sürüm numarasını gösterir.',
			'showVersionText',
			BOOL
		);
		catBottomBar.addOption(optVersion);

		addCategory(catBottomBar);

		// ══════════════════════════════════════════════
		// KATEGORİ 4 — Arka Plan Efektleri
		// ══════════════════════════════════════════════
		var catBG = new OptionCategory(
			'Arka Plan Efektleri',
			'Parçacıklar, yüzen küreler ve grid arka planı gibi görsel efektler.'
		);

		var optParticles = new Option(
			'Parçacık Efekti',
			'Arka planda yükselen küçük parçacıkları gösterir.',
			'showParticles',
			BOOL
		);
		catBG.addOption(optParticles);

		var optOrbs = new Option(
			'Yüzen Küreler',
			'Arka planda yavaşça hareket eden parlak küreleri gösterir.',
			'showFloatingOrbs',
			BOOL
		);
		catBG.addOption(optOrbs);

		var optGrid = new Option(
			'Grid Arka Planı',
			'Arka plandaki hareketli grid desenini gösterir.',
			'showGridBG',
			BOOL
		);
		catBG.addOption(optGrid);

		var optScanline = new Option(
			'Tarama Çizgileri',
			'Ekranda hareket eden ince yatay tarama çizgilerini gösterir.',
			'showScanlines',
			BOOL
		);
		catBG.addOption(optScanline);

		var optParallax = new Option(
			'Paralaks Efekti',
			'Fareyle arka planın hafifçe hareket etmesini sağlar.',
			'showParallax',
			BOOL
		);
		catBG.addOption(optParallax);

		addCategory(catBG);

		// ══════════════════════════════════════════════
		// Menüyü inşa et
		// ══════════════════════════════════════════════
		buildMenu();

		super.create();
	}
}
