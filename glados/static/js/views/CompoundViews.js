// Generated by CoffeeScript 1.4.0
var CompoundNameClassificationView;

CompoundNameClassificationView = Backbone.View.extend({
  initialize: function() {
    this.model.on('change', this.render, this);
    return this.model.on('error', this.showErrorCard, this);
  },
  showErrorCard: function() {
    $(this.el).children('.card-preolader-to-hide').hide();
    return $(this.el).children('.card-load-error').show();
  },
  render: function() {
    var attributes;
    $(this.el).children('.card-preolader-to-hide').hide();
    $(this.el).children(':not(.card-preolader-to-hide, .card-load-error)').show();
    attributes = this.model.toJSON();
    this.renderTitle();
    this.renderPrefName();
    this.renderMaxPhase();
    this.renderMolFormula();
    this.renderImage();
    return this.renderSynonymsAndTradeNames();
  },
  renderTitle: function() {
    return $(this.el).find('#Bck-CHEMBL_ID').text(this.model.get('molecule_chembl_id'));
  },
  renderPrefName: function() {
    return $(this.el).find('#Bck-PREF_NAME').text(this.model.get('pref_name'));
  },
  renderMaxPhase: function() {
    var phase, phase_class, rendered, source, template;
    phase = this.model.get('max_phase');
    phase_class = 'comp-phase-' + phase;
    if (phase === 4) {
      phase += ' (Approved)';
    }
    source = '<span class="{{class}}"> {{text}} </span>';
    template = Handlebars.compile(source);
    rendered = template({
      "class": phase_class,
      text: phase
    });
    return $(this.el).find('#Bck-MAX_PHASE').html(rendered);
  },
  renderMolFormula: function() {
    return $(this.el).find('#Bck-MOLFORMULA').text(this.model.get('molecule_properties')['full_molformula']);
  },
  renderImage: function() {
    var img_url;
    img_url = 'https://www.ebi.ac.uk/chembl/api/data/image/' + this.model.get('molecule_chembl_id');
    return $(this.el).find('#Bck-COMP_IMG').attr('src', img_url);
  },
  renderSynonymsAndTradeNames: function() {
    var all_syns, syn_rendered, synonyms_source, tn_rendered, trade_names, tradenames_source, unique_synonyms;
    all_syns = this.model.get('molecule_synonyms');
    unique_synonyms = new Set();
    trade_names = new Set();
    $.each(all_syns, function(index, value) {
      if (value.syn_type === 'TRADE_NAME') {
        trade_names.add(value.synonyms);
      }
      return unique_synonyms.add(value.synonyms);
    });
    synonyms_source = '{{#each items}}' + ' <span class="CNC-chip-syn">{{ this }}</span> ' + '{{/each}}';
    syn_rendered = Handlebars.compile(synonyms_source)({
      items: Array.from(unique_synonyms)
    });
    $(this.el).find('#CompNameClass-synonyms').html(syn_rendered);
    tradenames_source = '{{#each items}}' + ' <span class="CNC-chip-tn">{{ this }}</span> ' + '{{/each}}';
    tn_rendered = Handlebars.compile(tradenames_source)({
      items: Array.from(trade_names)
    });
    return $(this.el).find('#CompNameClass-tradenames').html(tn_rendered);
  }
});
