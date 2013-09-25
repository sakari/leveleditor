import sakari.leveleditor.Editor;
import sakari.leveleditor.hxp.EditorEngine;
import flash.geom.Point;
import sakari.leveleditor.hxp.ObservableEntity;

class EditorTest extends EditorEngine {
    public override function entities(): Array<Prefab> {
        return [
                {type: 'dude', icon: null, layer: 'defaults' }
                , {type: 'platform', icon: null, layer: 'tiled' }
                , {type: 'spawner', icon: null, layer: 'tiled' }
                ];
    }

    public override function entityFactory(p) {
        var e: ObservableEntity = null;
        if(p.type == 'dude')
            e = new Dude(p);
        else if(p.type == 'platform')
            e = new Platform(p);
        else if(p.type == 'spawner')
            e = new Spawner(p);
        return e;
    }

    public static function main() { new EditorTest(); }
}