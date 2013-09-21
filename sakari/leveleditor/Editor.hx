package sakari.leveleditor;
import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import flash.display.BitmapData;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.geom.Point;

import sakari.leveleditor.modes.Single;
import sakari.leveleditor.modes.AddEntity;
import sakari.leveleditor.modes.Camera;
import sakari.leveleditor.modes.Select;
import sakari.leveleditor.modes.AutoScroll;
import sakari.leveleditor.Entity;
import sakari.leveleditor.MenuSelect;

import sakari.menubar.Menubar;

#if mocks
import mocks.sakari.filepicker.Open;
import mocks.sakari.filepicker.Save;
import mocks.sys.io.File;
#else
import sys.io.File;
import sakari.filepicker.Open;
import sakari.filepicker.Save;
#end


enum Bounds {
    BoundingBox(width: Float, height: Float);
    BoundingCircle(radius: Float);
    BoundingPolygon(points: Array<{x: Float, y: Float}>);
}

enum Id {
    IdStatic(id: Int);
    IdDynamic(id: Int);
}


interface SceneBridge {
    var onAddEntity: EventEmitter<EntityBridge>;
    var onBegin: EventEmitter<Sprite>;
    function load(): Void;
}

interface EntityBridge {
    var x: Observable<Float>;
    var y: Observable<Float>;
    var deleted: Observable<Bool>;
    var definition: EntityArguments;
}

typedef Prefab = {
    var type: String;
    @:optional var icon: BitmapData;
    @:optional var layer: String;
};

typedef JsonLayer = {
    var name: String;
    @:optional var grid: String;
};

typedef JsonGrid = {
    var name: String;
    var x: {x: Float, y: Float};
    var y: {x: Float, y: Float};
};

typedef JsonScene = {
    var entities: Array<EntityArguments>;
    var layers: Array<JsonLayer>;
    var grids: Array<JsonGrid>;
}

typedef EntityArguments = {
    var x: Float;
    var y: Float;
    var type: String;
    var id: Int;
    var save: Bool;
    var deleted: Bool;
    var layer: String;
}

class Editor {
    var prefabs: Array<Prefab>;
    var selectedPrefab: Prefab;
    var editorLayer: Sprite;
    var keys: Map<Int, (Void -> Void)>;
    var paused: Observable<Bool>;
    var camera: Observable<Point>;

    var majorMode: Single;
    var entityAdd: Mode;
    var select: Mode;
    var originalCamera: Point;
    var prefabMenu: MenuSelect<Prefab>;
    var loaded: LoadedScene;

    public function resetMode() {
        this.entityAdd.disable();
        this.select.disable();
        this.paused.set(false);
        this.prefabMenu.reset();
    }

    public function new( createEntity: EntityArguments -> Void
                         , createScene: JsonScene -> SceneBridge
                         , screen: Observable<Point>
                         , camera: Observable<Point>
                         , paused
                         , prefabs
                         ) {
        loaded = new LoadedScene(createScene, paused
                                 , function(done) {
                                     new Save().extensions(['json']).open(done);
                                 }, function(done) {
                                     new Open().chooseFiles()
                                     .open(function(ps) {
                                             ps.length == 0 ? 
                                             done(null) : 
                                             done(ps[0]);
                                         });
                                 });
        loaded.onBegin.call(function(sprite) {
                this.editorLayer = new Sprite();
                this.camera.listen(function(p, o) {
                        editorLayer.x = -p.x;
                        editorLayer.y = -p.y;
                    });
                sprite.addChild(editorLayer);
            });
        loaded.onAddEntity.call(function(e) {
                editorLayer.addChild(e);
            });
        this.paused = paused;
        this.prefabs = prefabs;
        this.camera = camera;
        
        paused.listen(function(v, old) {
                if(v == old) return;
                if(v) {
                    originalCamera = camera.get();
                    select.enable();
                }else {
                    camera.set(originalCamera);
                    originalCamera = null;
                    majorMode.disable();
                }
            });
        prefabMenu = setupPrefabMenu();
        entityAdd = new AddEntity(Lib.current.stage
                                  , camera
                                  , prefabMenu.observe
                                  , function(s) { return loaded.tiler(s); }
                                  , createEntity);
        select = new Select(Lib.current.stage, camera, screen, 
                            function(s) { return loaded.tiler(s); });
        majorMode = new Single()
            .add(entityAdd)
            .add(select);
        setupFileMenu();
        setupEditMenu();
        loaded.newScene();
    }

    private function setupFileMenu() {
        Commands.get(Lib.current.stage)
            .command('new scene', 'File/New', "n", loaded.newScene)
            .command('open scene', 'File/Open', "o", loaded.load)
            .command('save scene', 'File/Save', 's', loaded.save)
            .command('save scene as', 'File/Save As', 'S', loaded.saveAs);
    }

    private function setupPrefabMenu(): MenuSelect<Prefab> {
        var m = new MenuSelect(Menubar.get(), 'Prefab');
        prefabs.map(function(p) {
                m.add(p.type, p);
            });
        return m;
    }

    private function setupEditMenu() {
        Commands.get(Lib.current.stage)
            .commandToggle('pause', 'Edit/Pause', 'p'
                           , paused)
            .commandToggle('add entity', 'Edit/Add Entity', 'a'
                         , entityAdd, paused)
            .commandToggle('select', 'Edit/Select', 'e'
                           , select, paused);
    }
}