import funkin.backend.assets.ModsFolder;
import funkin.backend.utils.XMLUtil;
import funkin.backend.utils.CoolUtil;
import funkin.editors.character.CharacterAnimScreen;
import funkin.editors.ui.UIState;
import funkin.editors.ui.UIText;
import funkin.editors.ui.UIButton;
import funkin.editors.ui.UITextBox;
import funkin.editors.ui.UINumericStepper;
import funkin.editors.ui.UICheckbox;
import funkin.editors.ui.UIColorwheel;
import funkin.editors.ui.UIButtonList;
import funkin.editors.ui.UIWarningSubstate;
import funkin.game.Character;

import haxe.xml.Printer;
import haxe.io.Path;

import lime.ui.FileDialog;
import lime.ui.FileDialogType;

import openfl.utils.Assets;

import sys.io.File;
import sys.FileSystem;

import CharacterAnimInfoButton; //Custom class

import Xml;
import Std;

public var spriteTextBox:UITextBox;
public var iconTextBox:UITextBox;
public var iconSprite:FlxSprite;
public var gameOverCharTextBox:UITextBox;
public var antialiasingCheckbox:UICheckbox;
public var flipXCheckbox:UICheckbox;
public var iconColorWheel:UIColorwheel;
public var positionXStepper:UINumericStepper;
public var positionYStepper:UINumericStepper;
public var cameraXStepper:UINumericStepper;
public var cameraYStepper:UINumericStepper;
public var scaleStepper:UINumericStepper;
public var singTimeStepper:UINumericStepper;
public var animationsButtonList:UIButtonList<CharacterAnimInfoButton>;
public var isPlayerCheckbox:UICheckbox;
public var isGFCheckbox:UICheckbox;
public var scriptExtension:UITextBox;
public var isShortLived:UICheckbox;
public var loadBefore:UICheckbox;

public var saveButton:UIButton;
public var closeButton:UIButton;

public var onSave:(xml:Xml) -> Void = null;

var chooseTypeGroup:FlxGroup = new FlxGroup();
var mainPage:FlxGroup = new FlxGroup();

var opponentTemplate:String = 
'<character isPlayer="false" flipX="false" holdTime="4" color="#AF66CE">
	<anim name="idle"      anim="Dad idle dance"      fps="24" loop="false" x="0" y="0"/>
	<anim name="singUP"    anim="Dad Sing note UP"    fps="24" loop="false" x="-6" y="50"/>
	<anim name="singLEFT"  anim="dad sing note right"  fps="24" loop="false" x="-10" y="10"/>
	<anim name="singRIGHT" anim="Dad Sing Note LEFT" fps="24" loop="false" x="0" y="27"/>
	<anim name="singDOWN"  anim="Dad Sing Note DOWN"  fps="24" loop="false" x="0" y="-30"/>
</character>';
var playerTemplate:String = 
'<character y="350" sprite="bf" flipX="true" isPlayer="true" icon="bf" color="#31B0D1">
	<anim name="idle" anim="BF idle dance" x="-5" y="0" fps="24" loop="false"/>
	<anim name="singUP" anim="BF NOTE UP0" x="-39" y="27" fps="24" loop="false"/>
	<anim name="singLEFT" anim="BF NOTE LEFT0" x="6" y="-7" fps="24" loop="false"/>
	<anim name="singRIGHT" anim="BF NOTE RIGHT0" x="-48" y="-6" fps="24" loop="false"/>
	<anim name="singDOWN" anim="BF NOTE DOWN0" x="-17" y="-50" fps="24" loop="false"/>
	<anim name="singUPmiss" anim="BF NOTE UP MISS" x="-35" y="27" fps="24" loop="false"/>
	<anim name="singLEFTmiss" anim="BF NOTE LEFT MISS" x="6" y="19" fps="24" loop="false"/>
	<anim name="singRIGHTmiss" anim="BF NOTE RIGHT MISS" x="-44" y="22" fps="24" loop="false"/>
	<anim name="singDOWNmiss" anim="BF NOTE DOWN MISS" x="-16" y="-19" fps="24" loop="false"/>
</character>';

var charType:Int = 0; // 0 = opponent, 1 = player
var playerButton:UIButton;
var opponentButton:UIButton;
var chooseDesc:UIText;

var curData = {
    anim: []
};

function create() {
    winTitle = "Creating Character";
	winWidth = 1014;
	winHeight = 600;
}

