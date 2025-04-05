import hrt.impl.DomkitViewer;

class Base extends h2d.Flow implements h2d.domkit.Object {
}

enum GfxType {
	A;
	B;
	C( x : Float );
}

class Gfx extends Base {
	public function new(type:GfxType,?icon:Data.IconKind,?parent) {
		super(parent);
		initComponent();
		dom.addClass(type.getName().toLowerCase());
		if( icon != null ) dom.addClass(icon.toString().toLowerCase());
	}
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

typedef ApiData = { color : Int };

@:source("comp/apiTest.api-test")
class ApiTest extends Base {
	var color : Int;
	public function new( color : Int, ?parent ) {
		super(parent);
		this.color = color;
		initComponent();
	}
	public function getData() {
		return { color : color };
	}
}

class ApiSub extends Base {
	public function new( api : ApiTest, data : ApiData, ?parent ) {
		super(parent);
		initComponent();
		api.dom.initAttributes({ background : "#"+StringTools.hex(api.getData().color) });
		dom.initAttributes({ background : "#"+StringTools.hex(data.color) });
	}
}

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

		var viewer = new DomkitViewer(style, hxd.Res.comp.apiTest, s2d);
		viewer.addCDB(Data.icon);
		viewer.addComponentsPath("comp");

		//new Window2(root);
	}

	override function update(dt:Float) {
		style.sync(dt);
	}

	static function main() {
		hxd.res.Resource.LIVE_UPDATE = true;
		hxd.Res.initLocal();
		Data.load(hxd.Res.data.entry.getText());
		new DomkitEditor();
	}

}
