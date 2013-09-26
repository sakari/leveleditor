package sakari.leveleditor.hxp;

import com.haxepunk.Scene;
import com.haxepunk.Entity;
import sakari.leveleditor.EventEmitter;
import sakari.leveleditor.Editor;
import flash.display.Sprite;
import com.haxepunk.HXP;

class HXPSceneBridge extends Scene implements SceneBridge {
    public var onBegin: EventEmitter<Sprite>;
    public var onAddEntity: EventEmitter<EntityBridge>;

    public override function begin() {
        super.begin();
        onBegin.emit(this.sprite);
    }

    public function new() {
        super();
        onAddEntity = new EventEmitter();
        onBegin = new EventEmitter();
    }

    /**
       NOTE. `e` MUST inherit from ObservableEntity. We just cannot state that
       in haxe.
     */
    public override function add<T: Entity>(e: T): T {
        super.add(e);
        onAddEntity.emit(new HXPEntityBridge(cast(e, ObservableEntity)));
        return e;
    }

    public function load() {
        HXP.scene = this;
        HXP.engine.update();
        HXP.engine.render();
    }
}