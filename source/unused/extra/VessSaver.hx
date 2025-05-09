import lime.system.System;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

using funkin.backend.utils.CoolUtil;
using StringTools;

/**
 * FOR SAVE SOME DATA IN CUSTOM CLASS.
 * ALSO, SIMPLE TYPE AS.
 * I LIKE EX-HSCRIPT-CUSTOM-CLASS >:]
 */
class VessSaver {
	private static final fullPath:String = System.applicationStorageDirectory + "Vess-Save-Items/";
	private static final extension:String = "sodayo";

	/**
	 * Saver's Exists. If false, it may cause partial functional paralysis
	 */
	public var exists:Bool = true;

	/**
	 * Current Data.
	 */
	public var fixedData:Dynamic;
	function get_fixedData():Dynamic {
		return this._data;
	}
	/**
	 * A Name Used To Save.
	 */
	public var name:String;
	function get_name():String {
		return _fileName;
	}
	/**
	 * Whether to loaded saved data or not
	 */
	public var loaded:Bool;
	function get_loaded() {
		return _loaded;
	}
	/**
	 * Whether to saved file or not
	 */
	public var saved:Bool;
	function get_saved() {
		return _saved;
	}

	private var _instal:PIInstal;
	private var _data:Dynamic;
	private var _inputData:Dynamic;
	private var _fileName:String;
	private var _exitToSave:Bool;
	private var _loaded:Bool = false;
	private var _saved:Bool = false;

	private var _registeredFields:Array<String>;

	private var _path:String;
	function get__path():String {
		return fullPath + _fileName + "." + extension;
	}

	/**
	 * Make A New Instance To Come True Save Data.
	 * ```haxe
	 * var item = new VessSaver(
	 * 	{
	 * 		//realize string
	 * 		sodayo: "114514",
	 * 		//realize math
	 * 		math: 1.,
	 * 		//realize array & map
	 * 		array: [],
	 * 	},
	 * "namedSave", true, false);
	 * //support directly getter & setter
	 * trace(item.sodayo); // output: 114514
	 * item.sodayo = "maybe";
	 * 
	 * item.math += 1;
	 * item.array.push("world was bad");
	 * item.trace(item.fixedData); // output: {array:[world was bas],math:2,sodayo:maybe}
	 * 
	 * //save changed data on your fileName "namedSave"
	 * item.save();
	 * ```
	 * ......
	 * @param inputData		  NEED SAVED DATA. IT CAN BE ANYONE EVEN STRUCTURE
	 * @param fileName			  SPECIFY THE NAME FOR SAVE DATA
	 * @param useCache			  IN FACT, IDK WHAT IS THIS. IN THE ABSENCE OF ANYERRORS, IT CAN BE ASSUMED THAT
	 * @param exitToSave	  WHEN THE GAME IS EXITING, WHETHER NEED TO SAVE DATA OR NOT. DEFAULT TO `false`
	 */
	public function new(inputData:Dynamic, fileName:String, ?useCache:Bool, ?exitToSave:Bool) {
		if(exitToSave == null) exitToSave = false;
		_exitToSave = exitToSave;

		_instal = new PIInstal(useCache);
		_registeredFields = [];

		if(Reflect.isObject(inputData)) {
			_inputData = Reflect.copy(inputData);
		} else {
			_inputData = inputData;
		}
		_data = inputData;
		_fileName = Path.withoutDirectory(Path.withoutExtension(fileName));

		checkLocateFiles();
		load();

		Application.current.onExit.add(onExit);
	}

	/**
	 * Clear Saved Data And Make Data Back To Origin.
	 */
	public function clear() {
		if(FileSystem.exists(this._path)) FileSystem.deleteFile(this._path);

		clearData();
		//TODO: RELOAD ORIGIN INPUT DATA.
		load();
	}

	/**
	 * Make Data Back To Origin.
	 */
	public function clearData() {
		if(exists) {
			if(Reflect.isObject(_data)) {
				_data = Reflect.copy(_inputData);
			}else {
				_data = _inputData;
			}
		}
	}

	/**
	 * For Save Data (Very Useful)
	 */
	public function save() {
		if(!exists) return;

		final content = _instal.serialize(this.fixedData);

		var saveItem = File.write(_path, false);
		saveItem.writeString(content);
		saveItem.close();

		_saved = true;
	}

