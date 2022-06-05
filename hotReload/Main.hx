class Main  {

	@:hlNative("std","sys_check_reload") static function check_reload( ?altFile : hl.Bytes ) return false;

	static function foo( v : Dynamic ) {
		trace(Float);
		#if reload
		if( !Std.isOfType(v,Float) )
			throw "assert";
		trace("OK");
		#else
		if( !Std.isOfType(v,Bool) )
			throw "assert";
		#end
	}

    public static function main() {
		if( Sys.command("haxe",["-D","reload","-hl","reload.hl","-main","Main"]) != 0 )
			throw "compilation failed";
		var v : Dynamic = 4.58;
		trace(v);
		if( !check_reload(@:privateAccess "reload.hl".bytes) )
			throw "can't reload";
		foo(v);
	}


}