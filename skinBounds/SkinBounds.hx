import h3d.scene.*;
import h3d.col.IPoint;
import hxd.fmt.hmd.Data;

class SkinBounds extends hxd.App {

	var time : Float = 0.;
	var skin : h3d.scene.Skin;
	var box : h3d.scene.Box;
	var boxes : Array<h3d.scene.Box> = [];
	var getBounds : h3d.scene.Box;

	override function init() {
		var model = hxd.Res.Abigail;
		var anim = hxd.Res.Anim_Abigail_Collapse;

		var obj = model.toHmd().makeObject(function(name) return hxd.Res.load(name.split("/").pop()).toTexture());
		if( obj.isMesh() )
			skin = cast(obj, h3d.scene.Skin);
		else {
			for( c in obj ) {
				skin = Std.downcast(c, h3d.scene.Skin);
				if( skin != null ) break;
			}
			for( c in obj )
				if( c != skin )
					c.remove();
		}
		if( anim != null ) {
			var anim = obj.playAnimation(anim.toHmd().loadAnimation());
			anim.speed = 0.05;
		}

		new h3d.scene.Interactive(skin.getGlobalCollider(), s3d);

		var joints = skin.getSkinData().allJoints;
		for( j in joints ) {
			var b = new h3d.scene.Box(j.bindIndex < 0 ? 0xFF : 0xFF00,h3d.col.Bounds.fromValues(-1,-1,-1,2,2,2), s3d);
			b.material.color.a = 0.5;
			b.material.blendMode = Alpha;
			var follow = new h2d.ObjectFollower(b, s2d);
			var tf = new h2d.Text(hxd.res.DefaultFont.get(), follow);
			//tf.text = j.name;
			boxes.push(b);
		}

		getBounds = new h3d.scene.Box(0xFFFFFF, new h3d.col.Bounds(), s3d);

		box = new h3d.scene.Box(s3d);
		s3d.addChild(obj);
		new h3d.scene.CameraController(10, s3d);
	}

	override function update(dt:Float) @:privateAccess {
		box.bounds = skin.getCurrentSkeletonBounds();
		getBounds.bounds = skin.getBounds();
		for( i in 0...boxes.length ) {
			var j = skin.skinData.allJoints[i];
			var b = boxes[i];
			if( j.offsets != null ) {
				var m = skin.currentPalette[j.bindIndex];
				b.setTransform(m);
				b.bounds.empty();

				var pt = j.offsets.getMin();
				b.bounds.addSpherePos(pt.x, pt.y, pt.z, j.offsetRay);
				var pt = j.offsets.getMax();
				b.bounds.addSpherePos(pt.x, pt.y, pt.z, j.offsetRay);
			} else {
				b.color = 0xFF;
				b.setTransform(skin.currentAbsPose[j.index]);
				b.bounds.empty();
				b.bounds.addSpherePos(0,0,0,0.01);
			}
		}
	}

	static function main() {

		//hxd.fmt.fbx.BaseLibrary.maxBonesPerSkin = 1000;
		try sys.FileSystem.deleteFile("res/.tmp/cache.dat") catch( e : Dynamic ) {};

		// initialize embeded ressources
		hxd.Res.initLocal();

		// start the application
		new SkinBounds();
	}

}
