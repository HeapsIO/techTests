enum TestName {
	ClearBackground;
	SimpleTriangle;
	UniformParams;
	UniformParamsGlobals;
}

class SimpleShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.BaseMesh;
		function vertex() {
			output.position = vec4(input.position,1);
		}
		function fragment() {
			output.color = vec4(input.normal, 1);
		}
	}
}


class ParamShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.BaseMesh;

		@param var value : Vec3;
		@const var useNormal : Bool;

		function vertex() {
			output.position = vec4(input.position,1);
		}
		function fragment() {
			output.color = vec4(abs(value) + (useNormal ? input.normal * 0.1 : vec3(0)), 1);
		}
	}
}


class ParamGlobalShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.BaseMesh;
		@param var value : Vec3;
		@const var useNormal : Bool;

		function vertex() {
			output.position = vec4(input.position * (1 + vec3(cos(global.time),sin(global.time),0) * 0.1),1);
		}
		function fragment() {
			output.color = vec4(abs(value) + cos(global.time * 40) * 0.1, 1);
		}
	}
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

	function initTest() {
		s3d.removeChildren();
		s3d.renderer = new h3d.scene.fwd.Renderer();
		engine.backgroundColor = 0;
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
		new DriverTest();
	}

}