
class DomkitEditor extends hxd.App {

	var style : h2d.domkit.Style;

	override function init() {
		style = new h2d.domkit.Style();
		style.load(hxd.Res.style);
		style.allowInspect = true;
		var viewer = new hrt.impl.DomkitViewer(style, hxd.Res.comp.button, s2d);
		viewer.addVariables(hxd.Res.vars);
		viewer.addComponentsPath("comp");
	}

	override function update(dt:Float) {
		style.sync(dt);
	}

	static function main() {
		hxd.res.Resource.LIVE_UPDATE = true;
		hxd.Res.initLocal();
		new DomkitEditor();
	}

}
