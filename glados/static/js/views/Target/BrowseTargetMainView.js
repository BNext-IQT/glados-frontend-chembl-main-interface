// Generated by CoffeeScript 1.4.0
var BrowseTargetMainView;

BrowseTargetMainView = Backbone.View.extend({
  events: {
    'click [type="checkbox"]': 'openAll'
  },
  initialize: function() {
    this.listView = TargetBrowserApp.initBrowserAsList(this.model, $('#BCK-TargetBrowserAsList'));
    return this.circlesView = TargetBrowserApp.initBrowserAsCircles(this.model, $('#BCK-TargetBrowserAsCircles'));
  },
  openAll: function() {
    return console.log('open all');
  }
});
