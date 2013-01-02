fr_index_popover_handler = {
  popover_cache: {},
  base_url: 'https://www.federalregister.gov/api/v1/articles/',
  fields: 'fields%5B%5D=title&fields%5B%5D=toc_subject&fields%5B%5D=toc_doc',
  current_el: null,

  initialize: function() {
    return this;
  },

  url: function() {
    return this.base_url + this.current_el.data('document-number') + '.json?' + this.fields;
  },

  get_popover_content: function(el) {
    var popover_handler = this;
    popover_handler.current_el = el;
  
    if( popover_handler.popover_cache[popover_handler.current_el.data('document-number')] === undefined ) {
      $.ajax({
        url: popover_handler.url(),
        dataType: 'jsonp'
      }).done(function(response) {
        popover_handler.ajax_done(response);
      });
    } else {
      popover_handler.add_popover_content();
    }
  },

  ajax_done: function(response) {
    this.popover_cache[this.current_el.data('document-number')] = response;
    this.add_popover_content();
  },

  add_popover_content: function() {
    var $tipsy_el = $('.tipsy'),
        prev_height = $tipsy_el.height(),
        fr_index_entry_popover_content_template = Handlebars.compile($("#fr-index-entry-popover-content-template").html()),
        popover_id = '#popover-' + this.current_el.data('document-number'),
        new_html = fr_index_entry_popover_content_template( this.popover_cache[this.current_el.data('document-number')] );

    $(popover_id).find('.loading').replaceWith( new_html );

    // bacause we modify the content we need to calculate a new top based on the new height of the popover
    var new_top = parseInt($tipsy_el.css('top'), 10) - ( ($tipsy_el.height() - prev_height) / 2 );
    $tipsy_el.css('top', new_top);
  }
};

