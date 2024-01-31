
class DisplayShader extends hxsl.Shader {
	static var SRC = {
		@:import h3d.shader.Base2d;
		@param var buffer : PartialBuffer<{ modelView : Mat4, color2 : Vec4 },2>;
		function fragment() {
			pixelColor = buffer[1].color2 * buffer[1].modelView;  // result should be 0xFFA080
		}
	}
}

class PartialBuffer extends hxd.App {

	override function init() {
		engine.backgroundColor = 0xFF200020;
		var prim = h3d.prim.Cube.defaultUnitCube();
		var batch = new h3d.scene.MeshBatch(prim,s3d);
		batch.material.shadows = false;
		var cm = new h3d.shader.ColorMult();
		cm.color.setColor(0xFFFF0080);
		batch.material.mainPass.addShader(cm);
		batch.allowGpuUpdate = true;
		batch.begin();
		batch.emitInstance();
		batch.y = 0xA0 / 256;
		batch.emitInstance();
		batch.flush();


		var bmp = new h2d.Bitmap(h2d.Tile.fromColor(0xFFFFFF,128,128), s2d);
		var sh = new DisplayShader();
		sh.buffer = @:privateAccess batch.dataPasses.buffers[0];
		bmp.addShader(sh);
	}

	static function main() {
		#if (hldx && dx12)
		h3d.impl.DX12Driver.DEBUG = true;
		#elseif hlsdl
		h3d.impl.GlDriver.enableComputeShaders();
		#end
		new PartialBuffer();
	}

}
