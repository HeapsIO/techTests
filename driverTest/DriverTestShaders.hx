
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

		function vertex() {
			output.position = vec4(input.position * (1 + vec3(cos(global.time),sin(global.time),0) * 0.1),1);
		}
		function fragment() {
			output.color = vec4(abs(value) + cos(global.time * 40) * 0.1, 1);
		}
	}
}


class TextureShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.BaseMesh;
		@param var tex : Sampler2D;

		function vertex() {
			output.position = vec4(input.position * (1 + vec3(cos(global.time),sin(global.time),0) * 0.1),1);
		}
		function fragment() {
			output.color = tex.get(input.position.xy * vec2(1.5,-1.5) + vec2(0.5,0));
		}
	}
}

class CubeTextureMap extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.BaseMesh;
		@param var tex : SamplerCube;

		function fragment() {
			output.color = tex.get(input.normal);
		}
	}

	public function new(tex) {
		super();
		this.tex = tex;
	}
}

class ArrayTextureMap extends hxsl.Shader {

	static var SRC = {
		@:import h3d.shader.BaseMesh;
		@param var tex : Sampler2DArray;

		function fragment() {
			output.color = tex.get((input.normal * 3).abs());
		}
	}

	public function new(tex) {
		super();
		this.tex = tex;
	}

}