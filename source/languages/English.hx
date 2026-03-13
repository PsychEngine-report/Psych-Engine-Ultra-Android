package languages;

/**
 * English (US) — Default language.
 * Phrases are empty because English is the base game language.
 * Add overrides here if you want to change default strings.
 */
class English implements ILanguage
{
	public function new() {}
    public var langName:String = 'English (US)';
    public var alphabetPath:Null<String> = null; // uses default

    public var phrases:Map<String, String> = [];

    public var imageOverrides:Map<String, String> = [];
}
