class Shader extends hxsl.Shader {

	static var SRC = {

		@sampler("shared") @param var textures : Array<Sampler2D,10>;
		@param var mid : Sampler2D;
		@sampler("shared2") @param var textures2 : Array<Sampler2D,10>;

		var pixelColor : Vec4;
		var calculatedUV : Vec2;

		function fragment() {
			var sum = vec4(0.);
			@unroll for( i in 0...10 ) {
				if( i != 5 && i != 7 )
					sum += textures[i].get(calculatedUV) + textures2[i].get(calculatedUV);
			}
			pixelColor = sum * mid.get(calculatedUV);
		}

	}

}

class DxSamplers extends hxd.App {

	override function init() {

		var bmp = new h2d.Bitmap(h2d.Tile.fromColor(-1,200,200), s2d);
		var s = new Shader();
		bmp.addShader(s);

		for( i in 0...10 ) {
			if( i == 5 || i == 7 ) continue;
			s.textures[i] = h3d.mat.Texture.fromColor(0xFF200000);
			s.textures2[i] = h3d.mat.Texture.fromColor(0xFF002000);
		}
		var tex = new h3d.mat.Texture(3,3);
		var pix = hxd.Pixels.alloc(3,3,RGBA);
		pix.clear(-1);
		pix.setPixel(1,1,0xFF808000);
		tex.uploadPixels(pix);
		tex.filter = Nearest;
		s.mid = tex;

	}

	static function main() {
		new DxSamplers();
	}

}
