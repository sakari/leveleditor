import flash.geom.Point;
import com.haxepunk.graphics.Image;
import com.haxepunk.HXP;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.utils.Draw;
import sakari.leveleditor.hxp.ObservableEntity;

class Dude extends ObservableEntity {

    var maxSpeed: Float = 100;
    var slide: Float = 100;
    var acceleration: Float = 150;
    var speed: Point;
    var jumping: Bool;
    var gravity = 600;
    var jumpForce = 400;

    public function new(def) {
        speed = new Point(0, 0);
        super(def);
        jumping = true;
        var i = new Image('graphics/dude.png');
        addGraphic(i);
        x = def.x - i.width / 2;
        y = def.y - i.height / 2;

        setHitbox(i.width - 11
                  , i.height - 3, 
                  Std.int(5 + (i.width - 11)/2),
                  Std.int(i.height / 2) + 3
                  );
        layer = 0;
        Input.define('left', [Key.LEFT]);
        Input.define('up', [Key.UP]);
        Input.define('right', [Key.RIGHT]);
    }

    public override function gameUpdate() {
        speed.y += gravity * HXP.elapsed;

        if(!jumping) {
            if(Input.check('up')) {
                speed.y = -jumpForce;
            } else if(Input.check('left')) {
                speed.x -= (acceleration * HXP.elapsed);
                if(speed.x < -maxSpeed) speed.x = -maxSpeed;
            } else if(Input.check('right')) {
                speed.x += (acceleration * HXP.elapsed);
                if(speed.x > maxSpeed) speed.x = maxSpeed;
            } else {
                if(speed.x < 0) {
                    speed.x += (slide * HXP.elapsed);
                    if(speed.x > 0) speed.x = 0;
                } else if(speed.x > 0) {
                    speed.x -= (slide * HXP.elapsed);
                    if(speed.x < 0) speed.x = 0;
                }
            }
        }

        jumping = true;
        if(collide('platform', x, y + (speed.y * HXP.elapsed)) != null) {
            speed.y = 0;
            jumping = false;
        }
        if(collide('platform', (x + speed.x * HXP.elapsed), y) != null) {
            speed.x = 0;
        }
        x += (speed.x * HXP.elapsed);
        y += (speed.y *HXP.elapsed);
        HXP.scene.camera.x = x - HXP.screen.width / 2;
        HXP.scene.camera.y = y - HXP.screen.height / 2;
    }
}