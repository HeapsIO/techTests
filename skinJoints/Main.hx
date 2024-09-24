
class ObjectDebugger extends h3d.scene.Object {

	var follow2d: h2d.ObjectFollower = null;
	var text: h2d.Text = null;
	var sphere: h3d.scene.Sphere = null;
	var target: h3d.scene.Object = null;
	public var autoSync : Bool = false;

	public function new(name: String, color: Int, target: h3d.scene.Object, scene: h3d.scene.Scene, s2d: h2d.Scene) {
		super(scene);
		this.target = target;
		this.name = name;

		sphere = new h3d.scene.Sphere(color, 0.10, this);
		follow2d = new h2d.ObjectFollower(this, s2d);
		text = new h2d.Text(hxd.res.DefaultFont.get(), follow2d);
		text.color.setColor(color);
		text.textAlign = Center;
		//text.dropShadow = {dx: 1, dy: 1, color: 0x000000, alpha: 1.0};
		update();
	}

	public function update() {
		var m = target.getAbsPos().clone();
		this.setTransform(m);
		text.text = '$name';
	}

	override function emit(ctx:h3d.scene.RenderContext) {
		if (autoSync)
			update();
		super.emit(ctx);
	}

	override function onRemove() {
		follow2d.remove();
		super.onRemove();
	}
}

class Main extends hxd.App {

	public var updateFunctions : Array<() -> Void> = [];

	override function init() {
		super.init();
		new h3d.scene.CameraController(20.0, s3d);

		var scene = loadScene("scene.prefab");

		placeAtRoot();
		placedThenMoved();
		tPosed();
		animated();
	}

	/**
		We create the prefab, then we get the position of its bones. We expect that the "frozen" hand positions
		match the one that are updated each frame
	**/
	function placeAtRoot() {
		var constraint = hxd.Res.contraints.load().make(new h3d.scene.Object(s3d));
		var root3d = constraint.findFirstLocal3d();
		var models = root3d.findAll((f) -> Std.downcast(f, h3d.scene.Mesh));
		for (model in models) {
			if (model.currentAnimation != null) {
				model.currentAnimation.speed = 0.0;
			}
		}
		new ObjectDebugger("Place At Root", 0xFF000000, root3d, s3d, s2d).autoSync = true;

		var root : h3d.scene.Object = root3d.getObjectByName("Root");
		createDebug(root3d);
	}

	/**
		We create the prefab, we get the position of its bones, then we move it and we get the position of it's bones again
	**/
	function placedThenMoved() {
		var constraint = hxd.Res.contraints.load().make(new h3d.scene.Object(s3d));
		var root3d = constraint.findFirstLocal3d();
		var models = root3d.findAll((f) -> Std.downcast(f, h3d.scene.Mesh));
		for (model in models) {
			if (model.currentAnimation != null) {
				model.currentAnimation.speed = 0.0;
			}
		}
		root3d.setPosition(0,5,0);
		new ObjectDebugger("Placed Then Moved", 0xFF000000, root3d, s3d, s2d);

		createDebug(root3d);
		root3d.setPosition(0,5.5,0);
		createDebug(root3d);

	}

	/**
		We create the prefab and remove all animations to see what the bones looks like in the default pose
	**/
	function tPosed() {
		var constraint = hxd.Res.contraints.load().make(new h3d.scene.Object(s3d));
		var root3d = constraint.findFirstLocal3d();
		var models = root3d.findAll((f) -> Std.downcast(f, h3d.scene.Mesh));
		for (model in models) {
			model.stopAnimation(true);
		}
		root3d.setPosition(0,-5,0);
		new ObjectDebugger("TPose", 0xFF000000, root3d, s3d, s2d).autoSync = true;

		var root : h3d.scene.Object = root3d.getObjectByName("Root");
		createDebug(root3d);
	}

	/**
		We animate the prefab and update half of the debug display in the update function and the other one in the emit to see if they are properly synched
	**/
	function animated() {
		var constraint = hxd.Res.contraints.load().make(new h3d.scene.Object(s3d));
		var root3d = constraint.findFirstLocal3d();
		var models = root3d.findAll((f) -> Std.downcast(f, h3d.scene.Mesh));
		for (model in models) {
			if (model.currentAnimation != null) {
				model.currentAnimation.speed = 0.1;
			}
		}

		root3d.setPosition(5,0,0);
		new ObjectDebugger("Animated", 0xFF000000, root3d, s3d, s2d).autoSync = true;

		var root : h3d.scene.Object = root3d.getObjectByName("Root");
		createDebug(root3d, true);
	}

	function createDebug(root3d: h3d.scene.Object, runUpdate: Bool = false) {
		var root = root3d.getObjectByName("Root");
		var rootHand01 : h3d.scene.Skin.Joint = cast root.getObjectByName("Bone_Weapon_Hand01");
		var child : h3d.scene.Object = root3d.getObjectByName("Child");
		var childHand01 = child.getObjectByName("Bone_Weapon_Hand01");

		var a = new ObjectDebugger("root->hand01", 0xFFFF0000, rootHand01, s3d, s2d);
		var b = new ObjectDebugger("child->hand01", 0xFF00FF00, childHand01, s3d, s2d);

		if (runUpdate) {
			updateFunctions.push(() -> a.update());
			updateFunctions.push(() -> b.update());
		}

		new ObjectDebugger("\nupdate root->hand01", 0xFFFF00FF, rootHand01, s3d, s2d).autoSync = true;
		new ObjectDebugger("\nupdate child->hand01", 0xFF00FFFF, childHand01, s3d, s2d).autoSync = true;
	}


	override function update(dt:Float) {
		for (func in updateFunctions) {
			func();
		}
	}

	function loadScene(?path: String) {
		var res = hxd.Res.load(path);
		var sceneRoot = new h3d.scene.Object(s3d);
		var sceneData = res.toPrefab().load();
		var prefab = sceneData.make();
		s3d.addChild(prefab.shared.root3d);
		return prefab.shared.root3d;
	}

	static function main() {
		hxd.Res.initLocal();
		new Main();
	}
}