
class Test extends hxd.App {


	override function init() {
		var cache = new h3d.prim.ModelCache();
		var obj = cache.loadModel(hxd.Res.Fir).toMesh();

		var soil = new h3d.prim.Cube(1100,1100,1,true);
		soil.addNormals();
		new h3d.scene.Mesh(soil, s3d).material.color.setColor(0x103010);

		var batch = new h3d.scene.MeshBatch(cast(obj.primitive,h3d.prim.MeshPrimitive), obj.material, s3d);
		var count = 1000;
		batch.begin();
		for( i in 0...count ) {
			batch.x = hxd.Math.srand() * 500;
			batch.y = hxd.Math.srand() * 500;
			batch.emitInstance();
		}
		new h3d.scene.CameraController(500, s3d);
		var dl = new h3d.scene.pbr.DirLight(new h3d.Vector(0.5,0.5,-0.3), s3d);
		dl.shadows = new h3d.pass.DirShadowMap(dl);
		dl.shadows.mode = Dynamic;
		dl.power = 5;
	}

	static function main() {
		hxd.Res.initLocal();
		h3d.mat.PbrMaterialSetup.set();
		new Test();
	}

}