	/**
	 * Load Or Reload Saved Data. Sometime, You Can Use It To Refresh Data And All Generated Field.
	 */
	public function load() {
		if(!exists) return;

		if(FileSystem.exists(this._path)) {
			var content:String;
			if((content = File.getContent(this._path)) != null && content.trim() != "") {
				var loadedData = _instal.unserialize(content);
				if(loadedData != null) {
					_data = loadedData;

					_loaded = true;
				}
			}
		}

		if(Reflect.isObject(fixedData)) {
			clearRegisteredProp();
			for(sb in Reflect.fields(fixedData)) {
				registerProp(sb);
			}
		}
	}

	private function checkLocateFiles() {
		if(!FileSystem.exists(fullPath)) {
			CoolUtil.addMissingFolders(fullPath);
			return false;
		}

		return true;
	}

	private function clearRegisteredProp() {
		if(_registeredFields.length > 0) {
			var i = -1;
			while((i++) < _registeredFields.length) {
				final name = _registeredFields[i];

				final variables = Reflect.getProperty(this, "interp").variables;
				final cachedFieldDecls = Reflect.getProperty(this, "__cachedFieldDecls");
				final cachedVarDecls = Reflect.getProperty(this, "__cachedVarDecls");
				final cachedFunctionDecls = Reflect.getProperty(this, "__cachedFunctionDecls");
				final hasField = Reflect.getProperty(this, "hasField");
				if(variables.exists(name) && hasField(name)) {
					cachedVarDecls.remove(name);
					cachedFieldDecls.remove(name);
					variables.remove(name);

					if(hasFunction("get_" + name)) {
						Reflect.getProperty(Reflect.getProperty(this, "__class"), "_accessPrivateVariables").remove("get_" + name);
						cachedFunctionDecls.remove("get_" + name);
						cachedFieldDecls.remove("get_" + name);
						variables.remove("get_" + name);
					}

					if(hasFunction("set_" + name)) {
						Reflect.getProperty(Reflect.getProperty(this, "__class"), "_accessPrivateVariables").remove("set_" + name);
						cachedFunctionDecls.remove("set_" + name);
						cachedFieldDecls.remove("set_" + name);
						variables.remove("set_" + name);
					}
				}

				_registeredFields.shift();
			}
		}
	}

	private function registerProp(name:String) {
		if(fixedData == null) return;
		if(!Reflect.isObject(fixedData)) {
			throw "saved item is not a structure!";
			return;
		}

		if(Reflect.hasField(fixedData, name)) {
			final variables = Reflect.getProperty(this, "interp").variables;
			final cachedFieldDecls = Reflect.getProperty(this, "__cachedFieldDecls");
			final cachedVarDecls = Reflect.getProperty(this, "__cachedVarDecls");
			final cachedFunctionDecls = Reflect.getProperty(this, "__cachedFunctionDecls");
			final hasField = Reflect.getProperty(this, "hasField");
			if(!variables.exists(name) && !hasField(name)) {
				if(Reflect.getProperty(this, "__allowSetGet") != true) Reflect.setProperty(this, "__allowSetGet", true);

				//Register Your AAASSSS~SSSSSSS :)
				cachedVarDecls.set(name, null);
				cachedFieldDecls.set(name, null);
				variables.set(name, Reflect.getProperty(fixedData, name));

				var pointName = name;
				Reflect.getProperty(Reflect.getProperty(this, "__class"), "_accessPrivateVariables").push("get_" + name);
				cachedFunctionDecls.set("get_" + name, null);
				cachedFieldDecls.set("get_" + name, null);
				variables.set("get_" + name, function() {
					if(_data == null || !Reflect.hasField(_data, pointName)) return null;
					return Reflect.getProperty(_data, pointName);
				});

				Reflect.getProperty(Reflect.getProperty(this, "__class"), "_accessPrivateVariables").push("set_" + name);
				cachedFunctionDecls.set("set_" + name, null);
				cachedFieldDecls.set("set_" + name, null);
				variables.set("set_" + name, function(val:Dynamic) {
					if(_data == null || !Reflect.hasField(_data, pointName)) return null;
					Reflect.setProperty(_data, pointName, val);

					return val;
				});

				_registeredFields.push(pointName);
			}
		}
	}

	private function onExit(i:Int) {
		if(this._exitToSave) {
			save();
		}
	}

	/**
	 * LETS GOTO MAKE A LARGE ORGY!
	 */
	public function destroy() {
		clear();

		exists = false;
		_loaded = false;
		_saved = false;

		_registeredFields.clear();
		_registeredFields = null;
		Application.current.onExit.remove(onExit);
		_instal.destroy();
		_instal = null;
		_inputData = null;
		_data = null;
	}
}
