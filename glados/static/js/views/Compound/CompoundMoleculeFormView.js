// Generated by CoffeeScript 1.4.0
var CompoundMoleculeFormView;

CompoundMoleculeFormView = Backbone.View.extend({
  tagName: 'div',
  className: 'col s6 m4 l3',
  initialize: function() {
    return this.model.on('change', this.render, this);
  },
  render: function() {
    var colour;
    colour = this.model.get('molecule_chembl_id') === CHEMBL_ID ? 'teal lighten-5' : '';
    $(this.el).html(Handlebars.compile($('#Handlebars-Compound-AlternateFormCard').html())({
      molecule_chembl_id: this.model.get('molecule_chembl_id'),
      colour: colour
    }));
    return this;
  }
});
