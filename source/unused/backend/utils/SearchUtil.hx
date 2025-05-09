import EReg;
using StringTools;

class SearchUtil {
	//正则表达式真好玩😋
	private static final urlEReg = new EReg("https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)", "i");

	/**
	 * 对于`str`中的信息进行网址格式检索并返回其`str`中对应网址的位置信息
	 * @param str						  检索目标
	 * @param directionPos	  指定返回值的信息表达方式，若为`true`将返回附有`start`和`end`匿名结构数组，否则为`index`和`length`（本质是为了方便使用`String`中的`substr`以及`substring`）
	 * @return 							  在没啥问题出现的情况下，通常会返回一个数组，其中包含了检索目标的网址位置信息
	 */
	public static function searchURLInformation(str:String, directionPos:Bool = false) {
		var substr = str;

		final array:Dynamic = [];

		var i:Int = 0;
		while(urlEReg.match(substr)) {
			final match = urlEReg.matched(0);
			if(!directionPos) {
				if(i > 0) i = array.push({index: str.indexOf(match, array[i - 1].index + array[i - 1].length), length: match.length});
				else i = array.push({index: str.indexOf(match), length: match.length});
			}else {
				if(i > 0) i = array.push({start: str.indexOf(match, array[i - 1].end), end: str.indexOf(match, array[i - 1].end) + match.length});
				else i = array.push({start: str.indexOf(match), end: str.indexOf(match) + match.length});
			}
			substr = urlEReg.matchedRight();
		}

		return array;
	}

}