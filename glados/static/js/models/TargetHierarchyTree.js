// Generated by CoffeeScript 1.4.0
var TargetHierarchyTree;

TargetHierarchyTree = Backbone.Model.extend({
  defaults: {
    'children': new TargetHierarchyChildren,
    'all_nodes': new TargetHierarchyChildren
  },
  initialize: function() {
    return this.on('change', this.initHierarhy, this);
  },
  initHierarhy: function() {
    var addOneNode, all_nodes, children_col, node, plain, _i, _len, _ref;
    console.log('file loaded ' + new Date());
    plain = {};
    plain['name'] = this.get('name');
    plain['children'] = this.get('children');
    this.set('plain', plain, {
      silent: true
    });
    all_nodes = new TargetHierarchyChildren;
    children_col = new TargetHierarchyChildren;
    addOneNode = function(node_obj, children_col, parent) {
      var child_obj, grand_children_coll, new_node, _i, _len, _ref, _results;
      grand_children_coll = new TargetHierarchyChildren;
      new_node = new TargetHierarchyNode({
        name: node_obj.name,
        id: node_obj.id,
        parent: parent,
        children: grand_children_coll,
        size: node_obj.size
      });
      children_col.add(new_node);
      all_nodes.add(new_node);
      if (node_obj.children != null) {
        _ref = node_obj.children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child_obj = _ref[_i];
          _results.push(addOneNode(child_obj, grand_children_coll, new_node));
        }
        return _results;
      }
    };
    _ref = this.get('children');
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      node = _ref[_i];
      if (node != null) {
        addOneNode(node, children_col, void 0);
      }
    }
    this.set('all_nodes', all_nodes, {
      silent: true
    });
    this.set('children', children_col, {
      silent: true
    });
    return console.log('structures loaded!' + new Date());
  }
});
