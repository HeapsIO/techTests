
class DomkitEditor extends hxd.App {

	override function init() {
		var style = new h2d.domkit.Style();
		style.load(hxd.Res.style);
		style.allowInspect = true;
		var viewer = new hrt.impl.DomkitViewer(style, hxd.Res.comp.window, s2d);
		viewer.addVariables(hxd.Res.vars);
		viewer.addComponentsPath("comp");
	}

	static function main() {
		hxd.res.Resource.LIVE_UPDATE = true;
		hxd.Res.initLocal();
		new DomkitEditor();
	}

}
