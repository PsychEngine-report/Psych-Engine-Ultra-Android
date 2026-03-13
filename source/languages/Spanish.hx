package languages;

/**
 * Español (Spanish)
 */
class Spanish implements ILanguage
{
    public var langName:String = 'Español';
    public var alphabetPath:Null<String> = null;
	
	public function new() {}

    public var phrases:Map<String, String> = [
        "play_on_a_friday_night"            => "Juega un Viernes... por la Noche.",
        "freeplay"                          => "Juego Libre",
        "story_mode"                        => "Modo Historia",
        "options"                           => "Opciones",
        "credits"                           => "Créditos",
        "exit_to_menu"                      => "Volver al Menú",
        "back"                              => "Atrás",
        "confirm"                           => "Confirmar",

        "search"                            => "Buscar",
        "no_songs_found"                    => "No se encontraron canciones.",
        "personal_best"                     => "Tu Mejor Puntuación",
        "not_played"                        => "No Jugado",

        "resume"                            => "Continuar",
        "restart_song"                      => "Reiniciar Canción",
        "botplay"                           => "Modo Bot",

        "easy"                              => "Fácil",
        "normal"                            => "Normal",
        "hard"                              => "Difícil",

        "touchpad_dpadmode_missing"         => "El touchPad dpadMode \"{1}\" no existe.",
        "touchpad_actionmode_missing"       => "El touchPad actionMode \"{1}\" no existe.",
    ];

    public var imageOverrides:Map<String, String> = [
        "bad"                               => "languages/images/spanish/malo",
        "good"                              => "languages/images/spanish/bien",
        "sick"                              => "languages/images/spanish/increible",
        "shit"                              => "languages/images/spanish/pésimo",
        "titleEnter"                        => "languages/images/spanish/titleEnter",
    ];
}
