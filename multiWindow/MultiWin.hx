
class MultiWin extends hxd.App {

	var color : Int;
	var bmp : h2d.Bitmap;

	public function new(color) {
		this.color = color;
		super();
	}

	override function init() {
		bmp = new h2d.Bitmap(h2d.Tile.fromColor(~color,32,32).center(), s2d);
	}

	override function update( dt : Float ) {
		engine.backgroundColor = color;
		if( bmp != null ) {
			bmp.x = s2d.mouseX;
			bmp.y = s2d.mouseY;
		}
	}

    static function main() {
		var ctx1 = new hxd.impl.AppContext(new MultiWin(0xFF));
		var ctx2 = new hxd.impl.AppContext(new MultiWin(0xFFFF));
    }

}