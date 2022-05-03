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


class SimpleTriangle extends hxd.App {

	override function init() {
		engine.backgroundColor = 0xFF204080;
		var idx = new hxd.IndexBuffer(3);
		idx.push(0);
		idx.push(1);
		idx.push(2);
		var poly = new h3d.prim.Polygon([new h3d.col.Point(0,0.5,0),new h3d.col.Point(0.7,-0.7,0),new h3d.col.Point(-0.7,-0.7,0)], idx);
		poly.normals = [new h3d.col.Point(1,1,1),new h3d.col.Point(1,0,0),new h3d.col.Point(0,1,0)];
		var mesh = new h3d.scene.Mesh(poly,s3d);
		mesh.material.mainPass.addShader(new SimpleShader());
		mesh.material.shadows = false;
	}

	static function main() {
		new SimpleTriangle();
	}

}