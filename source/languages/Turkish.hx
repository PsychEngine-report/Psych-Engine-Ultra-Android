package languages;

/**
 * Türkçe (Turkish)
 * 
 * Yeni çeviri eklemek için:
 *   "anahtar_kelime" => "çevrilen metin"
 * 
 * Image override eklemek için:
 *   "images/orjinal" => "images/languages/images/turkey/yeni"
 * 
 * Not: Key'ler küçük harf, boşluk yerine alt çizgi, noktalama işaretleri kaldırılmış olmalı.
 */
class Turkish implements ILanguage
{
    public var langName:String = 'Türkçe';
    public var alphabetPath:Null<String> = null; // 'alphabet_tr' gibi özel bir alphabet varsa yaz
	
	public function new() {}
    public var phrases:Map<String, String> = [
        // ── Genel ──────────────────────────────────────────
        "play_on_a_friday_night"            => "Bir Cuma... Gecesi Oyna.",
        "freeplay"                          => "Serbest Oyun",
        "story_mode"                        => "Hikaye Modu",
        "options"                           => "Ayarlar",
        "credits"                           => "Yapımcılar",
        "exit_to_menu"                      => "Menüye Dön",
        "back"                              => "Geri",
        "confirm"                           => "Onayla",

        // ── Freeplay ───────────────────────────────────────
        "search"                            => "Ara",
        "no_songs_found"                    => "Şarkı bulunamadı.",
        "personal_best"                     => "En İyi Skorun",
        "not_played"                        => "Hiç Oynanmadı",

        // ── Pause Menu ────────────────────────────────────
        "resume"                            => "Devam Et",
        "restart_song"                      => "Şarkıyı Yeniden Başlat",
        "exit_to_menu_pause"                => "Menüye Dön",
        "botplay"                           => "Bot Oyunu",

        // ── Options ───────────────────────────────────────
        "note_colors"                       => "Nota Renkleri",
        "controls"                          => "Kontroller",
        "adjust_offset"                     => "Offset Ayarla",
        "graphics"                          => "Grafik",
        "visuals_and_ui"                    => "Görsel & Arayüz",
        "gameplay"                          => "Oynanış",
        "accessibility"                     => "Erişilebilirlik",

        // ── Gameplay ─────────────────────────────────────
        "game_over"                         => "Oyun Bitti",
        "week"                              => "Hafta",
        "difficulty"                        => "Zorluk",
        "easy"                              => "Kolay",
        "normal"                            => "Normal",
        "hard"                              => "Zor",

        // ── TouchPad ─────────────────────────────────────
        "touchpad_dpadmode_missing"         => "TouchPad dpadMode \"{1}\" bulunamadı.",
        "touchpad_actionmode_missing"       => "TouchPad actionMode \"{1}\" bulunamadı.",

        // ── Errors & Warnings ────────────────────────────
        "chart_editor_unsaved_changes"      => "Kaydedilmemiş değişiklikler var!",
        "lua_error"                         => "Lua hatası: {1}",
    ];

    public var imageOverrides:Map<String, String> = [
        // Sözdizimi: "orijinal/path" => "dil-özel/path"
        // .png uzantısı ekleme, Paths.image() bunu halleder
        
        // ── UI Images ────────────────────────────────────
        "bad"                               => "languages/images/turkey/kötü",
        "good"                              => "languages/images/turkey/iyi",
        "sick"                              => "languages/images/turkey/mükemmel",
        "shit"                              => "languages/images/turkey/berbat",

        // ── Title Screen ─────────────────────────────────
        "logoBumpin"                        => "languages/images/turkey/logoBumpin",
        "titleEnter"                        => "languages/images/turkey/titleEnter",

        // ── Menu ─────────────────────────────────────────
        // "menuBG"                         => "languages/images/turkey/menuBG",
    ];
}
