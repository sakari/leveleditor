import flash.geom.Point;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import sakari.leveleditor.hxp.ObservableEntity;

class ShinyMover extends ObservableEntity {
    var speed: Point;
    var gravity = 600;
    var lifeTime = 100.0;

    public function new(def) {
        super(def);
        var i = new Image('graphics/shiny.png');
        addGraphic(i);
        x = def.x - i.width / 2;
        y = def.y - i.height / 2;
        type = "shiny";
        speed = new Point();
        speed.x = 400 - Math.random() * 800;
        speed.y = -Math.random() * 600;
        var l = Math.random();
        if(l < 0.5) layer = 0;
        else layer = 1;
        setHitbox(i.width
                  , i.height
                  , Std.int(i.width / 2)
                  , Std.int(i.height / 2));
    }

    public override function gameUpdate() {
        speed.y += gravity * HXP.elapsed;
        x += speed.x * HXP.elapsed;
        y += speed.y * HXP.elapsed;
        lifeTime -= HXP.elapsed;
        if(lifeTime < 0) {
            HXP.scene.remove(this);
        }
    }
}