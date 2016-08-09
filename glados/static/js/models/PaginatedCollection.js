// Generated by CoffeeScript 1.4.0
var PaginatedCollection;

PaginatedCollection = Backbone.Collection.extend({
  setMeta: function(attr, value) {
    this.meta[attr] = parseInt(value);
    return this.trigger('meta-changed');
  },
  getMeta: function(attr) {
    return this.meta[attr];
  },
  resetPageSize: function(new_page_size) {
    if (new_page_size === '') {
      return;
    }
    this.setMeta('page_size', new_page_size);
    this.setMeta('current_page', 1);
    this.calculateTotalPages();
    this.calculateHowManyInCurrentPage();
    return this.trigger('do-repaint');
  },
  resetMeta: function() {
    console.log('resetting meta');
    this.setMeta('total_records', this.models.length);
    this.setMeta('current_page', 1);
    this.calculateTotalPages();
    this.calculateHowManyInCurrentPage();
    return this.resetSortData();
  },
  calculateTotalPages: function() {
    var total_pages;
    total_pages = Math.ceil(this.models.length / this.getMeta('page_size'));
    return this.setMeta('total_pages', total_pages);
  },
  calculateHowManyInCurrentPage: function() {
    var current_page, page_size, total_pages, total_records;
    current_page = this.getMeta('current_page');
    total_pages = this.getMeta('total_pages');
    total_records = this.getMeta('total_records');
    page_size = this.getMeta('page_size');
    if (total_pages === 1) {
      return this.setMeta('records_in_page', total_records);
    } else if (current_page === total_pages) {
      return this.setMeta('records_in_page', total_records % page_size);
    } else {
      return this.setMeta('records_in_page', this.getMeta('page_size'));
    }
  },
  getCurrentPage: function() {
    var current_page, end, page_size, records_in_page, start, to_show;
    page_size = this.getMeta('page_size');
    current_page = this.getMeta('current_page');
    records_in_page = this.getMeta('records_in_page');
    start = (current_page - 1) * page_size;
    end = start + records_in_page;
    to_show = this.models.slice(start, +end + 1 || 9e9);
    this.setMeta('to_show', to_show);
    return to_show;
  },
  setPage: function(page_num) {
    this.setMeta('current_page', page_num);
    return this.trigger('do-repaint');
  },
  sortCollection: function(comparator) {
    var col, columns, is_descending, _i, _len;
    console.log('sort');
    this.comparator = comparator;
    columns = this.getMeta('columns');
    is_descending = false;
    for (_i = 0, _len = columns.length; _i < _len; _i++) {
      col = columns[_i];
      if (col.comparator === comparator) {
        col.is_sorting = (function() {
          switch (col.is_sorting) {
            case 0:
              return 1;
            default:
              return -col.is_sorting;
          }
        })();
        is_descending = col.is_sorting === -1;
      } else {
        col.is_sorting = 0;
      }
      col.sort_class = (function() {
        switch (col.is_sorting) {
          case -1:
            return 'fa-sort-desc';
          case 0:
            return 'fa-sort';
          case 1:
            return 'fa-sort-asc';
        }
      })();
    }
    if (is_descending) {
      this.sort({
        silent: true
      });
      this.models = this.models.reverse();
      return this.trigger('sort');
    } else {
      return this.sort();
    }
  },
  resetSortData: function() {
    var col, columns, _i, _len, _results;
    this.comparator = void 0;
    columns = this.getMeta('columns');
    _results = [];
    for (_i = 0, _len = columns.length; _i < _len; _i++) {
      col = columns[_i];
      col.is_sorting = 0;
      _results.push(col.sort_class = 'fa-sort');
    }
    return _results;
  },
  getPaginatedURL: function(url) {
    var current_page, limit_str, page_size, page_str;
    page_size = this.getMeta('page_size');
    current_page = this.getMeta('current_page');
    limit_str = 'limit=' + page_size;
    page_str = 'offset=' + (current_page - 1) * page_size;
    return url + '&' + limit_str + '&' + page_str;
  }
});
