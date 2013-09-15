package sakari.leveleditor.hxp;

import com.haxepunk.Scene;
import sakari.leveleditor.Editor;
import sakari.leveleditor.hxp.HXPSceneBridge;
import flash.geom.Point;
import flash.events.Event;

class LoadableScene extends HXPSceneBridge {
    var json: JsonScene;
    var factory: EntityArguments -> ObservableEntity;

    public function new(json: JsonScene
                        , factory) {
        super();
        this.json = json;
        this.factory = factory;
    }

    public override function begin() {
        super.begin();
        for(i in json.entities) {
            add(factory(i));
        }
    }
}