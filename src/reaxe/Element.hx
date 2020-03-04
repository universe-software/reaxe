package reaxe;

import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;

class Element {
	private var isEmpty: Map<DisplayObject, Bool> = [];

    public var type: Class<Dynamic>;
    public var properties: Map<String, Dynamic>;
    public var children: Array<Element>;

    public function new(type: Class<Dynamic>, properties: Map<String, Dynamic>, ?children: Array<Array<Element>>) {
		this.type = type;
		this.properties = properties;

		this.children = new Array<Element>();

		if(children != null) {
			for(list in children) {
				if(list != null) {
					for(child in list) {
						if(child != null)
							this.children.push(child);
					}
				}
			}
		}
    }

    public function create(): Dynamic {
		var obj = Type.createInstance(type, []);

		for(key in properties.keys()) {
			if(key != 'ref' && key != 'reref') {
				if(Reflect.getProperty(obj, key) != properties[key]) {
					if(Std.is(properties[key], Actuation))
						cast(properties[key], Actuation).tween(obj, key);
					else
						Reflect.setProperty(obj, key, properties[key]);
				}
			}
		}
		
		if(Std.is(obj, DisplayObjectContainer)) {
			var container = cast(obj, DisplayObjectContainer);

			for(child in children)
				container.addChild(child.create());
		}

		if(properties.exists('ref'))
			properties['ref'](obj);

		if(properties.exists('reref'))
			properties['reref'](obj);

		if(Std.is(obj, DisplayObjectContainer) && cast(obj, DisplayObjectContainer).numChildren == 0)
			isEmpty[obj] = true;
		else
			isEmpty[obj] = false;

		return obj;
    }

    public function morph(obj: DisplayObject) {
		for(key in properties.keys()) {
			if(key == 'reref')
				properties['reref'](obj);
			else if(key != 'ref') {
				if(Std.is(properties[key], Actuation))
					cast(properties[key], Actuation).tween(obj, key);
				else
					Reflect.setProperty(obj, key, properties[key]);
			}
		}

		if(Std.is(obj, DisplayObjectContainer)) {
			var container = cast(obj, DisplayObjectContainer);

			if(!isEmpty[container]) {
				var i = 0;
				while(i < container.numChildren) {
					var found = false;

					for(child in children) {
						if(child.properties['name'] == container.getChildAt(i).name) {
							found = true;
							break;
						}
					}

					if(!found) {
						container.removeChildAt(i);
						i--;
					}

					i++;
				}

				for(i in 0...children.length) {
					var found = false;

					for(j in 0...container.numChildren) {
						if(container.getChildAt(j).name == children[i].properties['name']) {
							found = true;
							break;
						}
					}

					if(!found)
						container.addChildAt(children[i].create(), i);
				}

				for(i in 0...container.numChildren) {
					var el: Element = null;

					for(child in children) {
						if(child.properties['name'] == container.getChildAt(i).name) {
							el = child;
							break;
						}
					}

					el.morph(container.getChildAt(i));
				}
			}
		}
    }
}