function postCreate() {
    add(mainPage);
    mainPage.visible = false;
    add(chooseTypeGroup);

    playerButton = new UIButton(windowSpr.x + 320, windowSpr.y + 320, 'Player', function() {
        charType = 1;
        playerButton.canBeHovered = playerButton.selectable = false;
        opponentButton.canBeHovered = opponentButton.selectable = false;
        chooseTypeGroup.visible = false;
        initialize();
        mainPage.visible = true;
    }, 160);

    opponentButton = new UIButton(playerButton.x + playerButton.bWidth + 30, windowSpr.y + 320, 'Opponent/Extra', function() {
        charType = 0;
        playerButton.canBeHovered = playerButton.selectable = false;
        opponentButton.canBeHovered = opponentButton.selectable = false;
        chooseTypeGroup.visible = false;
        initialize();
        mainPage.visible = true;
    }, 160);

    chooseDesc = new UIText(playerButton.x - 28, playerButton.y - 70, 0, 'Choose the new character type:', 24);

    chooseTypeGroup.add(playerButton);
    chooseTypeGroup.add(opponentButton);
    chooseTypeGroup.add(chooseDesc);
}

function initialize() {
    function addLabelOn(ui, text:String)
		mainPage.add(new UIText(ui.x, ui.y - 24, 0, text));

    var title:UIText;
    mainPage.add(title = new UIText(windowSpr.x + 20, windowSpr.y + 30 + 16, 0, "Sprite Data", 28));

    spriteTextBox = new UITextBox(title.x, title.y + title.height + 38, 'sprite', 200);
    spriteTextBox.onChange = (sprite:String) -> {checkSpriteFile(sprite);}
    mainPage.add(spriteTextBox);
    addLabelOn(spriteTextBox, "Sprite");

    iconTextBox = new UITextBox(spriteTextBox.x + 200 + 26, spriteTextBox.y, 'sprite-icon', 150);
    iconTextBox.onChange = (newIcon:String) -> {updateIcon(newIcon);}
    mainPage.add(iconTextBox);
    addLabelOn(iconTextBox, "Icon");

    updateIcon('face');

    gameOverCharTextBox = new UITextBox(iconTextBox.x + 150 + (75 + 12), iconTextBox.y, "bf-dead", 200);
    gameOverCharTextBox.onChange = (sprite:String) -> {checkSpriteFile(sprite);}
    mainPage.add(gameOverCharTextBox);
    addLabelOn(gameOverCharTextBox, "Game Over Character");

    antialiasingCheckbox = new UICheckbox(spriteTextBox.x, spriteTextBox.y + 10 + 32 + 28, "Antialiasing", true);
    mainPage.add(antialiasingCheckbox);
    addLabelOn(antialiasingCheckbox, "Antialiased");

    flipXCheckbox = new UICheckbox(antialiasingCheckbox.x + 172, spriteTextBox.y + 10 + 32 + 28, "FlipX", charType == 1 ? true : false);
    mainPage.add(flipXCheckbox);
    addLabelOn(flipXCheckbox, "Flipped");

    iconColorWheel = new UIColorwheel(gameOverCharTextBox.x + 200 + 20, gameOverCharTextBox.y, 0xFFFFFFFF);
    mainPage.add(iconColorWheel);
    addLabelOn(iconColorWheel, "Icon Color");

    mainPage.add(title = new UIText(spriteTextBox.x, spriteTextBox.y + 10 + 46 + 84, 0, "Character Data", 28));

    positionXStepper = new UINumericStepper(title.x, title.y + title.height + 36, 0, 0.001, 2, null, null, 84);
    mainPage.add(positionXStepper);
    addLabelOn(positionXStepper, "Position (X,Y)");

    mainPage.add(new UIText(positionXStepper.x + 84 - 32 + 0, positionXStepper.y + 9, 0, ",", 22));

    positionYStepper = new UINumericStepper(positionXStepper.x + 84 - 32 + 26, positionXStepper.y, 0, 0.001, 2, null, null, 84);
    mainPage.add(positionYStepper);

    cameraXStepper = new UINumericStepper(positionYStepper.x + 36 + 84 - 32, positionYStepper.y, 0, 0.001, 2, null, null, 84);
    mainPage.add(cameraXStepper);
    addLabelOn(cameraXStepper, "Camera Position (X,Y)");

    mainPage.add(new UIText(cameraXStepper.x + 84 - 32 + 0, cameraXStepper.y + 9, 0, ",", 22));

    cameraYStepper = new UINumericStepper(cameraXStepper.x + 84 - 32 + 26, cameraXStepper.y, 0, 0.001, 2, null, null, 84);
    mainPage.add(cameraYStepper);

    scaleStepper = new UINumericStepper(cameraYStepper.x + 84 - 32 + 90, cameraYStepper.y, 1, 0.001, 2, null, null, 74);
    mainPage.add(scaleStepper);
    addLabelOn(scaleStepper, "Scale");

    singTimeStepper = new UINumericStepper(scaleStepper.x + 74 - 32 + 36, scaleStepper.y, 4, 0.001, 2, null, null, 74);
    mainPage.add(singTimeStepper);
    addLabelOn(singTimeStepper, "Sing Duration (Steps)");

    animationsButtonList = new UIButtonList/*<CharacterAnimInfoButton>*/(singTimeStepper.x + singTimeStepper.width + 200, singTimeStepper.y, 290, 200, '', FlxPoint.get(280, 35), null, 5);
    animationsButtonList.frames = Paths.getFrames('editors/ui/inputbox');
    animationsButtonList.cameraSpacing = 0;
    animationsButtonList.addButton.callback = function() {
        openSubState(new CharacterAnimScreen(null, (_) -> {
            if(_ != null) addAnim(_);
        }));
    }
    
    var tempXML = Xml.parse(charType == 1 ? playerTemplate : opponentTemplate).firstElement();
    var c:Int = 0;
    for(i in tempXML.elements()) {
        var animData = XMLUtil.extractAnimFromXML(i);
        addAnim(animData, c);
        c++;
    }

    mainPage.add(animationsButtonList);
    addLabelOn(animationsButtonList, "Animations");

    isPlayerCheckbox = new UICheckbox(positionXStepper.x, positionXStepper.y + 10 + 32 + 28, "isPlayer", charType == 1 ? true : false);
    mainPage.add(isPlayerCheckbox);
    addLabelOn(isPlayerCheckbox, "Is Player");

    isGFCheckbox = new UICheckbox(isPlayerCheckbox.x + 128, positionXStepper.y + 10 + 32 + 28, "isGF", false);
    mainPage.add(isGFCheckbox);
    addLabelOn(isGFCheckbox, "Is GF");

    for (checkbox in [isPlayerCheckbox, isGFCheckbox, antialiasingCheckbox, flipXCheckbox])
        {checkbox.y += 4; checkbox.x += 6;}

    scriptExtension = new UITextBox(250, 388, "", 200);
    mainPage.add(scriptExtension);
    addLabelOn(scriptExtension, "Script Extension");

    isShortLived = new UICheckbox(scriptExtension.x, (scriptExtension.y + scriptExtension.bHeight) + 15, "isShortLived", false);
    mainPage.add(isShortLived);

    loadBefore = new UICheckbox(isShortLived.x, isShortLived.y + 30, "loadBefore", true);
    mainPage.add(loadBefore);

    saveButton = new UIButton(windowSpr.x + windowSpr.bWidth - 20, windowSpr.y + windowSpr.bHeight- 20, "Save & Close", function() {
        saveCharacterInfo();
        close();
    }, 125);
    saveButton.x -= saveButton.bWidth;
    saveButton.y -= saveButton.bHeight;

    closeButton = new UIButton(saveButton.x - 20, saveButton.y, "Close", function() {
        if (onSave != null) onSave(null);
        close();
    }, 125);
    closeButton.x -= closeButton.bWidth;
    closeButton.color = 0xFFFF0000;
    mainPage.add(closeButton);
    mainPage.add(saveButton);
}

