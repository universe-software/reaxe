# Getting Started with Reaxe

## Install OpenFL and Actuate

If you don't haxe OpenFL already, you'll need to install it with this command: `haxelib install openfl`. Then run `haxelib run openfl setup`. Also install Actuate with `haxelib install actuate`.

## Install

Install Reaxe with this command: `haxelib install reaxe`.

## Create an OpenFL Project

To create a new OpenFL project, run `openfl create project <name>`, replacing `<name>` with the name for your project. It will create a new folder with that name containing a basic starter project template.

## Add Reaxe and Actuate

To include Reaxe and Actuate in the new project, add the following lines to `project.xml`, after the line that says `<haxelib name="openfl" />`:

```xml
<haxelib name="actuate" />
<haxelib name="reaxe" />
```

## Making a Component

A Reaxe component is a reusable piece of UI, just like any OpenFL component, but the difference is that a Reaxe component does not explicitly create its children and change their properties manually. Instead, it defines a *layout* and Reaxe automatically creates and updates properties when variables change. All Reaxe components must extend `reaxe.Component`, which itself extends `openfl.display.Sprite`, and must implement the `render` method, which is what defines the layout. Components should also call `super()` and `refresh()` in their constructor. Here's an example of a component class:

```haxe
package;

import reaxe.Component;
import reaxe.Element;

class Main extends Component {
	public function new() {
		super();
		refresh();
	}
	
	private override function render(): Element {
		//... Code to define layout ...
	}
}
```

An `Element` object defines a node in the layout tree. To define a component's layout, the `render` function should return a tree of `Element`s. Usually, you define layout in an XML file and use Reaxe's `XmlRenderer.render` macro to generate the layout code, but you can also manually write it.

## Layout XML

Layout XML files should be put somewhere in the `Assets` folder (usually in a subfolder named, for example, `components`). Here's the most basic layout:

```xml
<Component />
```

XML layout elements are just Haxe class names (usually OpenFL components), and the root node should always be a `Component`. Let's add a `TextField` now:

```xml
<Component>
	<TextField name="'myTextField'" text="'Hello, world!'" />
</Component>
```

Notice how string are put inside single quotes, as well as in the double quotes. That's because properties are always Haxe expressions, so if you want a string literal, you use single quotes. If you omit those, it will try to interpret the string as an expression, which is invalid. Omit the quotes to use numbers, variables, function calls, etc.. Also, notice the `name` property. Every element except for the root node must specify a name. Names should always be unique within a specific parent node. (They don't have to be globally unique - only different from sibling elements.) Omitting a name or having duplicate names can cause unexpected behavior and weird errors.

### Including Layouts in Haxe Classes

For XML layouts to do anything, they need to be included in a component class's `render` function with `XmlRenderer`. For example:

```haxe
package;

import openfl.text.TextField;
import reaxe.Component;
import reaxe.Element;
import reaxe.XmlRenderer;

class Main extends Component {
	public function new() {
		super();
		refresh();
	}
	
	private override function render(): Element {
		return XmlRenderer.render('Assets/components/Main.xml');
	}
}
```

Notice how `openfl.text.TextField` is imported now. Any classes used in the XML must be imported in the source code.

## Reactive State

The point of a reactive UI framework is for the UI to be in-sync with variables. Reaxe does this with Haxe's property setters - a way to react to changes in fields. When a field is updated, the setter should call `refresh()` so that the UI will update. The XML can use the field's value in element properties. For example:

```haxe
package;

import openfl.text.TextField;
import reaxe.Component;
import reaxe.Element;
import reaxe.XmlRenderer;

class Main extends Component {
	private var text(null, set) = 'Hello, world!';
	
	private function set_text(text: String): String {
		this.text = text;
		refresh();
		return text;
	}

	public function new() {
		super();
		refresh();
	}
	
	private override function render(): Element {
		return XmlRenderer.render('Assets/components/Main.xml');
	}
}
```

```xml
<Component>
	<TextField name="'myTextField'" text="text" />
</Component>
```

Notice how the `text` property isn't in single quotes. That's so it will be evaluated as a Haxe expression - a variable name. Now whenever the `text` field of the class changes, the `TextField` will be updated.

## `ref`s and Event Listeners

Sometimes you want to get access to the actual OpenFL object of an element so you can do things such as add event listeners. You can do this by setting the element's `ref` property to a function that will accept the OpenFL object as a parameter. That function will be called when the OpenFL object is created from the element. Here's an example that uses a `ref` to add an event listener:

```haxe
package;

import openfl.events.MouseEvent;
import openfl.text.TextField;
import reaxe.Component;
import reaxe.Element;
import reaxe.XmlRenderer;

class Main extends Component {
	private var text(null, set) = 'Hello, world!';
	
	private function set_text(text: String): String {
		this.text = text;
		refresh();
		return text;
	}

	public function new() {
		super();
		refresh();
	}
	
	private function onClick(e: MouseEvent) {
		text = 'You clicked me!';
	}
	
	private override function render(): Element {
		return XmlRenderer.render('Assets/components/Main.xml');
	}
}
```

