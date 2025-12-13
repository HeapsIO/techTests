
class Test implements hscript.Live {

	var x : Int = 33;
	var y : Int = 22;
	var arr = [];

	public function new() {
	}

	public function update() {
		trace("="+foo(x));
	}

	function foo( x : Int ) {
		return "!!"+y++;
	}

}


class LiveClass {


	static function main() {
		var t = new Test();
		haxe.EventLoop.main.add(function() {
			t.update();
			Sys.sleep(0.5);
		});
		var l : hscript.Live = t;
		trace(l);
	}

}