function checkSpriteFile(sprite:String) {
    var fileExists:Bool = false;
    if(sprite != null && StringTools.trim(sprite).length > 0) {
        var spriteFile = Paths.image("characters/" + sprite); // Common spritesheet file
        var spriteAtlas = Path.withoutExtension(spriteFile) + "/Animation.json"; // Texture Atlas
        var spriteMulti = Path.withoutExtension(spriteFile) + "/1.xml"; // Multiple Spritesheets
        for(sf in [spriteFile, spriteAtlas, spriteMulti]) {
            if(Assets.exists(sf))
                fileExists = true;
        }
        if(!fileExists) {
            openSubState(new UIWarningSubstate("Missing Sprite file!", "The provided filename/folder doesn't exist or is inaccessible. Try again.", [
                {label: "Ok", color: 0xFFFF0000, onClick: function(t) {}}
            ]));
        }
    }
}

function updateIcon(icon:String) {
    if (iconSprite == null) add(iconSprite = new FlxSprite());

    var path:String = Paths.image("icons/" + icon);

    if (!Assets.exists(path)) path = Paths.image('icons/face');

    iconSprite.loadGraphic(path, true, 150, 150);
    iconSprite.animation.add(icon, [0], 0, false);
    iconSprite.antialiasing = true;
    iconSprite.animation.play(icon);

    iconSprite.scale.set(0.5, 0.5);
    iconSprite.updateHitbox();
    iconSprite.setPosition(iconTextBox.x + 150 + 8, (iconTextBox.y + 16) - (iconSprite.height/2));
}

