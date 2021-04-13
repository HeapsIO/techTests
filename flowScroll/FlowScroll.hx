
class FlowScroll extends hxd.App {

	override function init() {

		var mask = new h2d.Mask(300,100, s2d);
		new h2d.Bitmap(h2d.Tile.fromColor(0x004040, mask.width, mask.height), mask);
		mask.x = 50;
		mask.y = 40;

		var f = new h2d.Flow(mask);
		f.x = 20;
		f.y = -50;

		f.backgroundTile = h2d.Tile.fromColor(0x202020);
		f.maxHeight = 200;
		f.overflow = Scroll;

		var content = new h2d.Flow(f);
		content.layout = Vertical;
		content.verticalSpacing = 5;
		content.padding = 12;
		content.paddingRight = 40;

		for( i in 0...20 ) {
			var c = new h3d.Vector(Math.random(), Math.random(), Math.random()).normalized();
			var b = new h2d.Bitmap(h2d.Tile.fromColor(c.toColor(),80,30), content);
			var int = new h2d.Interactive(b.tile.width, b.tile.height, b);
			int.cursor = Button;
			int.onOver = function(_) b.alpha = 0.5;
			int.onOut = function(_) b.alpha = 1;
		}
	}

	static function main() {
		new FlowScroll();
	}

}
