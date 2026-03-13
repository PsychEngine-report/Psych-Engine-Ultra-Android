package backend;

import languages.ILanguage;
import languages.English;
import languages.Turkish;
import languages.Spanish;

/**
 * Language sistemi — Statik Haxe Map tabanlı.
 * 
 * Yeni dil eklemek için:
 *   1. source/languages/YeniDil.hx oluştur (ILanguage implement et)
 *   2. Aşağıdaki registerLanguages() fonksiyonuna ekle
 *   3. assets/shared/images/ultra/images/language/yenidil.png ekle
 */
class Language
{
    public static var defaultLangName:String = 'English (US)';
    public static var defaultLangKey:String  = 'english';

    /** Kayıtlı tüm diller: key (lowercase, örn: "turkish") => ILanguage instance */
    public static var registeredLanguages:Map<String, ILanguage> = [];

    #if TRANSLATIONS_ALLOWED
    private static var currentLang:ILanguage = null;
    private static var phrases:Map<String, String> = [];
    private static var imageOverrides:Map<String, String> = [];
    #end

    /**
     * Tüm dilleri kaydet. Yeni dil = buraya bir satır ekle.
     */
    public static function registerLanguages():Void
    {
        registeredLanguages.clear();
        registeredLanguages.set('english',  new English());
        registeredLanguages.set('turkish',  new Turkish());
        registeredLanguages.set('spanish',  new Spanish());
        // registeredLanguages.set('french',   new French());
        // registeredLanguages.set('german',   new German());
        // registeredLanguages.set('portuguese', new Portuguese());
        // registeredLanguages.set('russian',  new Russian());
        // registeredLanguages.set('japanese', new Japanese());
        // registeredLanguages.set('korean',   new Korean());
        // registeredLanguages.set('chinese',  new Chinese());
    }

    /**
     * Mevcut dili yükle. ClientPrefs.data.language key'ini kullanır.
     */
    public static function reloadPhrases():Void
    {
        if (registeredLanguages.keys().hasNext() == false)
            registerLanguages();

        #if TRANSLATIONS_ALLOWED
        var langKey:String = ClientPrefs.data.language.toLowerCase().trim();
        currentLang = registeredLanguages.get(langKey);

        if (currentLang == null)
        {
            trace('[Language] "$langKey" bulunamadı, English\'e dönülüyor.');
            ClientPrefs.data.language = defaultLangKey;
            currentLang = registeredLanguages.get(defaultLangKey);
        }

        // Phrase ve image override map'lerini yükle
        phrases       = (currentLang != null) ? currentLang.phrases       : [];
        imageOverrides = (currentLang != null) ? currentLang.imageOverrides : [];

        // Alphabet path
        var alphaPath:String = (currentLang != null && currentLang.alphabetPath != null)
            ? currentLang.alphabetPath
            : 'alphabet';
        AlphaCharacter.loadAlphabetData(alphaPath);

        #else
        AlphaCharacter.loadAlphabetData();
        #end
    }

    /**
     * Çeviri getir.
     * @param key           Çeviri anahtarı (ör: "play_on_a_friday_night")
     * @param defaultPhrase Bulunamazsa kullanılacak string
     * @param values        {1}, {2} gibi placeholder değerleri
     */
    inline public static function getPhrase(key:String, ?defaultPhrase:String, values:Array<Dynamic> = null):String
    {
        #if TRANSLATIONS_ALLOWED
        var str:String = phrases.get(formatKey(key));
        if (str == null) str = defaultPhrase;
        #else
        var str:String = defaultPhrase;
        #end

        if (str == null) str = key;

        if (values != null)
            for (num => value in values)
                str = str.replace('{${num + 1}}', value);

        return str;
    }

    /**
     * Image path çevirisi. 
     * Örnek: "images/bad" → "images/languages/images/turkey/kötü"
     * Bulunamazsa orijinal path döner.
     */
    public static function getFileTranslation(key:String):String
    {
        #if TRANSLATIONS_ALLOWED
        var trimmed:String = key.trim().toLowerCase();

		var translated:String = imageOverrides.get(trimmed);
		if (translated != null) return translated;

		if (trimmed.startsWith('images/'))
		{
			translated = imageOverrides.get(trimmed.substr('images/'.length));
			if (translated != null) return 'images/' + translated;
		}
        #end
        return key;
    }

    /**
     * Dil adını döner (görünen ad).
     */
    public static function getLangDisplayName(key:String):String
    {
        if (registeredLanguages.keys().hasNext() == false)
            registerLanguages();

        var lang:ILanguage = registeredLanguages.get(key.toLowerCase());
        if (lang != null) return lang.langName;
        return key;
    }

    /**
     * Aktif dil key'ini döner.
     */
    public static function getCurrentLangKey():String
    {
        return ClientPrefs.data.language.toLowerCase().trim();
    }

    #if TRANSLATIONS_ALLOWED
    inline static private function formatKey(key:String):String
    {
        final hideChars = ~/[~&\\\/;:<>#.,'"%?!]/g;
        return hideChars.replace(key.replace(' ', '_'), '').toLowerCase().trim();
    }
    #end

    #if LUA_ALLOWED
    public static function addLuaCallbacks(lua:State)
    {
        Lua_helper.add_callback(lua, "getTranslationPhrase", function(key:String, ?defaultPhrase:String, ?values:Array<Dynamic> = null) {
            return getPhrase(key, defaultPhrase, values);
        });
        Lua_helper.add_callback(lua, "getFileTranslation", function(key:String) {
            return getFileTranslation(key);
        });
    }
    #end
}
