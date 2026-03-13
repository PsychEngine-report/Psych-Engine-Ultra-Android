package options;

class LanguageSubState extends MusicBeatSubstate
{
    #if TRANSLATIONS_ALLOWED

    // ── Veri ────────────────────────────────────────────────────
    var langKeys:Array<String>   = [];  // ["english", "turkish", ...]
    var curSelected:Int          = 0;
    var changedLanguage:Bool     = false;

    // ── UI ──────────────────────────────────────────────────────
    var bg:FlxSprite;
    var darkOverlay:FlxSprite;

    // Sol: dil listesi
    var listGroup:FlxTypedGroup<FlxSpriteGroup> = new FlxTypedGroup<FlxSpriteGroup>();
    var listItems:Array<LanguageListItem>        = [];

    // Sağ: büyük flag / dil görseli
    var previewBG:FlxSprite;
    var previewFlag:FlxSprite;
    var previewName:FlxText;
    var previewShadow:FlxText;

    // Seçili item için parlama efekti
    var selectGlow:FlxSprite;

    // Scroll limitleri
    static final ITEM_HEIGHT:Float  = 90;
    static final VISIBLE_ITEMS:Int  = 6;
    static final LIST_X:Float       = 60;
    static final LIST_Y_START:Float = 130;
    static final PREVIEW_X:Float    = 680;

    public function new()
    {
        super();

        Language.registerLanguages();

        // Dil listesini doldur
        for (key in Language.registeredLanguages.keys())
            langKeys.push(key);

        langKeys.sort(function(a, b) {
            var na = Language.getLangDisplayName(a).toLowerCase();
            var nb = Language.getLangDisplayName(b).toLowerCase();
            if (na < nb) return -1; else if (na > nb) return 1; return 0;
        });

        // Mevcut dili bul
        curSelected = langKeys.indexOf(ClientPrefs.data.language.toLowerCase());
        if (curSelected < 0) curSelected = 0;

        buildUI();
        updateList();
        updatePreview(false);
    }

    // ── UI İnşa ─────────────────────────────────────────────────

    function buildUI():Void
    {
        // Arka plan
        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.color    = 0xFF1a1a2e;
        bg.alpha    = 1.0;
        bg.antialiasing = ClientPrefs.data.antialiasing;
        bg.screenCenter();
        add(bg);

        darkOverlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xCC000000);
        darkOverlay.alpha = 0.7;
        add(darkOverlay);

