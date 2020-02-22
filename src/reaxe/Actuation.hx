package reaxe;

import motion.Actuate;

class Actuation {
    public var time: Float;
    public var to: Dynamic;

    public function new(time: Float, to: Dynamic) {
        this.time = time;
        this.to = to;
    }

    public function tween(obj: Dynamic, prop: String) {
        var state = {};
        Reflect.setProperty(state, prop, to);
        Actuate.tween(obj, time, state);
    }
}