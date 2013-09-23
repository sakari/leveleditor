import flash.geom.Point;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import sakari.leveleditor.hxp.ObservableEntity;

class Spawner extends ObservableEntity {
    public function new(def) {
        super(def);
        var i = new Image('graphics/spawner.png');
        addGraphic(i);
        x = def.x - i.width / 2;
        y = def.y - i.height / 2;
        type = "spawner";
        layer = 2;
        setHitbox(i.width
                  , i.height
                  , Std.int(i.width / 2)
                  , Std.int(i.height / 2));
    }

    public override function gameUpdate() {
        if(Math.random() < 0.03) {
            HXP.scene.add(new ShinyMover({
                    x: x + originX
                            , y: y + originY
                            , type: 'shinyMover'
                            , id: 0
                            , save: false
                            , deleted: false
                            , layer: 'default'
                            }
                    ));
        }
    }
}