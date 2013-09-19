package sakari.leveleditor.hxp;

import com.haxepunk.Engine;
import com.haxepunk.HXP;
import sakari.leveleditor.Editor;
import flash.geom.Point;
import flash.events.Event;
import sakari.leveleditor.hxp.ObservableEntity;


class EditorEngine extends Engine {
    var observableCamera: Observable<Point>;
    var screen: Observable<Point>;
    public var editor: Editor;

    public function new() {
        super();
    }
    
    public function entities(): Array<Prefab> {
        return [];
    }

    private function onResize(e: Event) {
        screen.set(new Point(HXP.stage.stageWidth,
                             HXP.stage.stageHeight));
    }

    public function entityFactory(e: EntityArguments): ObservableEntity {
        throw 'you must override the entityFactory method';
        return null;
    }

    private function entityAdd(args: EntityArguments) {
        var e = entityFactory(args);
        HXP.scene.add(e);
        HXP.engine.update();
        HXP.engine.render();
    }

    public function sceneFactory(scene: JsonScene): HXPSceneBridge {
        return new LoadableScene(scene, entityFactory);
    }

    override public function init() {
        super.init();
        observableCamera = new Observable(HXP.scene.camera)
            .listen(function(p, o) {
                    HXP.scene.camera = p;
                    HXP.engine.render();
                });
        screen = new Observable(new Point(0, 0));
        onResize(null);

        HXP.stage.addEventListener(Event.RESIZE, onResize);
        editor = new Editor(entityAdd
                            , sceneFactory
                            , screen
                            , observableCamera
                            , new Observable(HXP.engine.paused)
                            .listen(function(p, o) {
                                    HXP.engine.paused = p;
                                }) 
                            , entities());
    }
}