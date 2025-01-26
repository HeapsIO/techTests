import hrt.impl.DomkitViewer;

class Base extends h2d.Flow implements h2d.domkit.Object {
}

/*
@:source("comp/button")
class Button extends Base {
	public function new(text:String,?parent) {
		super(parent);
		initComponent();
	}
}

@:source("comp/window")
class Window extends Base {

	public var show = true;

}

@:source("comp/window2.special") class Special extends Base {

	public function new(title:String,?parent) {
		super(parent);
		initComponent();
	}

}

@:source("comp/window2")
class Window2 extends Window {

	public var text = "NewWindow2";
}
*/

class DomkitEditor extends hxd.App {

	var style : DomkitStyle;
	var root : h2d.Flow;

	override function init() {
		style = new DomkitStyle();
		style.loadDefaults([hxd.Res.vars]);
		style.load(hxd.Res.style);
		style.allowInspect = true;

		root = new h2d.Flow(s2d);
		root.dom = domkit.Properties.create("flow", root);
		root.fillWidth = root.fillHeight = true;
		root.layout = Stack;
		style.addObject(root);

		var viewer = new DomkitViewer(style, hxd.Res.comp.window2, s2d);
		viewer.addComponentsPath("comp");

		//new Window2(root);
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
