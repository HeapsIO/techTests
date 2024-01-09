class BufferView extends hxsl.Shader {

	static var SRC = {
		@param var buffer : Buffer<Vec4,1>;
		var pixelColor : Vec4;
		function fragment() {
			pixelColor *= buffer[0];
		}
	}

}

class ComputeBufShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.BaseMesh;
		@param var buffer : RWBuffer<Vec4,1>;
		@param var color : Vec4;
		function main() {
			buffer[0] = color + vec4(sin(global.time), 0, 0, 0);
		}
	}
}

class ComputeTexShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.BaseMesh;
		@param var tex : RWTexture2D<Vec2>;
		@param var color : Vec4;
		function main() {
			setLayout(16);
			var iuv = computeVar.globalInvocation.xy;
			tex.store(iuv, (vec2(iuv) / tex.size()) + sin(vec2(iuv) * global.time * 0.01));
		}
	}
}

class Compute extends hxd.App {

	var bufShader : ComputeBufShader;
	var texShader : ComputeTexShader;

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

		bufShader = new ComputeBufShader();
		bufShader.buffer = buffer;

		var wtex = new h3d.mat.Texture(256,256,[Writable],RG8);
		texShader = new ComputeTexShader();
		texShader.tex = wtex;

		var bmp = new h2d.Bitmap(h2d.Tile.fromTexture(wtex), s2d);
		bmp.x = 400;
		bmp.y = 100;
		bmp.blendMode = None;
	}

	override function render(e:h3d.Engine) {
		bufShader.color.set(0,1,0.5*Math.random(),1);
		s3d.renderer.computeDispatch(bufShader);

		texShader.color.set(0,1,0.5*Math.random(),1);
		s3d.renderer.computeDispatch(texShader,Std.int(texShader.tex.width * 0.75 / 16), Std.int(texShader.tex.height*0.75));

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
