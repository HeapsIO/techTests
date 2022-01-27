import hrt.prefab.Model;

class Test extends hxd.App {

	var tf : h2d.Text;
	var obj : h3d.scene.Object;
	var bounds : h3d.scene.Box;

	override function init() {
		var cache = new h3d.prim.ModelCache();

		obj = new h3d.scene.Object(s3d);
		for( i in 0...1 ) {
			var o = cache.loadPrefab(hxd.Res.castle1);
			o.x = hxd.Math.srand(i*0.1);
			o.y = hxd.Math.srand(i*0.1);
			o.setRotation(0, 0, hxd.Math.srand(i*0.1));
			obj.addChild(o);
		}

		var soil = new h3d.prim.Cube(100,100,1,true);
		soil.addNormals();
		var mat = new h3d.scene.Mesh(soil, s3d).material;
		mat.color.setColor(0x103010);
		mat.shadows = false;

		new h3d.scene.CameraController(50, s3d);
		var dl = new h3d.scene.pbr.DirLight(new h3d.Vector(0.5,0.5,-0.3), s3d);
		dl.shadows = new h3d.pass.DirShadowMap(dl);
		dl.shadows.mode = Dynamic;
		dl.power = 5;

		var lib = hxd.Res.modelLib.load().get(hrt.prefab.l3d.ModelLibrary);
		cache.loadPrefab(hxd.Res.modelLib);
		lib.optimize(obj);

		tf = new h2d.Text(hxd.res.DefaultFont.get(), s2d);
		tf.x = tf.y = 5;

		bounds = new h3d.scene.Box(new h3d.col.Bounds(),s3d);
		bounds.material.shadows = false;
		bounds.material.mainPass.setPassName("overlay");
		updateBounds();
	}

	function updateBounds() {
		bounds.bounds.empty();
		for( o in obj.getMeshes() ) {
			if( o.culled ) continue;
			var b = o.primitive.getBounds().clone();
			b.transform(o.getAbsPos());
			bounds.bounds.add(b);
		}
	}

	override function update(dt:Float) {
		tf.text = (engine.drawCalls-10)+" draw calls "+(engine.drawTriangles-(tf.text.length*2))+" tri "+Std.int(hxd.Timer.fps())+" fps";
		if( hxd.Key.isPressed(hxd.Key.SPACE) ) {
			for( o in obj.getMeshes() )
				o.culled = !o.culled;
			updateBounds();
		}
		if( hxd.Key.isPressed(hxd.Key.F6) ) {
			var render = cast(s3d.renderer, h3d.scene.pbr.Renderer);
			render.displayMode = render.displayMode == Pbr ? Debug : Pbr;
		}
	}

	static function main() {
		hxd.Res.initLocal();
		h3d.mat.PbrMaterialSetup.set();
		new Test();
	}

}
