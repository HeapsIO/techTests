class Main extends hxd.App {

	var sc : h2d.Scene3D;
	var obj : h3d.scene.Mesh;

	override function init() {
		sc = new h2d.Scene3D(sevents, s2d);
		sc.minWidth = 300;
		sc.minHeight = 400;
		sc.x = 50;
		sc.y = 70;
		sc.backgroundColor = 0xFF202020;


		var cube = h3d.prim.Cube.defaultUnitCube();
		obj = new h3d.scene.Mesh(cube, sc.s3d);

		if( sc.s3d.renderer is h3d.scene.pbr.Renderer )
			new h3d.scene.pbr.DirLight(new h3d.Vector(-1,2,-8).normalized(), sc.s3d);
		else
			new h3d.scene.fwd.DirLight(new h3d.Vector(-1,2,-8).normalized(), sc.s3d);

		var int3d = new h3d.scene.Interactive(h3d.col.Bounds.fromValues(-0.5,-0.5,-0.5,1,1,1),obj);
		int3d.onOver = function(_) {
			obj.material.color.setColor(0xFF80FF80);
		};
		int3d.onOut = function(_) {
			obj.material.color.setColor(-1);
		};

		var int = new h2d.Interactive(30,30,sc.s2d);
		int.backgroundColor = 0x80FF0000;
		int.onOver = function(_) {
			int.backgroundColor = 0x8000FF00;
		};
		int.onOut = function(_) {
			int.backgroundColor = 0x80FF0000;
		};
		int.x = 70;
		int.y = 10;


		var int = new h2d.Interactive(30,30,s2d);
		int.backgroundColor = 0x80FF0000;
		int.onOver = function(_) {
			int.backgroundColor = 0x8000FF00;
		};
		int.onOut = function(_) {
			int.backgroundColor = 0x80FF0000;
		};
		int.x = 150;
		int.y = 10;

	}

	override function update(dt:Float) {
		super.update(dt);
		if( hxd.Key.isPressed(hxd.Key.SPACE) )
			s2d.scaleMode = s2d.scaleMode == Resize ? Zoom(1.5) : Resize;
		if( hxd.Key.isPressed(hxd.Key.NUMBER_1) ) {
			var win = hxd.Window.getInstance();
			var mode = win.width == 800;
			win.resize(mode ? 600 : 800, mode ? 800 : 600);
		}
		if( hxd.Key.isPressed(hxd.Key.NUMBER_2) ) {
			var mode = sc.minWidth == 300;
			sc.minWidth = mode ? 400 : 300;
			sc.minHeight = mode ? 300 : 400;
		}
		if( hxd.Key.isPressed(hxd.Key.NUMBER_3) ) {
			var mode = sc.backgroundColor == 0x00FF0000;
			sc.backgroundColor = mode ? 0xFF202020 : 0x00FF0000;
		}
		if( hxd.Key.isPressed(hxd.Key.NUMBER_4) ) {
			var mode = sc.backgroundColor == null;
			sc.backgroundColor = mode ? 0x80202020 : null;
		}
		obj.rotate(0,0,dt * 0.3);
	}

    public static function main() {
		//h3d.mat.PbrMaterialSetup.set();
		new Main();
	}


}