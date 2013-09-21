package sakari.leveleditor;
import flash.geom.Point;

interface Tiler {
    function real(p: Point): Point;
    function tile(p: Point): Point;
    function snap(p: Point): Point;
}

class FreeHand implements Tiler {
    public function real(p) {
        return p;
    }
    public function tile(p) {
        return p;
    }
    public function snap(p) { return p; }
    public function new() {}

}

class Tiled implements Tiler {
    var _x: Point;
    var _y: Point;
    var _angle: Float;

    function len(p) {
        return Math.sqrt(Math.pow(p.x, 2) + Math.pow(p.y, 2));
    }

    function angle(x: Point, y: Point) {
        return Math.acos((x.x * y.x + x.y * y.y) /
                         (len(x) * len(y)));
    }
    
    public function new(x: Point, y: Point) {
        _x = x;
        _y = y;
        _angle = angle(x, y);
    }
    
    public function real(tile: Point) {
        return new Point(tile.x * _x.x + tile.y * _y.x
                         ,  tile.x * _x.y + tile.y * _y.y
                         );
    }

    public function tile(cart: Point) {
        var u = cart.x  - cart.y / Math.tan(_angle);
        var w = cart.y / Math.sin(_angle);
        var tile_x = u / len(_x);
        var tile_y = w / len(_y);
        return new Point(Math.round(tile_x), Math.round(tile_y));
    }

    public function snap(cart: Point): Point {
        return real(tile(cart));
    }
}