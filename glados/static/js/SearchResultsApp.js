// Generated by CoffeeScript 1.4.0
var SearchResultsApp;

SearchResultsApp = (function() {

  function SearchResultsApp() {}

  SearchResultsApp.init = function() {
    SearchResultsApp.searchModel = null;
    this.initCompResultsListView($('#BCK-CompoundSearchResults'));
    this.initDocsResultsListView($('#BCK-DocSearchResults'));
    return this.search();
  };

  SearchResultsApp.getSearchModel = function() {
    if (!SearchResultsApp.searchModel) {
      SearchResultsApp.searchModel = new SearchModel;
    }
    return SearchResultsApp.searchModel;
  };

  SearchResultsApp.initCompResultsListView = function(top_level_elem) {
    var compResView;
    compResView = new CompoundResultsListView({
      collection: this.getSearchModel().getCompoundResultsList(),
      el: top_level_elem
    });
    return compResView;
  };

  SearchResultsApp.initDocsResultsListView = function(top_level_elem) {
    var docResView;
    docResView = new DocumentResultsListView({
      collection: this.getSearchModel().getDocumentResultsList(),
      el: top_level_elem
    });
    return docResView;
  };

  SearchResultsApp.initCompTargMatrixView = function(topLevelElem) {
    var compTargMatrixView;
    compTargMatrixView = new CompoundTargetMatrixView({
      el: topLevelElem
    });
    return compTargMatrixView;
  };

  SearchResultsApp.initCompResultsGraphView = function(topLevelElem) {
    var compResGraphView;
    compResGraphView = new CompoundResultsGraphView({
      el: topLevelElem
    });
    return compResGraphView;
  };

  SearchResultsApp.initCompoundTargetMatrix = function() {
    var ctm;
    ctm = new CompoundTargetMatrix;
    new CompoundTargetMatrixView({
      model: ctm,
      el: $('#CompTargetMatrix')
    });
    return ctm.fetch();
  };

  SearchResultsApp.search = function() {
    return this.getSearchModel().search();
  };

  return SearchResultsApp;

})();
