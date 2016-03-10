// Generated by CoffeeScript 1.4.0
var CompoundNameClassificationView;

CompoundNameClassificationView = Backbone.View.extend({
  render: function() {
    var attributes;
    attributes = this.model.toJSON();
    return this.renderTitle();
  },
  renderTitle: function() {
    return $(this.el).find('.Bck-CHEMBL_ID').text(this.model.get('chembl_id'));
  }
});
