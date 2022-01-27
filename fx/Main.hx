import hrt.prefab.fx.FX.FXAnimation;
import hrt.prefab.fx.FX;
import hxd.Key as K;

class Main extends hxd.App {

    var event = new hxd.WaitEvent();
    override function init() {
		super.init();
		loadScene("scene.prefab");

        new h3d.scene.CameraController(20, s3d);
    }

    override function update(dt:Float) {
        super.update(dt);
        event.update(dt);
    }

    function loadScene(?path: String) {
		var res = hxd.Res.load(path);
		var sceneData = res.toPrefab().load();
		
		var sceneRoot = new h3d.scene.Object(s3d);
		var ctx = new hrt.prefab.Context();
		ctx.shared = new hrt.prefab.ContextShared();
		ctx.shared.root3d = sceneRoot;
		ctx.shared.currentPath = path;
		ctx.init();
		ctx = sceneData.make(ctx);

        var root = sceneRoot.getObjectByName("root");
        // sceneRoot.fixedPosition = true;
        var fxs = sceneRoot.findAll(o -> Std.downcast(o, FXAnimation));
		for(fx in fxs) {
            // fx.cullingDistance = 10.0;
            fx.playSpeed = 0.1;
        }

        event.waitUntil(function(f) {
            if(K.isPressed(K.C)) {
                for(f in fxs) f.culled = !f.culled;
            }
            if(K.isPressed(K.F)) {
                sceneRoot.fixedPosition = !sceneRoot.fixedPosition;
            }
            return false;
        });
	}

    static function main() {

        // initialize embeded ressources
        hxd.Res.initLocal();

        // start the application
        new Main();
    }
}