        // Başlık
        var titleBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, 110, 0xFF16213e);
        add(titleBG);

        var titleText = new FlxText(0, 0, FlxG.width, Language.getPhrase('language_select', 'Select Language'));
        titleText.setFormat(null, 36, FlxColor.WHITE, CENTER, OUTLINE);
        titleText.borderColor = 0xFF0f3460;
        titleText.borderSize  = 3;
        titleText.screenCenter(Y);
        titleText.y = 28;
        add(titleText);

        // Sağ panel: preview alanı
        var panelX:Float = PREVIEW_X - 20;
        var previewPanel = new FlxSprite(panelX, 110).makeGraphic(
            Std.int(FlxG.width - panelX),
            Std.int(FlxG.height - 110),
            0xFF0f3460
        );
        previewPanel.alpha = 0.6;
        add(previewPanel);

        // Seçili item parlama efekti (sol liste için)
        selectGlow = new FlxSprite(LIST_X - 10, 0).makeGraphic(
            Std.int(PREVIEW_X - LIST_X - 10),
            Std.int(ITEM_HEIGHT - 8),
            0xFF533483
        );
        selectGlow.alpha = 0.5;
        add(selectGlow);

        // List grup
        add(listGroup);

        // Liste itemlerini oluştur
        for (i in 0...langKeys.length)
        {
            var key:String  = langKeys[i];
            var item = new LanguageListItem(
                LIST_X,
                LIST_Y_START + i * ITEM_HEIGHT,
                key,
                Language.getLangDisplayName(key)
            );
            listItems.push(item);
            listGroup.add(item);
        }

        // Sağ: flag preview
        previewFlag = new FlxSprite(PREVIEW_X + 20, 160);
        previewFlag.antialiasing = ClientPrefs.data.antialiasing;
        add(previewFlag);

        // Dil adı gölgesi + metni
        previewShadow = new FlxText(PREVIEW_X + 2, FlxG.height - 102, FlxG.width - PREVIEW_X, '');
        previewShadow.setFormat(null, 32, 0xFF000000, CENTER);
        add(previewShadow);

        previewName = new FlxText(PREVIEW_X, FlxG.height - 104, FlxG.width - PREVIEW_X, '');
        previewName.setFormat(null, 32, FlxColor.WHITE, CENTER);
        add(previewName);

        // Sol kenar çizgisi (dekoratif)
        var divider = new FlxSprite(PREVIEW_X - 2, 110).makeGraphic(3, Std.int(FlxG.height - 110), 0xFF533483);
        add(divider);

        // Hint text
        var hint = new FlxText(0, FlxG.height - 36, FlxG.width, '');
        #if mobile
        var hintStr = Language.getPhrase('lang_hint_mobile', 'Tap to select   Back to cancel');
        #else
        var hintStr = Language.getPhrase('lang_hint', 'ENTER: Select   ESC: Back   ↑↓: Navigate');
        #end
        hint.text = hintStr;
        hint.setFormat(null, 18, 0xFFaaaaaa, CENTER);
        add(hint);
    }

    // ── Preview Güncelle ────────────────────────────────────────

    function updatePreview(animate:Bool = true):Void
    {
        var key:String = langKeys[curSelected];
        var displayName:String = Language.getLangDisplayName(key);

        // Flag image yükle
        var flagPath:String = 'ultra/images/language/$key';
		try {
			previewFlag.loadGraphic(Paths.image(flagPath));
		} catch(e) {
			previewFlag.makeGraphic(300, 200, 0xFF533483);
		}

        // Boyut & pozisyon ayarla
        var maxW:Float = FlxG.width - PREVIEW_X - 40;
        var maxH:Float = FlxG.height - 230;
        var scaleW:Float = maxW / previewFlag.frameWidth;
        var scaleH:Float = maxH / previewFlag.frameHeight;
        var scale:Float  = Math.min(scaleW, scaleH);
        previewFlag.setGraphicSize(
            Std.int(previewFlag.frameWidth  * scale),
            Std.int(previewFlag.frameHeight * scale)
        );
        previewFlag.updateHitbox();
        previewFlag.x = PREVIEW_X + 20 + (maxW - previewFlag.width)  * 0.5;
        previewFlag.y = 160         + (maxH - previewFlag.height) * 0.5;

        previewName.text   = displayName;
        previewShadow.text = displayName;

        if (animate)
        {
            previewFlag.alpha = 0;
            FlxTween.tween(previewFlag, {alpha: 1}, 0.25, {ease: FlxEase.quadOut});
        }
        else
        {
            previewFlag.alpha = 1;
        }
    }

    // ── Liste Güncelle ──────────────────────────────────────────

    function updateList():Void
    {
        // Scroll hesapla: seçili item ortada görünsün
        var scrollOffset:Float = curSelected * ITEM_HEIGHT
            - (VISIBLE_ITEMS / 2) * ITEM_HEIGHT
            + ITEM_HEIGHT * 0.5;
        scrollOffset = Math.max(0, Math.min(scrollOffset, (langKeys.length - VISIBLE_ITEMS) * ITEM_HEIGHT));

        for (i in 0...listItems.length)
        {
            var item = listItems[i];
            var targetY:Float = LIST_Y_START + i * ITEM_HEIGHT - scrollOffset;

            FlxTween.tween(item, {y: targetY}, 0.18, {ease: FlxEase.quadOut});

            var isSelected:Bool = (i == curSelected);
            item.setSelected(isSelected);

            // Görünürlük (ekran dışındakileri gizle)
            item.visible = (targetY > 100 && targetY < FlxG.height - 40);
        }

        // Glow'u seçili item'ın yanına taşı
        var selectedItem = listItems[curSelected];
        FlxTween.tween(selectGlow, {y: selectedItem.y + 4}, 0.18, {ease: FlxEase.quadOut});
    }

    // ── Update ──────────────────────────────────────────────────

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        var mult:Int = FlxG.keys.pressed.SHIFT ? 4 : 1;

        if (controls.UI_UP_P)   changeSelected(-1 * mult);
        if (controls.UI_DOWN_P) changeSelected(1  * mult);
        if (FlxG.mouse.wheel != 0) changeSelected(-FlxG.mouse.wheel);

        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound('cancelMenu'));
            if (changedLanguage)
            {
                FlxTransitionableState.skipNextTransIn  = true;
                FlxTransitionableState.skipNextTransOut = true;
                MusicBeatState.resetState();
            }
            else close();
        }

        if (controls.ACCEPT) confirmSelection();
    }

    function changeSelected(change:Int = 0):Void
    {
        if (langKeys.length == 0) return;
        curSelected = FlxMath.wrap(curSelected + change, 0, langKeys.length - 1);
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);
        updateList();
        updatePreview(true);
    }

    function confirmSelection():Void
    {
        var key:String = langKeys[curSelected];
        FlxG.sound.play(Paths.sound('confirmMenu'), 0.6);

        // Seçilen item'da flash efekti
        var item = listItems[curSelected];
        FlxTween.tween(item, {alpha: 0.3}, 0.08, {
            onComplete: _ -> FlxTween.tween(item, {alpha: 1}, 0.15)
        });

        ClientPrefs.data.language = key;
        ClientPrefs.saveSettings();
        Language.reloadPhrases();
        changedLanguage = true;
    }

    #end // TRANSLATIONS_ALLOWED
}

