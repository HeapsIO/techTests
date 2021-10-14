class Button extends h2d.Bitmap
{
	var interactive:h2d.Interactive;
	public var onClick:Void->Void;
	private var title:h2d.Text;

	public function new(parent:h2d.Object, text:String, cb: Void -> Void)
	{
		var w = text.length*8 > 110 ? text.length*8: 110;
		var h = 30;

		super(h2d.Tile.fromColor(0x404040, w, h), parent);
		this.x = x;
		this.y = y;
		interactive = new h2d.Interactive(w, h, this);

		title = new h2d.Text(hxd.res.DefaultFont.get(), this);
		title.text = text;
		title.x += w/2;
		title.y += h/2-10;
		title.textAlign = Center;

		interactive.onClick = function (e) {
			if(cb != null)
				cb();
		}
	}
}

class ScreenMode extends hxd.App {
	var resList : Array<{width:Int,height:Int,framerate:Int}>;
	var framerateList : Array<Int> = [];

	public function new() {
		super();
	}

	function setDisplayMode(m:hxd.Window.DisplayMode) {
		#if (hl_ver >= version("1.12.0"))
		if(hxd.Window.getInstance().displayMode == Windowed && m != Windowed) {
			var cdm = hxd.Window.getInstance().getCurrentDisplaySetting();
			hxd.Window.getInstance().displayMode = m;
			hxd.Window.getInstance().resize(cdm.width, cdm.height);
		}
		else
			hxd.Window.getInstance().displayMode = m;
		#else
		hxd.Window.getInstance().displayMode = m;
		#end
		redraw();
	}

	#if (hl_ver >= version("1.12.0"))
	function moveToScreen(id) {
		hxd.Window.getInstance().monitor = id;
		hxd.Window.getInstance().applyDisplay();
		redraw();
	}

	function setFramerate(framerate) {
		hxd.Window.getInstance().framerate = framerate;
		hxd.Window.getInstance().applyDisplay();
		redraw();
	}
	
	function resize(width, height) {
		hxd.Window.getInstance().resize(width, height);
		hxd.Window.getInstance().applyDisplay();
		redraw();
	}

	function updateResList() {
		resList = [];
		var r = hxd.Window.getInstance().getDisplaySettings();
		r.sort((a, b) -> {
			var s = a.width - b.width;
			if(s != 0)
				return s;
			return a.height - b.height;
		});
		for(d in r) {
			if(resList.length <= 0 || resList[resList.length-1].width != d.width || resList[resList.length-1].height != d.height)
				resList.push(d);
		}
	}
	#end

	function redraw() {
		s2d.removeChildren();
		var f = new h2d.Flow(s2d);
		f.layout = Vertical;

		var f2 = new h2d.Flow(f);
		new Button(f2, "Windowed", () -> setDisplayMode(Windowed));
		new Button(f2, "Borderless", () -> setDisplayMode(Borderless));
		new Button(f2, "Fullscreen", () -> setDisplayMode(Fullscreen));

		#if (hl_ver >= version("1.12.0"))
		var f2 = new h2d.Flow(f);
		new Button(f2, 'Default screen', () -> moveToScreen(0));
		for(i => o in hxd.Window.getMonitors()) {
			var ds = hxd.Window.getInstance().getCurrentDisplaySetting(i);
			new Button(f2, '${o.name} - ${o.width}x${o.height}@${ds.framerate}' + (i == hxd.Window.getInstance().currentMonitorIndex ? " (current)" : ""), () -> moveToScreen(i));
		}

		f2 = new h2d.Flow(f);
		var cur = hxd.Window.getInstance().getCurrentDisplaySetting(hxd.Window.getInstance().currentMonitorIndex);
		if(cur != null) {
			for(m in hxd.Window.getInstance().getDisplaySettings()) {
				if(m.width == cur.width && m.height == cur.height)
					new Button(f2, m.framerate + " ips", () -> setFramerate(m.framerate));
			}
		}

		var f3 = new h2d.Flow(f);
		if(hxd.Window.getInstance().displayMode != Windowed && hxd.Window.getInstance().displayMode != Borderless) {
			var f2 = new h2d.Flow(f3);
			f2.layout = Vertical;

			updateResList();
			for(r in resList) {
				new Button(f2, '${r.width}x${r.height}', () -> resize(r.width, r.height));
			}
		}
		#end
	}

	override function init() {
		redraw();
	}

	static function main() {
		new ScreenMode();
	}
}