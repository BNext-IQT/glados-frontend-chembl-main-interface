// Generated by CoffeeScript 1.4.0
var WizardOptionView;

WizardOptionView = Backbone.View.extend({
  initialize: function() {
    return this.render();
  },
  render: function() {
    var template;
    template = this.typeToTemplate[this.model.get('type')];
    return $(this.el).html(Handlebars.compile($(template).html())({
      title: this.model.get('title'),
      description: this.model.get('description'),
      link: this.model.get('link'),
      icon: this.model.get('icon')
    }));
  },
  typeToTemplate: {
    'icon': '#Handlebars-DownloadWizard-option-icon',
    'image': '#Handlebars-DownloadWizard-option-image'
  }
});