```xml
<Component>
	<TextField name="'myTextField'"
		text="text"
		ref="(ref: TextField) -> ref.addEventListener(MouseEvent.CLICK, onClick)" />
</Component>
```

Notice how it uses an arrow function in the `ref` property and adds a click event listener to call the `onClick` function when the `TextField` is clicked. When it's clicked, it changes the text to `'You clicked me!'`.

Normally, `ref`s only get called when the object is first created, not every time the object is updated. In some cases, you want the function to be called on every update, so you should use the `reref` property instead of `ref`. `reref` calls on every update.

## Constructs: `if` and `for`

### The `if` construct

The `if` construct controls whether an element gets rendered. You can give an element an `if` property as a boolean value, and, if that value is false, the element won't get rendered. Example:

```haxe
package;

import openfl.events.MouseEvent;
import openfl.text.TextField;
import reaxe.Component;
import reaxe.Element;
import reaxe.XmlRenderer;

class Main extends Component {
	private var shown(null, set) = true;
	
	private function set_shown(shown: Bool): Bool {
		this.shown = shown;
		refresh();
		return shown;
	}

	public function new() {
		super();
		refresh();
	}
	
	private function onClick(e: MouseEvent) {
		shown = false;
	}
	
	private override function render(): Element {
		return XmlRenderer.render('Assets/components/Main.xml');
	}
}
```

```xml
<Component>
	<TextField if="shown"
		name="'myTextField'"
		text="'Click me to make me disappear'"
		ref="(ref: TextField) -> ref.addEventListener(MouseEvent.CLICK, onClick)" />
</Component>
```

### The `for` construct

The `for` construct makes an element duplicate multiple times for each item in an array, useful for displaying a list. To make an element repeat, set the `for` property to `<name> : <array>`, replacing `<name>` with the name for the iterator variable and `<list>` with a Haxe expression for an array. This is similar to haxe for loops that use the syntax `for(<name> in <array>)`. For example:

```haxe
package;

import openfl.events.MouseEvent;
import openfl.text.TextField;
import reaxe.Component;
import reaxe.Element;
import reaxe.XmlRenderer;

class Main extends Component {
	var i = 1;
	var numbers: Array<Int> = [];

	public function new() {
		super();
		refresh();
	}
	
	private function onClick(e: MouseEvent) {
		numbers.push(i);
		refresh();
		i++;
	}
	
	private override function render(): Element {
		return XmlRenderer.render('Assets/components/Main.xml');
	}
}
```

```xml
	<Component>
		<TextField name="'myTextField'"
			text="'Click me to add a number to the list'"
			ref="(ref: TextField) -> ref.addEventListener(MouseEvent.CLICK, onClick)" />
		<TextField for="n : numbers"
			name="n + ''"
			text="n + ''"
			y="n * 20" />
	</Component>
```

In this example, a `TextField` is repeated for each item in an array. Notice how the name of this element is not a string literal. **When using a for construct, don't use constant names. Always use variables.** It's important because names must be unique, and if the name was constant it would cause duplicate names. **Names should be relative to the item in the list.** In this case, we can just use the number itself because each one is guaranteed to be unique, but if the list could contain duplicate items, then names would need to be obtained some other way. Also, notice how the name is `n + ''` and not just `n`. That's because **names must be strings**, and just `n` is a number, but concatenating it with an empty string makes it a string. The same is done for the `text` property.

## Actuation: Animating Properties

Sometimes, when a property changes, you don't want it to change immediately but rather to change over time. This is helpful for transition/tweens which can make an application more aesthetic. To make a property tween over time, instead of passing the value directly, pass a `reaxe.Actuation` object, which contains the value to tween to and the length of time for the transition. Such an object can be created with `new Actuation(<length>, <value>)`. For example:

```haxe
package;

import openfl.events.MouseEvent;
import openfl.text.TextField;
import reaxe.Actuation;
import reaxe.Component;
import reaxe.Element;
import reaxe.XmlRenderer;

class Main extends Component {
	private var transparency(null, set): Float = 1;
	
	private function set_transparency(transparency: Float): Float {
		this.transparency = transparency;
		refresh();
		return transparency;
	}

	public function new() {
		super();
		refresh();
	}
	
	private function onClick(e: MouseEvent) {
		transparency = 0;
	}
	
	private override function render(): Element {
		return XmlRenderer.render('Assets/components/Main.xml');
	}
}
```

```xml
<Component>
	<TextField name="'myTextField'"
		text="'Click to make me fade out'"
		alpha="new Actuation(1, transparency)"
		ref="(ref: TextField) -> ref.addEventListener(MouseEvent.CLICK, onClick)" />
</Component>
```

Notice how the `alpha` property is passed an `Actuation` instead of the value itself. The transition length is set to one second. **Warning: Since OpenFL stores colors as a single number, tweening colors may not work as expected.**

## That's it for This Guide

Now that you know how to use Reaxe, pair it with a UI toolkit like [Feathers UI](https://feathersui.com) and start making reactive interfaces with OpenFL.