
class Main extends hxd.App {

	public var updateFunctions : Array<() -> Void> = [];
	public var checkers : Array<ObjectChecker> = [];
	public var skinCheckers : Array<SkinChecker> = [];
	var checkerDisplay : h2d.Flow;

	override function init() {
		super.init();
		new h3d.scene.CameraController(20.0, s3d);

		var scene = loadScene("scene.prefab");

		checkerDisplay = new h2d.Flow(s2d);
		checkerDisplay.backgroundTile = h2d.Tile.fromColor(0, 1,1, 0.75);
		checkerDisplay.layout = Vertical;
		checkerDisplay.padding = 4;

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
		var name = "Place At Root";
		new ObjectDebugger(name, 0xFFFFFFFF, root3d, s3d, s2d).autoSync = true;

		var root : h3d.scene.Object = root3d.getObjectByName("Root");
		createDebug(root3d, name);
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
		var name = "Placed Then Moved";
		root3d.setPosition(0,5,0);
		new ObjectDebugger(name, 0xFFFFFFFF, root3d, s3d, s2d);

		createDebug(root3d, false, null);
		root3d.setPosition(0,5.5,0);
		createDebug(root3d, name);

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
		var name = "TPose";
		new ObjectDebugger(name, 0xFFFFFFFF, root3d, s3d, s2d).autoSync = true;

		var root : h3d.scene.Object = root3d.getObjectByName("Root");
		createDebug(root3d, name);
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

		var name = "Animated";
		root3d.setPosition(5,0,0);
		new ObjectDebugger(name, 0xFFFFFFFF, root3d, s3d, s2d).autoSync = true;

		var root : h3d.scene.Object = root3d.getObjectByName("Root");
		createDebug(root3d, true, name);
	}

	function createDebug(root3d: h3d.scene.Object, runUpdate: Bool = false, checkName: String) {
		var root = root3d.getObjectByName("Root");
		var rootHand01 : h3d.scene.Skin.Joint = cast root.getObjectByName("Bone_Weapon_Hand01");
		var child : h3d.scene.Object = root3d.getObjectByName("Child");
		var childHand01 : h3d.scene.Skin.Joint = cast child.getObjectByName("Bone_Weapon_Hand01");

		var rootHand = new ObjectDebugger("root->hand01", 0xFFFF0000, rootHand01, s3d, s2d);
		var childHand = new ObjectDebugger("child->hand01", 0xFF00FF00, childHand01, s3d, s2d);

		if (runUpdate) {
			updateFunctions.push(() -> rootHand.update());
			updateFunctions.push(() -> childHand.update());
		}

		var rootHandUpdate = new ObjectDebugger("update root->hand01", 0xFFFF00FF, rootHand01, s3d, s2d, 16.0);
		rootHandUpdate.autoSync = true;
		var childHandUpdate = new ObjectDebugger("update child->hand01", 0xFF00FFFF, childHand01, s3d, s2d, 16.0);
		childHandUpdate.autoSync = true;

		if (checkName != null) {
			checkers.push(new ObjectChecker(rootHand, rootHandUpdate, '$checkName : root'));
			checkers.push(new ObjectChecker(childHand, childHandUpdate, '$checkName : child'));

			skinCheckers.push(new SkinChecker(rootHand01, '$checkName : root'));
			skinCheckers.push(new SkinChecker(childHand01, '$checkName : child'));
		}
	}


