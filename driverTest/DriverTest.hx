import DriverTestShaders;

enum TestName {
	ClearBackground;
	SimpleTriangle;
	UniformParams;
	UniformParamsGlobals;
	TexturedTriangle;
	SamplingValues;
	CubeLight;
	RenderTarget;
	MRT;
	CubeTexture;
	TextureArray;
}

class DriverTest extends hxd.App {

	static var TESTS = TestName.createAll();

	var current : TestName;
	var time : Float;
	var enableMainKeys = true;

	override function init() {
		current = hxd.Save.load();
		if( current == null ) current = ClearBackground;
		haxe.Timer.delay(function() {
			if( hxd.Timer.frameCount < 2 ) {
				var prev = current;
				var forceLoop = false;
				enableMainKeys = false;
				hxd.Key.initialize();
				hxd.System.setLoop(function() {
					hxd.Timer.update();
					sevents.checkEvents();
					updateKeys();
					if( prev != current || forceLoop ) {
						prev = current;
						forceLoop = false;
						update(hxd.Timer.dt);
						var dt = hxd.Timer.dt; // fetch again in case it's been modified in update()
						if( s2d != null ) s2d.setElapsedTime(dt);
						if( s3d != null ) s3d.setElapsedTime(dt);
						engine.render(this);
						forceLoop = true;
					}
				});
			}
		},1000);
		initTest();
	}

	function addTriangle() {
		var idx = new hxd.IndexBuffer(3);
		idx.push(0);
		idx.push(1);
		idx.push(2);
		var poly = new h3d.prim.Polygon([new h3d.col.Point(0,0.5,0),new h3d.col.Point(0.7,-0.7,0),new h3d.col.Point(-0.7,-0.7,0)], idx);
		poly.normals = [new h3d.col.Point(1,1,1),new h3d.col.Point(1,0,0),new h3d.col.Point(0,1,0)];
		var mesh = new h3d.scene.Mesh(poly,s3d);
		mesh.material.shadows = false;
		return mesh;
	}

	function addCube() {
		var m = new h3d.scene.Mesh(h3d.prim.Cube.defaultUnitCube(), s3d);
		m.material.shadows = false;
		return m;
	}

	function addSphere() {
		var m = new h3d.scene.Mesh(h3d.prim.Sphere.defaultUnitSphere(), s3d);
		m.material.shadows = false;
		return m;
	}

	function addLight() {
		var l = new h3d.scene.fwd.DirLight(new h3d.Vector(1,-2,-4),s3d);
		return l;
	}

	function initPbr() {
		var render = new h3d.scene.pbr.Renderer();
		s3d.renderer = render;
		s3d.lightSystem = new h3d.scene.pbr.LightSystem();
		h3d.mat.PbrMaterialSetup.set();
		return render;
	}

