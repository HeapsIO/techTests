
class ShadowMap extends hxd.App {

	var meshes : Array<h3d.scene.Mesh> = [];
	var display : h3d.scene.Object;
	var light : h3d.scene.pbr.DirLight;
	var shadows : h3d.pass.DirShadowMap;
	var displayMap : h2d.Bitmap;
	var event = new hxd.WaitEvent();

	override function init() {
		s2d.defaultSmooth = true;

		var cube = new h3d.prim.Cube(1,1,1,true);
		cube.unindex();
		cube.addNormals();

		inline function scale(m:h3d.scene.Object,x,y,z) {
			m.scaleX = x;
			m.scaleY = y;
			m.scaleZ = z;
		}

		var rnd = new hxd.Rand(0);
		for(i in 0...50) {
			var mesh = new h3d.scene.Mesh(cube, s3d);
			scale(mesh, 4, 4, rnd.rand() * 30);
			mesh.material.color.setColor(0x102040);
			mesh.setPosition(rnd.srand() * 100, rnd.srand() * 100, mesh.scaleZ/2);
			mesh.cullingCollider = mesh.getBounds();
			meshes.push(mesh);
		}

		light = new h3d.scene.pbr.DirLight(new h3d.Vector(0.2,-0.3,-0.5), s3d);
		light.power = 3;
		light.shadows.mode = Dynamic;
		shadows = cast light.shadows;
		shadows.autoZPlanes = true;
		shadows.autoShrink = true;

		var tile = 16;
		var floor = new h3d.prim.Cube(tile - 0.05,tile - 0.05,0.1,true);
		floor.unindex();
		floor.addNormals();
		for( x in -10...10 )
			for( y in -10...10 ) {
				var floor = new h3d.scene.Mesh(floor, s3d);
				floor.x = x * tile;
				floor.y = y * tile;
				//floor.material.castShadows = false;
				floor.material.color.setColor(0x204020);
				floor.cullingCollider = floor.getBounds();
			}

		displayMap = new h2d.Bitmap(null, s2d);
		displayMap.colorKey = 0xFF0000;
		displayMap.width = 256;

		var ctrl = new h3d.scene.CameraController(30,s3d);
		event.waitUntil(function(dt) {
			@:privateAccess ctrl.targetOffset.z = 0;
			return false;
		});

		haxe.Timer.delay(drawVolumes,0);

		var txt = new h2d.Text(hxd.Res.debug_font.toFont(), s2d);
		txt.x = 300;
		event.waitUntil(function(dt) {
			txt.text = 'Draw calls: ${h3d.Engine.getCurrent().drawCalls}';
			return false;
		});
	}

	function addPoint(x,y,z) {
		var m = new h3d.scene.Mesh(h3d.prim.Sphere.defaultUnitSphere(), display);
		m.setPosition(x,y,z);
		m.material.color.setColor(0xFF0000FF);
		m.material.shadows = false;
	}

	function drawVolumes() {
		s3d.camera.update();
		if( display != null ) {
			display.remove();
			display = null;
		}
		display = new h3d.scene.Object(s3d);

		if( displayMap.tile != null )
			displayMap.tile.getTexture().dispose();
		displayMap.tile = h2d.Tile.fromTexture(shadows.getShadowTex().clone());

		var g = new h3d.scene.Graphics(display);
		g.lineStyle(1, 0xFF00FF);

		var zmin = shadows.minDist < 0 ? 0 : getCamZ(shadows.minDist);
		var zmax = shadows.maxDist < 0 ? 1 : getCamZ(shadows.maxDist);
		var f = s3d.camera.getFrustumCorners(zmax, zmin);
		inline function goto(i) {
			g.moveTo(f[i].x, f[i].y, f[i].z);
		}
		inline function line(i) {
			g.lineTo(f[i].x, f[i].y, f[i].z);
		}
		goto(0);
		line(1);
		line(2);
		line(3);
		line(0);
		line(4);
		line(5);
		line(6);
		line(7);
		line(4);
		goto(1);
		line(5);
		goto(2);
		line(6);
		goto(3);
		line(7);

		g.lineStyle(1, 0xFFFF00);
		var ld = @:privateAccess light.getShadowDirection();
		ld.scale(10);
		for( p in f ) {
			g.moveTo(p.x, p.y, p.z);
			g.lineTo(p.x + ld.x, p.y + ld.y, p.z + ld.z);
		}

		var brot = new h3d.scene.Object(display);
		var box = new h3d.scene.Box(@:privateAccess shadows.lightCamera.orthoBounds.clone(), brot);

		var g = new h3d.scene.Graphics(box);
		g.lineStyle(1.3, 0xFFFF00);
		g.lineTo(0,0,box.bounds.zMax + box.bounds.zSize);
		brot.setDirection(light.getLocalDirection());
		box.rotate(-Math.PI/2, Math.PI, -Math.PI/2); // x front to z front

		for( m in display.getMaterials() )
			m.mainPass.setPassName("overlay");
	}

	override function update(dt:Float) {
		super.update(dt);
		if( hxd.Key.isPressed(hxd.Key.SPACE) )
			drawVolumes();
		event.update(dt);
	}

	function getCamZ( dist : Float ) {
		return s3d.camera.distanceToDepth(dist);
	}

	static function main() {
		hxd.Res.initLocal();
		h3d.mat.PbrMaterialSetup.set();
		new ShadowMap();
	}

}