	override function update(dt:Float) {
		for (func in updateFunctions) {
			func();
		}

		checkerDisplay.removeChildren();
		for (checker in checkers) {
			var txt = new h2d.Text(hxd.res.DefaultFont.get(), checkerDisplay);
			txt.text = checker.name;

			switch([checker.isOkFirstFrame, checker.isOk, checker.isSameAsPreviousFrame]) {
				case [true, true, _]:
					txt.color.setColor(0xFF00FF00);
					txt.text +=" OK";
				case [false, true, _]:
					txt.color.setColor(0xFFFF00FF);
					txt.text +=" ERR First Frame/OK Update";
				case [true, false, false]:
					txt.color.setColor(0xFFFF00FF);
					txt.text +=" OK First Frame/ERR Update";
				case [true, false, true]:
					txt.color.setColor(0xFFFFFF00);
					txt.text +=" OK First Frame/1Frame delay Update";
				case [false, false, true]:
					txt.color.setColor(0xFFFFFF00);
					txt.text +=" ERR First Frame/1Frame delay Update";
				case [false, false, false]:
					txt.color.setColor(0xFFFF0000);
					txt.text +=" ERR";
			}
		}
		var txt = new h2d.Text(hxd.res.DefaultFont.get(), checkerDisplay);
		txt.text = "=== skin checkers ===";
		for (checker in skinCheckers) {
			var txt = new h2d.Text(hxd.res.DefaultFont.get(), checkerDisplay);
			txt.text = checker.name;

			switch([checker.isOk, checker.isSameAsPreviousFrame]) {
				case [true, _]:
					txt.color.setColor(0xFF00FF00);
					txt.text +=" OK";
				case [false, true]:
					txt.color.setColor(0xFFFF00FF);
					txt.text +=" 1 Frame Delay";
				case [false, false]:
					txt.color.setColor(0xFFFF0000);
					txt.text +=" ERR";
			}
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

class ObjectDebugger extends h3d.scene.Object {

	var follow2d: h2d.ObjectFollower = null;
	var text: h2d.Text = null;
	var sphere: h3d.scene.Sphere = null;
	var target: h3d.scene.Object = null;
	public var autoSync : Bool = false;

	public function new(name: String, color: Int, target: h3d.scene.Object, scene: h3d.scene.Scene, s2d: h2d.Scene, offset: Float = 0.0) {
		super(scene);
		this.target = target;
		this.name = name;

		sphere = new h3d.scene.Sphere(color, 0.10, this);
		follow2d = new h2d.ObjectFollower(this, s2d);
		var flow = new h2d.Flow(follow2d);
		flow.verticalAlign = Middle;
		flow.horizontalAlign = Middle;
		flow.y += offset;

		if (offset > 0) {
			var g = new h2d.Graphics(follow2d);
			g.lineStyle(1, color, 1.0);
			g.moveTo(0,0);
			g.lineTo(0, offset);
		}
		flow.padding = 2;
		flow.backgroundTile = h2d.Tile.fromColor(0xFF000000);

		text = new h2d.Text(hxd.res.DefaultFont.get(), flow);
		text.color.setColor(color);
		//text.textAlign = Center;
		//text.dropShadow = {dx: 1, dy: 1, color: 0x000000, alpha: 1.0};
		update();
	}

	public function update() {
		var m = target.getAbsPos().clone();
		this.setTransform(m);
		text.text = '$name';
	}

	override function syncRec(ctx:h3d.scene.RenderContext) {
		if (autoSync)
			update();
		super.syncRec(ctx);
	}

	override function onRemove() {
		follow2d.remove();
		super.onRemove();
	}
}
class ObjectChecker extends h3d.scene.Object {
	var a: h3d.scene.Object;
	var b: h3d.scene.Object;
	var isFirstFrame = true;
	public var isOkFirstFrame = true;
	public var isOk = true;
	public var isSameAsPreviousFrame = true;

	var prevFrame : h3d.Matrix;

	public function new(a: h3d.scene.Object, b: h3d.scene.Object, name: String) {
		this.a = a;
		this.b = b;
		this.name = name;

		super(a.getScene());
	}

	override function emit(ctx) {
		var d = hxd.Math.distance(a.absPos.tx - b.absPos.tx, a.absPos.ty - b.absPos.ty, a.absPos.tz - b.absPos.tz);

		if (isFirstFrame) {
			isOkFirstFrame = d < hxd.Math.EPSILON;
		} else {
			isOk = isOk && d < hxd.Math.EPSILON;

			if (!isOk) {
				var d = hxd.Math.distance(a.absPos.tx - prevFrame.tx, a.absPos.ty - prevFrame.ty, a.absPos.tz - prevFrame.tz);
				isSameAsPreviousFrame = isSameAsPreviousFrame && d < hxd.Math.EPSILON;
			}
		}
		prevFrame = b.absPos.clone();
		isFirstFrame = false;
	}
}

@:access(h3d.scene.Skin)
class SkinChecker extends h3d.scene.Object {
	var joint : h3d.scene.Skin.Joint;
	public var isOk : Bool = true;
	public var isSameAsPreviousFrame : Bool = true;
	var prevFrame : h3d.Matrix;

	public function new(joint: h3d.scene.Skin.Joint, name: String) {
		this.joint = joint;
		this.name = name;
		super(joint.skin.getScene());
	}

	override function emit(ctx) {
		var jointAbs = joint.absPos;
		var skinJointAbs = joint.skin.currentAbsPose[joint.index];

		var d = hxd.Math.distance(jointAbs.tx - skinJointAbs.tx, jointAbs.ty - skinJointAbs.ty, jointAbs.tz - skinJointAbs.tz);

		isOk = isOk && d < hxd.Math.EPSILON;
		if (!isOk && prevFrame != null) {
			var d = hxd.Math.distance(jointAbs.tx - prevFrame.tx, jointAbs.ty - prevFrame.ty, jointAbs.tz - prevFrame.tz);
			isSameAsPreviousFrame = isSameAsPreviousFrame && d < hxd.Math.EPSILON;
		}

		prevFrame = skinJointAbs.clone();
	}
}