package sakari.leveleditor;
import flash.geom.Point;
import sakari.leveleditor.Tiler;
using sakari.should.Should;

class TilerTest {
    var tiler: Tiler;

    function pointCmp(l, r) {
        return l.x == r.x && l.y == r.y;
    }
    
    @Before function setup() {
        tiler = new Tiled(new Point(10, 0), new Point(0, 10));
    }
    
    @Test function tiler_converts_from_tile_coords_to_real() {
        tiler.real(new Point(1, 2)).should().eql(new Point(10, 20), pointCmp);
    }

    @Test function tiler_converts_from_real_to_tile() {
        tiler.tile(new Point(10, 10)).should().eql(new Point(1, 1), pointCmp);
    }

    @Test function tiler_can_use_non_cartesian_coords_y() {
        tiler = new Tiled(new Point(1, 0), new Point(1, 1));
        tiler.tile(new Point(1, 1)).should().eql(new Point(0, 1), pointCmp);
   }

    @Test function tiler_can_use_non_cartesian_coords_both() {
        tiler = new Tiled(new Point(1, 0), new Point(1, 1));
        tiler.tile(new Point(2, 1)).should().eql(new Point(1, 1), pointCmp);
   }

    @Test function tiler_can_use_non_cartesian_coords_long() {
        tiler = new Tiled(new Point(10, 0), new Point(10, 10));
        tiler.tile(new Point(20, 10)).should().eql(new Point(1, 1), pointCmp);
   }

    @Test function tiler_can_snap_to_grid() {
        tiler.snap(new Point(6, 16)).x.should().eql(10); 
        tiler.snap(new Point(6, 16)).y.should().eql(20); 
    }
}