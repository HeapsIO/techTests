
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

class TestComp extends Base {
	static var SRC = <test-comp>
		<gfx(A)/>
		<gfx(B)/>
		<gfx(A)/>
	</test-comp>

	public function new(?parent) {
		super(parent);
		initComponent();
	}
	function get(v:GfxType) {
		return v;
	}
}

@:uiInitFunction(init)
class Root extends Base {

	static var SRC = <root>
		<test-comp/>
	</root>

	public function new(?parent) {
		super(parent);
		init();
	}

	function init() {
		initComponent();
	}

	public function rebuild() {
		removeChildren();
		init();
	}

}

class DomkitStudio extends hxd.App {

	var style : h2d.domkit.Style;
	var root : h2d.Flow;

	override function init() {

		style = new h2d.domkit.Style();
		style.loadComponents("style",[hxd.Res.style.vars]);
		style.watchInterpComponents("api.xml",["."]);
		style.allowInspect = true;

		root = new Root(s2d);
		style.addObject(root);
	}

	override function update(dt:Float) {
		style.sync(dt);
	}

	static function main() {
		hxd.res.Resource.LIVE_UPDATE = true;
		#if js
		hxd.Res.initEmbed();
		#else
		hxd.Res.initLocal();
		#end
		Data.load(hxd.Res.data.entry.getText());
		new DomkitStudio();
	}

}
