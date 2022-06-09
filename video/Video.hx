class Video extends hxd.App {
	var video : h2d.Video;

	override function init() {
		hxd.Res.initEmbed();

		video = new h2d.Video(s2d, 0);
		#if hl
		//video.loadResource(hxd.Res.splash_screen);
		video.loadResource(hxd.Res.splash_screen);
		#elseif js
		video.loadFile("res/splash_screen.mkv");
		#end
		//video.loop = true;

		hxd.Window.getInstance().addEventTarget(function(e) {
			switch(e.kind) {
				case EKeyDown:
					if(e.keyCode == hxd.Key.SPACE) {
						video.playing = !video.playing;
					}
				default:
			}
		});

	}

	override function update( dt : Float ) {
		if(video == null || video.playing)
			return;
		trace("Vidéo terminé");
		video.dispose();
		video = null;
	}

    static function main() {
		var v = new Video();
    }
}