	function initTest() {
		s3d.removeChildren();
		s2d.removeChildren();
		s3d.renderer = new h3d.scene.fwd.Renderer();
		s3d.lightSystem = new h3d.scene.pbr.LightSystem();
		h3d.mat.MaterialSetup.current = new h3d.mat.MaterialSetup("default");
		engine.backgroundColor = 0xFF002030;
		time = 0;
		switch( current ) {
		case ClearBackground:
			// nothing
		case SimpleTriangle:
			var mesh = addTriangle();
			mesh.material.mainPass.addShader(new SimpleShader());
		case UniformParams:
			var mesh = addTriangle();
			mesh.material.mainPass.addShader(new ParamShader());
		case UniformParamsGlobals:
			var mesh = addTriangle();
			mesh.material.mainPass.addShader(new ParamGlobalShader());
		case TexturedTriangle:
			var mesh = addTriangle();
			var tex = new TextureShader();
			tex.tex = hxd.Res.heapsLogo.toTexture();
			tex.tex.wrap = Repeat;
			mesh.material.mainPass.addShader(tex);
		case SamplingValues:
			var f = new h2d.Flow(s2d);
			f.fillWidth = f.fillHeight = true;
			f.horizontalAlign = f.verticalAlign = Middle;
			var t = h2d.Tile.fromTexture(h3d.mat.Texture.genChecker(16));
			var b1 = new h2d.Bitmap(t, f);
			var b2 = new h2d.Bitmap(t, f);
			b1.smooth = true;
			b2.smooth = false;
			b1.scale(6);
			b2.scale(6);
		case CubeLight:
			addLight();
			addCube();
		case RenderTarget:
			var b = new h2d.Bitmap(hxd.Res.heapsLogo.toTile(), s2d);
			b.x = b.y = 100;
			var m = new h3d.Matrix();
			m.identity();
			m.colorSaturate(-0.7);
			b.filter = new h2d.filter.ColorMatrix(m);
		case MRT:
			s3d.renderer = new MRTRenderer();
			addLight();
			addCube();
			var bmp = new h2d.Bitmap(h2d.Tile.fromColor(0xFF00FF,100,100), s2d);
		case CubeTexture:
			var m = addSphere();
			addLight();
			var c = new h3d.mat.Texture(1,1,[Cube]);
			for( i => v in [0xFF0000,0xFF00,0xFF,0xFF00FF,0xFFFF,0xFFFF00] ) {
				var p = hxd.Pixels.alloc(1,1,RGBA);
				p.setPixel(0,0,v);
				c.uploadPixels(p,0,i);
			}
			m.material.mainPass.addShader(new CubeTextureMap(c));
		case TextureArray:
			var m = addSphere();
			addLight();
			var c = new h3d.mat.TextureArray(1,1,4,[Target]);
			for( i => v in [0xFFFFFF, 0xFF0000,0xFF00,0xFF] ) {
				haxe.Timer.delay(function() {
					// fallback if clear doesn't work and to test if manual upload is supported
					var p = hxd.Pixels.alloc(1,1,RGBA);
					p.setPixel(0,0,(v&0x7F7F7F)|0xFF000000);
					c.uploadPixels(p,0,i);
				},1000);
				engine.driver.setRenderTarget(c, i);
				engine.driver.clear(h3d.Vector.fromColor(v|0xFF000000));
			}
			engine.driver.setRenderTarget(null);
			m.material.mainPass.addShader(new ArrayTextureMap(c));
		}
	}

	override function update(dt:Float) {
		time += dt;
		switch( current ) {
		case ClearBackground:
			engine.backgroundColor = Std.int((Math.cos(time * 5) + 1) * 127) | 0xFF000000;
		case UniformParams:
			var p = s3d.getMaterials()[0].mainPass.getShader(ParamShader);
			p.value.set(Math.cos(time),Math.sin(time),time%1.0);
			p.useNormal = !p.useNormal;
		case UniformParamsGlobals:
			var p = s3d.getMaterials()[0].mainPass.getShader(ParamGlobalShader);
			p.value.set(Math.cos(time),Math.sin(time),time%1.0);
		case MRT:
			var t = @:privateAccess s3d.renderer.ctx.textures.getNamed(Std.int(time*2)%2 == 0 ? "normal" : "albedo");
			if( t != null )
				cast(s2d.getChildAt(0),h2d.Bitmap).tile = h2d.Tile.fromTexture(t);
		case CubeTexture, TextureArray:
			s3d.getChildAt(0).rotate(0,0,dt);
		default:
		}
		if( enableMainKeys )
			updateKeys();
	}

	function updateKeys() {
		if( hxd.Key.isPressed(hxd.Key.ESCAPE) ) {
			current = TESTS[0];
			hxd.Save.save(current);
			initTest();
		}
		if( hxd.Key.isPressed(hxd.Key.PGUP) && current.getIndex() > 0 ) {
			current = TESTS[current.getIndex() - 1];
			hxd.Save.save(current);
			initTest();
		}
		if( hxd.Key.isPressed(hxd.Key.PGDOWN) && current.getIndex() + 1 < TESTS.length ) {
			current = TESTS[current.getIndex() + 1];
			hxd.Save.save(current);
			initTest();
		}
	}

	static function main() {
		#if hl
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end
		new DriverTest();
	}

}

class MRTRenderer extends h3d.scene.fwd.Renderer {

	var output = new h3d.pass.Output("default",[
		Value("pixelColor"),
		Vec4([Value("transformedNormal"),Const(1)])
	]);

	override function render() {
		var albedo = allocTarget("albedo", true, 1.);
		var normal = allocTarget("normal", true, 1.);
		setTargets([albedo,normal]);
		clear(0, 1, 0);
		output.setContext(ctx);
		renderPass(output,get("default"));
		resetTarget();
	}

}