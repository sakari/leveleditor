package sakari.leveleditor;
import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
import flash.display.BitmapData;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.geom.Point;

import haxe.Json;
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
    var createScene: JsonScene -> SceneBridge;
    var sceneDefinition: JsonScene;
    var prefabSelect: MenuSelect<Prefab>;
    var currentSceneFile: String;
    var sceneEntities: Array<Entity>;

    public function loadScene(scene: SceneBridge) {
        scene.onAddEntity.call(addEntity);
        scene.onBegin.call( function(sprite: Sprite) {
                editorLayer = new Sprite();
                camera.listen(function(p, o) {
                        editorLayer.x = -p.x;
                        editorLayer.y = -p.y;
                    });
                sprite.addChild(editorLayer);
            });
        paused.set(true);
        scene.load();
    }

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
        sceneEntities = [];
        this.createScene = createScene;
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
        newScene();
    }

    private function newScene() {
        currentSceneFile = null;
        sceneDefinition = { entities: []};
        loadScene(createScene(sceneDefinition));
    }

    private function setupFileMenu() {
                
        function saveCurrentFile() {
            if(currentSceneFile == null) return;
            var file = File.write(currentSceneFile, false);
            sceneDefinition.entities = [];
            for(e in sceneEntities) {
                if(!e.saved.save || e.saved.deleted) continue;
                sceneDefinition.entities.push(e.saved);
            }
            sceneEntities = sceneEntities.filter(function(e) {
                    return !e.saved.deleted;
                });
            file.writeString(Json.stringify(sceneDefinition));
        }

        function saveAs() {
            new Save().extensions(['json']).open(function(path) {
                    currentSceneFile = path;
                    saveCurrentFile();
                });
        }
                
        var m = Menubar.get()
            .add('File/New', null, true, function() {
                    newScene();
                })
            .add('File/Open', null, true, function(){
                    new Open().chooseFiles().open(function(paths) {
                            if(paths.length == 0) return;
                            var path = paths[0];
                            var contents = File.getContent(path);
                            try {
                                sceneDefinition = Json.parse(contents);
                            } catch(e: Dynamic) {
                                trace('parse error for $path: $e');
                                return;
                            }
                            currentSceneFile = path;
                            loadScene(createScene(sceneDefinition));
                        });
                })
            .add('File/Save', null, true, function() {
                    if(currentSceneFile == null) {
                        saveAs();
                        return;
                    }
                    saveCurrentFile();
                })
            .add('File/Save As', null, true, saveAs);
    }
    
    private function setupMenubar() {
        setupFileMenu();

        var m = Menubar.get();

        prefabSelect = new MenuSelect(m, 'Prefab')
            .onSelect(function(tag, data) {
                    selectedPrefab = data;
                });
        prefabs.map(function(p) {
                prefabSelect.add(p.type, p);
            });
        m.add('Edit/Pause')
            .enable('Edit/Pause')
            .add('Edit/Add Entity')
            .listen('Edit/Pause', function() {
                    paused.set(!paused.get());
                })
            .listen('Edit/Add Entity', function() {
                    if(entityAdd.enabled) {
                        m.off('Edit/Add Entity');                    
                        select.enable();
                        return;
                    }
                    m.on('Edit/Add Entity');                    
                    entityAdd.enable();
                });

        this.entityAdd
            .onEnable(function() {
                    m.on('Edit/Add Entity');
                })
            .onDisable(function() {
                    m.off('Edit/Add Entity');
                });

        this.paused.listen(function(v, o) {
                if(v) {
                    m.on('Edit/Pause');
                    m.enable('Edit/Add Entity');
                } else {
                    m.off('Edit/Pause');
                    m.off('Edit/Add Entity');
                    m.disable('Edit/Add Entity');
                }
            });
    }

    public function addEntity(e: EntityBridge): Editor {
        var entity = new Entity(e);
        sceneEntities.push(entity);
        editorLayer.addChild(entity);
        return this;
    }
}