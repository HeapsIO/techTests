
class TestInput extends hxd.App {

	override function init() {

		var f = new h2d.Flow(s2d);
		f.x = 20;
		f.y = 30;
		f.maxWidth = f.minWidth = 500;
		f.maxHeight = f.minHeight = 200;
		f.backgroundTile = h2d.Tile.fromColor(0x202020);
		f.verticalAlign = Top;
		f.layout = Vertical;
		f.verticalSpacing = 5;
		f.overflow = Scroll;


		var f2 = new h2d.Flow(f);
		f2.backgroundTile = h2d.Tile.fromColor(0x303030);
		f2.padding = 5;
		f2.fillWidth = true;

		var t = new h2d.TextInput(hxd.res.DefaultFont.get(), f2);
		t.text = "Test\nMultiline\nOk";
		for( i in 0...20 )
			t.text += "\nLine#"+i+" zekaaz k oeazezaok eza,ezaeoaz ".substr(Std.random(10),Std.random(10));
		t.multiline = true;
	}


	static function main() {
		new TestInput();
	}

}
