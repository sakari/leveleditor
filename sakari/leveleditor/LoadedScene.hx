package sakari.leveleditor;
import sakari.leveleditor.Editor;
import flash.display.Sprite;
import flash.geom.Point;
import sakari.leveleditor.Tiler;

#if mocks
import mocks.sys.io.File;
#else
import sys.io.File;
#end

class LoadedScene {
    var currentSceneFile: String;
    var sceneEntities: Array<Entity>;
    var createScene: JsonScene -> SceneBridge;
    var loadedScene: SceneBridge;
    var paused: Observable<Bool>;
    var getSavePath: (String -> Void) -> Void;
    var getOpenPath: (String -> Void) -> Void;
    public var onAddEntity: EventEmitter<Entity>;
    public var onBegin: EventEmitter<Sprite>;
    var loadedJson: JsonScene;
    var tilers: Map<String, Tiler>;

    public function new(createScene: JsonScene -> SceneBridge
                        , paused: Observable<Bool>
                        , getSavePath: (Null<String> -> Void) -> Void
                        , getOpenPath: (String -> Void) -> Void) {
        this.createScene = createScene;
        this.paused = paused;
        this.getOpenPath = getOpenPath;
        this.getSavePath = getSavePath;
        onAddEntity = new EventEmitter();
        onBegin = new EventEmitter();
    }

    private function loadLayerTilers(scene: JsonScene) {
        tilers = new Map();
        for(layer in scene.layers) {
            if(layer.grid == null) {
                tilers.set(layer.name, new FreeHand());
                continue;
            }
            for(grid in scene.grids) {
                if(layer.grid != grid.name) continue;
                tilers.set(layer.name, new Tiled(
                                                 new Point(grid.x.x, grid.x.y)
                                                 , new Point(grid.y.x, grid.y.y)
                                                 ));
                break;
            }
        }
        if(tilers.get('default') == null) {
            tilers.set('default', new FreeHand());
        }
    }
    
    private function addEntity(e: EntityBridge) {
        var entity = new Entity(e);
        sceneEntities.push(entity);
        onAddEntity.emit(entity);
    }

    private function setScene(sceneDefinition) {
        loadedJson = sceneDefinition;
        loadLayerTilers(sceneDefinition);
        loadedScene = createScene(sceneDefinition);
        sceneEntities = [];
        loadedScene.onAddEntity.call(addEntity);
        loadedScene.onBegin.call(onBegin.emit);
        paused.set(true);
        loadedScene.load();
    }

    public function newScene() {
        currentSceneFile = null;
        setScene({layers: [], grids: [], entities: []});
    }

    public function saveAs() {
        getSavePath(saveWithPath);
    }

    private function saveWithPath(path: String): Void {
        if(path == null) return;
        currentSceneFile = path;
        var file = File.write(currentSceneFile, false);
        var sceneDefinition = { layers: loadedJson.layers
                                , grids: loadedJson.grids
                                , entities: []};
        for(e in sceneEntities) {
            if(!e.saved.save || e.saved.deleted) continue;
            sceneDefinition.entities.push(e.saved);
        }
        sceneEntities = sceneEntities.filter(function(e) {
                return !e.saved.deleted;
            });
        file.writeString(new Json().stringify(sceneDefinition));
        file.close();
    }

    public function save() {
        if(currentSceneFile == null) {
            getSavePath(saveWithPath);
            return;
        }
        saveWithPath(currentSceneFile);
    }

    public function tiler(layer: String) {
        var tiler = tilers.get(layer == null ? 'default' : layer);
        if(tiler == null) {
            throw 'no such grid ${layer}';
        }
        return tiler;
    }

    public function load() {
        getOpenPath(function(path) {
                if(path == null) return;
                var contents = File.getContent(path);
                var sceneDefinition;
                try {
                    sceneDefinition = new Json().parse(contents);
                } catch(e: Dynamic) {
                    trace('parse error for $path: $e');
                    return;
                }
                currentSceneFile = path;
                setScene(sceneDefinition);
            });
    }
}