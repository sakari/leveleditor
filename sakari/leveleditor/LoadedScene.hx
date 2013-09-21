package sakari.leveleditor;
import sakari.leveleditor.Editor;
import flash.display.Sprite;
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
    
    private function addEntity(e: EntityBridge) {
        var entity = new Entity(e);
        sceneEntities.push(entity);
        onAddEntity.emit(entity);
    }

    private function setScene(sceneDefinition) {
        loadedScene = createScene(sceneDefinition);
        sceneEntities = [];
        loadedScene.onAddEntity.call(addEntity);
        loadedScene.onBegin.call(onBegin.emit);
        paused.set(true);
        loadedScene.load();
    }

    public function newScene() {
        currentSceneFile = null;
        setScene({entities: []});
    }

    public function saveAs() {
        getSavePath(saveWithPath);
    }

    private function saveWithPath(path: String): Void {
        if(path == null) return;
        currentSceneFile = path;
        var file = File.write(currentSceneFile, false);
        var sceneDefinition = { entities: []};
        for(e in sceneEntities) {
            if(!e.saved.save || e.saved.deleted) continue;
            sceneDefinition.entities.push(e.saved);
        }
        sceneEntities = sceneEntities.filter(function(e) {
                return !e.saved.deleted;
            });
        file.writeString(new Json().stringify(sceneDefinition));
    }

    public function save() {
        if(currentSceneFile == null) {
            getSavePath(saveWithPath);
            return;
        }
        saveWithPath(currentSceneFile);
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