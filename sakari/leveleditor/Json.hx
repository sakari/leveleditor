package sakari.leveleditor;

class Json {
    public function new() {}

    public function parse(str): Dynamic {
        return haxe.Json.parse(str);
    }

    public function stringify(o: Dynamic): String {
        return pretty(o, 0);
    }

    private function pretty(o: Dynamic, indent: Int) {
        if(Std.is(o, Float)) {
            return '' + cast(o, Float);
        } else if(Std.is(o, Int)) {
            return '' + cast(o, Int);
        } else if(Std.is(o, Bool)) {
            return '' + cast(o, Bool);
        } else if(Std.is(o, String)) {
            return '"' + cast(o, String) + '"';
        } else if(Std.is(o, Array)) {
            return '[\n' + prettyArray(cast(o, Array<Dynamic>), indent + 1) + 
                '\n' + pad(indent) + ']';
        }
        return '{\n' +
            prettyObject(o, indent + 1) +
            '\n' + pad(indent) + '}';
    }

    private function prettyObject(o: Dynamic, i) {
        var fields = Reflect.fields(o);
        fields.sort(function(a, b) {
                return a < b ? -1 : 1;
            });
        return fields.map(function(f) {
                return pad(i) + '"' + f + '": ' + pretty(Reflect.field(o, f)
                                                         , i);
            }).join(',\n');
    }

    private function prettyArray(o: Array<Dynamic>, i) {
        return o.map(function(e) {
                return pad(i) + pretty(e, i);
            }).join(',\n');
    }
    
    private function pad(i) {
        var p = '';
        var k = 0;
        while(k++ < i * 4) {
            p += ' ';
        }
        return p;
    }
}