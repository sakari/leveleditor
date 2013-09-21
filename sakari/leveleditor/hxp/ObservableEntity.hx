package sakari.leveleditor.hxp;
import com.haxepunk.Entity;
import com.haxepunk.HXP;
import sakari.leveleditor.Editor;
import sakari.leveleditor.EventEmitter;

class ObservableEntity extends Entity {
    var listeners: Array<ObservableEntity -> Void>;
    public var def: EntityArguments;
    public var onChange: EventEmitter<ObservableEntity>;

    public function gameUpdate() {}

    public override function update() {
        super.update();
        if(HXP.engine.paused) return;
        gameUpdate();
        onChange.emit(this);
    }

    public function new(def: EntityArguments) {
        super();
        onChange = new EventEmitter();
        this.def = def;
    }

}