// ── Yardımcı Sınıf: Liste İtemi ─────────────────────────────────

#if TRANSLATIONS_ALLOWED
class LanguageListItem extends FlxSpriteGroup
{
    var bg:FlxSprite;
    var icon:FlxSprite;
    var label:FlxText;

    public var langKey:String;

    static final W:Int = 580;
    static final H:Int = 82;

    public function new(x:Float, y:Float, key:String, displayName:String)
    {
        super(x, y);
        langKey = key;

        // Arka plan
        bg = new FlxSprite().makeGraphic(W, H, 0xFF16213e);
        bg.alpha = 0.85;
        add(bg);

        // Küçük ikon (varsa)
        icon = new FlxSprite(12, (H - 56) * 0.5);
        var iconPath:String = 'ultra/images/language/${key}_icon';
		try {
			icon.loadGraphic(Paths.image(iconPath));
			icon.setGraphicSize(56, 56);
			icon.updateHitbox();
		} catch(e) {
			icon.makeGraphic(56, 56, 0xFF533483);
		}
        icon.antialiasing = ClientPrefs.data.antialiasing;
        add(icon);

        // Dil adı
        label = new FlxText(80, 0, W - 90, displayName);
        label.setFormat(null, 26, FlxColor.WHITE, LEFT, OUTLINE);
        label.borderColor = 0xFF000000;
        label.borderSize  = 1.5;
        label.y = (H - label.height) * 0.5;
        add(label);
    }

    public function setSelected(selected:Bool):Void
    {
        if (selected)
        {
            bg.color  = 0xFF533483;
            bg.alpha  = 1.0;
            label.color = FlxColor.WHITE;
            label.size  = 28;
        }
        else
        {
            bg.color  = 0xFF16213e;
            bg.alpha  = 0.75;
            label.color = 0xFFaaaacc;
            label.size  = 26;
        }
        label.y = (H - label.height) * 0.5;
    }
}
#end