function saveCharacterInfo() {
    var xml = Xml.createElement("character");
    // Avoids redundant default values
    if(positionXStepper.value != 0) xml.set("x", Std.string(positionXStepper.value));
    if(positionYStepper.value != 0) xml.set("y", Std.string(positionYStepper.value));
    if(gameOverCharTextBox.label.text != Character.FALLBACK_DEAD_CHARACTER) xml.set("gameOverChar", gameOverCharTextBox.label.text);
    if(cameraXStepper.value != 0) xml.set("camx", Std.string(cameraXStepper.value));
    if(cameraXStepper.value != 0) xml.set("camy", Std.string(cameraYStepper.value));
    if(singTimeStepper.value != 4) xml.set("holdTime", Std.string(singTimeStepper.value));
    if(flipXCheckbox.checked) xml.set("flipX", Std.string(flipXCheckbox.checked));
    if(scaleStepper.value != 1) xml.set("scale", Std.string(scaleStepper.value));
    if (iconColorWheel.colorChanged)
        xml.set("color", iconColorWheel.curColorString);

    xml.set("isPlayer", isPlayerCheckbox.checked ? "true" : "false");
    xml.set("icon", iconTextBox.label.text);
    xml.set("antialiasing", antialiasingCheckbox.checked ? "true" : "false");
    xml.set("sprite", spriteTextBox.label.text);

    for (anim in curData.anim)
    {
        var animXml:Xml = Xml.createElement('anim');
        animXml.set("name", anim.name);
        animXml.set("anim", anim.anim);
        animXml.set("loop", Std.string(anim.loop));
        animXml.set("fps", Std.string(anim.fps));
        var offset:FlxPoint = FlxPoint.get(anim.x, anim.y);
        animXml.set("x", Std.string(offset.x));
        animXml.set("y", Std.string(offset.y));
        offset.put();

        if (anim.indices.length > 0)
            animXml.set("indices", CoolUtil.formatNumberRange(anim.indices));
        xml.addChild(animXml);
    }

    // scriptExtension.label.text.trim() != "";
    if(StringTools.trim(scriptExtension.label.text) != "") {
        var extXml:Xml = Xml.createElement('extension');
        var _scriptFile:String = StringTools.trim(scriptExtension.label.text);
        var _scriptFolder:String = null;
        var _scriptPath:Array<String> = _scriptFile.split("/");
        if(_scriptPath.length > 1) {
            _scriptFile = _scriptPath.pop();
            _scriptFolder = _scriptPath.join("/") + "/";
        }
        extXml.set("script", _scriptFile);
        if(_scriptFolder != null) extXml.set("folder", _scriptFolder);
        if(isShortLived.checked) extXml.set("isShortLived", Std.string(isShortLived.checked));
        if(!loadBefore.checked) extXml.set("loadBefore", Std.string(loadBefore.checked));
        xml.addChild(extXml);
    }

    var data:String = "<!DOCTYPE codename-engine-character>\n" + Printer.print(xml, true);
    var fileDialog = new FileDialog();
    fileDialog.onCancel.add(function() close());
    fileDialog.onSelect.add(function(str)
    {
        CoolUtil.safeSaveFile(str, data);
        close();
        FlxG.resetState();
    });
    var fullPath = FileSystem.fullPath(Paths.xml('characters/character'));
    fileDialog.browse(FileDialogType.SAVE, "xml", fullPath);
    if (onSave != null) onSave(xml);
}

function addAnim(animData:AnimData, animID:Int = -1) {
    var newButton = new CharacterAnimInfoButton(0, 0, animData.name, FlxPoint.get(animData.x,animData.y));
    // Edit/Delete callbacks
    newButton.editButton.callback = function() {
        editAnim(newButton.anim);
    };
    newButton.deleteButton.callback = function() {
        deleteAnim(newButton.anim);
    };

    if (animID == -1){ 
        animationsButtonList.add(newButton);
        curData.anim.push(animData);
    }
    else {
        animationsButtonList.insert(newButton, animID);
        curData.anim.insert(animID, animData);
    }
}

public function editAnim(name:String) {
    var _anim:AnimData = null;
    for(anim in curData.anim) {
        if(anim.name == name) {
            _anim = anim;
            break;
        }
    }
    openSubState(new CharacterAnimScreen(_anim, (_) -> {
        if(_ != null) _edit_anim(name, _anim, _);
    }));
}

function _edit_anim(name:String, oldAnimData:AnimData, animData:AnimData) {
    var buttoner:CharacterAnimInfoButton = null;
    for (button in animationsButtonList.buttons.members)
        if (button.anim == name) buttoner = button;
    buttoner.updateInfo(animData.name);

    //Replace the old data
    var index = curData.anim.indexOf(oldAnimData);
    curData.anim[index] = animData;
}

public function deleteAnim(name:String) {
    for(button in animationsButtonList.buttons.members)
    {
        if(button.anim == name)
            animationsButtonList.remove(button);
    }
    for (anim in curData.anim)
    {
        if (anim.name == name)
        {
            curData.anim.remove(anim);
            break;
        }
    }
}
