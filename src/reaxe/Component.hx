package reaxe;

import openfl.display.Sprite;

class Component extends Sprite {
    private function render(): Element { return null; }

    private function refresh() {
        render().morph(this);
    }
}