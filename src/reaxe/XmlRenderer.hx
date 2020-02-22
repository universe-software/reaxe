package reaxe;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.File;

class XmlRenderer {
    public static macro function render(path: String): Expr {
        var xml = Xml.parse(File.getContent(path));
        var list = new Array<Xml>();
        getAll(xml.firstChild(), list);
        var map = new Map<Xml, Expr>();

        while(!(satisfied(xml.firstChild(), map) && map.exists(xml.firstChild()))) {
            for(node in list) {
                if(!map.exists(node) && satisfied(node, map)) {
                    var e: Expr;

                    var children = new Array<Expr>();

                    for(child in node.iterator()) {
                        if(child.nodeType == Xml.Element)
                            children.push(map[child]);
                    }

                    var properties = new Array<Expr>();

                    for(attribute in node.attributes()) {
                        if(attribute != 'if' && attribute != 'for')
                            properties.push(macro $v{attribute} => ${Context.parse(node.get(attribute), Context.currentPos())});
                    }

                    e = macro new Element($i{node.nodeName}, $a{properties}, $a{children});

                    if(node.exists('for')) {
                        var regex = ~/^(.+?)\s*:\s*(.+?)$/;

                        if(!regex.match(node.get('for')))
                            throw 'Invalid syntax of for attribute';

                        var name = regex.matched(1);
                        var listExpr = regex.matched(2);

                        e = macro [for($i{name} in ${Context.parse(listExpr, Context.currentPos())}) ${e}];
                    }

                    if(node.exists('if'))
                        e = macro ${Context.parse(node.get('if'), Context.currentPos())} ? ${e} : null;

                    if(node == xml.firstChild() || node.exists('for'))
                        map[node] = e;
                    else
                        map[node] = macro [${e}];
                }
            }
        }

        return map[xml.firstChild()];
    }

    private static function getAll(xml: Xml, list: Array<Xml>) {
        if(xml.nodeType == Xml.Element) {
            list.push(xml);

            for(child in xml.iterator())
                getAll(child, list);
        }
    }

    private static function satisfied(xml: Xml, map: Map<Xml, Expr>): Bool {
        for(child in xml.iterator()) {
            if(child.nodeType == Xml.Element && !map.exists(child))
                return false;
        }

        return true;
    }
}