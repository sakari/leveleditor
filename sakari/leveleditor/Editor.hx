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
    var icon: BitmapData;
};

typedef JsonScene = {
    var entities: Array<EntityArguments>;
};

typedef EntityArguments = {
    var x: Float;
    var y: Float;
    var type: String;
    var id: Int;
    var save: Bool;
    var deleted: Bool;
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
    var prefabSelect: MenuSelect<Prefab>;
    var loaded: LoadedScene;

    public function resetMode() {
        this.entityAdd.disable();
        this.select.disable();
        this.paused.set(false);
        this.prefabSelect.reset();
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
        entityAdd = new AddEntity(Lib.current.stage
                                  , camera
                                  , function(x: Float, y: Float) {
                                      if(selectedPrefab == null) return;
                                      var e = {
                                          type: selectedPrefab.type
                                          , x: x + camera.get().x
                                          , y: y + camera.get().y
                                          , id: 0
                                          , save: true
                                          , deleted: false
                                      };
                                      createEntity(e);
                                  });
        select = new Select(Lib.current.stage, camera, screen);
        majorMode = new Single()
            .add(entityAdd)
            .add(select);
        setupMenubar();
        loaded.newScene();
    }

    private function setupFileMenu() {
        Commands.get(Lib.current.stage)
            .command('new scene', 'File/New', "n", loaded.newScene)
            .command('open scene', 'File/Open', "o", loaded.load)
            .command('save scene', 'File/Save', 's', loaded.save)
            .command('save scene as', 'File/Save As', 'S', loaded.saveAs);
    }

    private function setupPrefabMenu() {
        prefabSelect = new MenuSelect(Menubar.get(), 'Prefab')
            .onSelect(function(tag, data) {
                    selectedPrefab = data;
                });
        prefabs.map(function(p) {
                prefabSelect.add(p.type, p);
            });
    }

    private function setupEditMenu() {
        Commands.get(Lib.current.stage)
            .commandToggle('pause', 'Edit/Pause', 'p'
                           , paused)
            .commandMode('add entity', 'Edit/Add Entity', 'a'
                         , entityAdd, paused)
            .commandMode('select', 'Edit/Select', 'e'
                           , select, paused);
    }

    private function setupMenubar() {
        setupPrefabMenu();
        setupFileMenu();
        setupEditMenu();
    }
}