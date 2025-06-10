
class Main extends hxd.App {

	public function make(mode) {
		var f = new h2d.Flow(s2d);
		f.backgroundTile = h2d.Tile.fromColor(0x202020);
		f.padding = 10;
		f.debug = true;
		f.maxWidth = 200;

		f.layout = Vertical;
		f.verticalSpacing = 10;

		var font = hxd.res.DefaultFont.get();

		function add(text,align) {
			var t = new h2d.HtmlText(font,f);
			t.lineHeightMode = mode;
			t.text = text;
			t.imageVerticalAlign = align;
			t.loadImage = function(url) return h2d.Tile.fromColor(0xFFFFFF,10,url == "small" ? 4 : 40, 0.5);
		}

		add("Hello World", Bottom);

		for( a in ([Bottom,Top,Middle] : Array<h2d.HtmlText.ImageVerticalAlign>) ) {
			add(a.getName(), a);
			add('Hello <img src="small"/> World', a);
			add('Hello <img src=""/> World', a);
			add('Hello some long text with image <img src=""/><img src="small"/><img src=""/> to see if the lines are same height', a);
			//add('A<br/><img src=""/>.<br/>B',a);
		}
		return f;
	}

	override function init() {
		var f = make(Accurate);
		f.x = 20;
		f.y = 50;

		var f = make(TextOnly);
		f.x = 300;
		f.y = 50;
	}

	static function main() {
		new Main();
	}

}
