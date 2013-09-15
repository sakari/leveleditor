# Leveleditor

A library for adding level editing to openfl based game engines. Why? This way
what you see in the editor is exactly what the engine will render. We can also
run and pause the game engine while we are editing the scene to test things out.

## Features

 * Haxepunk [bridge](https://github.com/sakari/openfl-editor/tree/master/sakari/leveleditor/hxp)
 * Open/Save json scenes
 * Add entities to scene
 * Drag and delete entities in scene
 * Move editor camera by dragging on scene

## Caveats

 * Mac only as `filepicker` and `menubar` only support osx. Contribute there if
   you want something else.
 * Early version with lots of missing functionality

## Building

Clone, build and install from github. Note the tags.

 * [filepicker 1.0.0](https://github.com/sakari/filepicker), requires building native libs
 * [menubar 0.0.2](https://github.com/sakari/menubar), requires building native libs
 * [should 0.0.1](https://github.com/sakari/haxe-should)
 * [should-openfl 0.0.2](https://github.com/sakari/haxe-should-openfl)

The `project.xml` and `example/project.xml` define the other dependencies which you
need to get from haxelib. After you are done build everything with

    make

For the selection of make targets run

    make help

## License

(c) Sakari Jokinen

MIT license
