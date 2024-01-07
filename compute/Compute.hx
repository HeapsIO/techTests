class BufferView extends hxsl.Shader {

	static var SRC = {
		@param var buffer : Buffer<Vec4,1>;
		var pixelColor : Vec4;
		function fragment() {
			pixelColor *= buffer[0];
		}
	}

}

class ComputeShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.BaseMesh;
		@param var buffer : RWBuffer<Vec4,1>;
		@param var color : Vec4;
		function main() {
			setLayout(8,1,1);
			buffer[0] = color + vec4(sin(global.time), 0, 0, 0);
		}
	}
}

class Compute extends hxd.App {

	var shader : ComputeShader;

	override function init() {
		engine.backgroundColor = 0xFF200020;

		var buffer = new h3d.Buffer(1, hxd.BufferFormat.VEC4_DATA, [UniformBuffer, ReadWriteBuffer]);
		var data = new hxd.FloatBuffer();
		data.push(1);
		data.push(0);
		data.push(0.5);
		data.push(1);
		buffer.uploadFloats(data, 0, 1);

		var tex = h3d.mat.Texture.genChecker(16);
		var t = h2d.Tile.fromTexture(tex);
		t.scaleToSize(256,256);
		var bmp = new h2d.Bitmap(t, s2d);
		bmp.tileWrap = true;
		bmp.x = bmp.y = 100;
		var sh = new BufferView();
		sh.buffer = buffer;
		bmp.addShader(sh);
		bmp.blendMode = None;

		shader = new ComputeShader();
		shader.buffer = buffer;
	}

	override function render(e:h3d.Engine) {
		shader.color.set(0,1,0.5*Math.random(),1);
		s3d.renderer.computeDispatch(shader);
		super.render(e);
	}

	static function main() {
		#if hldx
		h3d.impl.DX12Driver.DEBUG = true;
		#else
		h3d.impl.GlDriver.enableComputeShaders();
		#end
		new Compute();
	}

}
