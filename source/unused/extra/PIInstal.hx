import StringBuf;
import haxe.Unserializer;
import haxe.Serializer;

using funkin.backend.utils.CoolUtil;
using StringTools;

/**
 * This Is A Combination Of `Serializer` and `Unserializer` What Has Convenience And Good Repeatability. (Yeh
 * Suitable For Multiple Repeated Projects
 */
class PIInstal {
	private var _serialize:Serializer;
	private var _unserialize:Unserializer;

	private var useCache:Bool;

	/**
	 * Make A New Combination.
	 * @param useCache	 Whetever Use Cache When Serialize Or Not.
	 */
	public function new(?useCache:Bool) {
		if(useCache == null) useCache = false;
		this.useCache = useCache;

		_serialize = new Serializer();
		_serialize.useCache = useCache;
		_serialize.useEnumIndex = true;

		_unserialize = new Unserializer("");
	}

	/**
	 * Serialize Data
	 * @param data				 ALL ANY VALUE. (EXCLUDE FUNCTION	MAYBE)
	 * @return RETURN A STRING. IF MEET SOME TROUBLE, IT MAYBE RETURN A NULL VALUE.
	 */
	public function serialize(data:Dynamic):Null<String> {
		arrange(1);

		if(_serialize != null) {
			_serialize.serialize(data);
			return _serialize.toString();
		}

		return null;
	}

	/**
	 * Unserialize Content
	 * @param content			 INPUT SERIALIZER STRING
	 * @return YOU KNOW.
	 */
	public function unserialize(content:String):Dynamic {
		arrange(2);

		if(_unserialize != null) {
			_unserialize.buf = str;
			_unserialize.length = str.length;

			return _unserialize.unserialize();
		}

		return null;
	}

	private function arrange(catchStyle:Int) {
		switch(catchStyle) {
			case 1:
				if(_serialize != null) {
					_serialize.buf = new StringBuf();
					_serialize.shash.clear();
					_serialize.scount = 0;
				}
			case 2:
				if(_unserialize != null) {
					_unserialize.scache.clear();
					_unserialize.pos = 0;
					#if neko
					_unserialize.upos = 0;
					#end
				}
		}
	}

	/**
	 * YOU KNOW. BTW, I THINK IT NEED IMPLEMENTS
	 */
	public function destroy() {
		for(i in 0...2) {
			arrange(i + 1);
		}
		if(_serialize != null) {
			_serialize.cache.clear();
		}
		if(_unserialize != null) {
			_unserialize.cache.clear();
		}

		_serialize = null;
		_unserialize = null;
	}
}
