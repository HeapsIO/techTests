
class Shader extends hxsl.Shader {

	static var SRC = {

		@param var texArray : Sampler2DArray;

		var pixelColor : Vec4;
		var calculatedUV : Vec2;

		function fragment() {
			var lod = int(calculatedUV.y * 8);
			pixelColor = texArray.getLod(vec3(calculatedUV, int((calculatedUV.x * 10) % 2.0)), lod);
		}
	}
}

class TextureArrays extends hxd.App {

	override function init() {
		engine.driver.setDebug(true);
		testSimple(0,0);
		testMipMaps(0,256);
		#if hl
		testCompressed(256, 0);
		testCompressedMipmaps(256, 256);
		#end
	}


	function testSimple(x: Int, y: Int) {
		var size = 512;

		var red = new h3d.mat.Texture(size, size, RGBA);
		red.clear(0xff0000, 1);
		var blue = new h3d.mat.Texture(size, size, RGBA);
		blue.clear(0x0000ff, 1);

		var tex = new h3d.mat.TextureArray(size, size, 2, [], RGBA);
		tex.uploadPixels(red.capturePixels(), 0, 0);
		tex.uploadPixels(blue.capturePixels(), 0, 1);

		var bmp = new h2d.Bitmap(h2d.Tile.fromTexture(red), s2d);
		bmp.width = bmp.height = 256;
		bmp.x = x; bmp.y = y;
		var s = new Shader();
		s.texArray = tex;
		bmp.addShader(s);
		return bmp;
	}

	function testCompressed(x: Int, y: Int) {
		var i1 = hxd.Res.tex1_BC1;
		var i2 = hxd.Res.tex2_BC1;
		var t1 = i1.toTexture();
		var t2 = i2.toTexture();
		if(!t1.format.equals(t2.format))
			throw "!";

		var tex = new h3d.mat.TextureArray(t1.width, t1.height, 2, [], t1.format);
		tex.uploadPixels(i1.getPixels(), 0, 0);
		tex.uploadPixels(i2.getPixels(), 0, 1);

		var bmp = new h2d.Bitmap(h2d.Tile.fromTexture(tex), s2d);
		bmp.width = bmp.height = 256;
		bmp.x = x; bmp.y = y;
		var s = new Shader();
		s.texArray = tex;
		bmp.addShader(s);
		return bmp;
	}

	function testMipMaps(x: Int, y: Int) {
		var size = 512;

		var flags : Array<h3d.mat.Data.TextureFlags> = [MipMapped, ManualMipMapGen];
		var tex = new h3d.mat.TextureArray(size, size, 2, flags, RGBA);

		var mipLevel = 0;
		while(size > 1) {
			var t = new h3d.mat.Texture(size, size, [], RGBA);
			t.clear(0x600000 + mipLevel * 20);
			tex.uploadPixels(t.capturePixels(), mipLevel, 0);
			t.clear(0x006000 + mipLevel * 20);
			tex.uploadPixels(t.capturePixels(), mipLevel, 1);
			t.dispose();
			size >>= 1;
			++mipLevel;
		}

		var bmp = new h2d.Bitmap(h2d.Tile.fromTexture(tex), s2d);
		bmp.width = bmp.height = 256;
		bmp.x = x; bmp.y = y;
		var s = new Shader();
		s.texArray = tex;
		bmp.addShader(s);
		return bmp;
	}

	function testCompressedMipmaps(x: Int, y: Int) {
		var i1 = hxd.Res.tex3_BC1_mips;
		var i2 = hxd.Res.tex4_BC1_mips;
		var t1 = i1.toTexture();
		var t2 = i2.toTexture();
		if(!t1.format.equals(t2.format))
			throw "!";

		var flags : Array<h3d.mat.Data.TextureFlags> = [MipMapped, ManualMipMapGen];
		var tex = new h3d.mat.TextureArray(t1.width, t1.height, 2, flags, t1.format);
		for(i in 0...tex.mipLevels) {
			tex.uploadPixels(i1.getPixels(tex.format, false, i), i, 0);
			tex.uploadPixels(i2.getPixels(tex.format, false, i), i, 1);
		}

		var bmp = new h2d.Bitmap(h2d.Tile.fromTexture(tex), s2d);
		bmp.width = bmp.height = 256;
		bmp.x = x; bmp.y = y;
		var s = new Shader();
		s.texArray = tex;
		bmp.addShader(s);
		return bmp;
	}

	static function main() {
		new TextureArrays();
		#if hl
		hxd.Res.initLocal();
		#else
		hxd.Res.initEmbed();
		#end
	}

}
