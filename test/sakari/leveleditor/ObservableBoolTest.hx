package sakari.leveleditor;

import sakari.leveleditor.Observable;
using sakari.should.Should;

class ObservableBoolTest {
    @Test function iff_mirrors_the_state() {
        var a = new ObservableBool(false);
        var b = new ObservableBool(false);

        a.iff(b);
        b.set(true);
        a.get().should().eql(true);
        a.set(false);
        b.get().should().eql(false);
    }

    @Test function iff_sets_the_lhs_state_on_init() {
        var a = new ObservableBool(false);
        var b = new ObservableBool(true);
        a.iff(b);
        b.get().should().eql(true);
        a.get().should().eql(true);
    }

    @Test function follows_makes_lhs_follow_rhs_state() {
        var a = new ObservableBool(false);
        var b = new ObservableBool(true);
        a.follows(b);
        a.get().should().eql(true);

        b.set(false);
        a.get().should().eql(false);

        a.set(true);
        b.get().should().eql(false);
    }

    @Test function iffNot() {
        var a = new ObservableBool(false);
        var b = new ObservableBool(false);
        a.iffNot(b);
        a.get().should().eql(true);

        b.set(true);
        a.get().should().eql(false);

        a.set(true);
        b.get().should().eql(false);
    }
}
