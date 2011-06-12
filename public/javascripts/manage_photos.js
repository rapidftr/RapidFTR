
$(function() {

  _.templateSettings = {
    interpolate : /\{\{(.+?)\}\}/g
  };

  window.Photo = Backbone.Model.extend({
    initialize: function() {
    }
  });

  window.PhotoList = Backbone.Collection.extend({
    model: Photo
  });

  window.Photos = new PhotoList;

  window.PhotoView = Backbone.View.extend({
    tagName: "div",

    // Cache the template function for a single item.
    template: _.template($('#photo-template').html()),

    initialise: function() {
      _.bindAll(this, 'render', 'close');
      this.model.bind('change', this.render);
      this.model.view = this;
    },

    events: {
      "mouseover .thumbnail": "mouseover"
    },

    render: function() {
      $(this.el).html(this.template({thumbnail_uri: this.model.get("thumbnail_uri")}));
      return this;
    },

    mouseover: function() {
      // $(this.el).html("<b>Book!</b>");
    }

  });

  window.AppView = Backbone.View.extend({

    // Instead of generating a new element, bind to the existing skeleton of
    // the App already present in the HTML.
    el: $(".thumbnails"),

    initialize: function() {
      _.bindAll(this, 'addOne', 'addAll');

      // this.input    = this.$("#new-todo");

      Photos.bind('add',     this.addOne);
      Photos.bind('refresh', this.addAll);
    },

    addOne: function(photo) {
      var view = new PhotoView({model: photo});
      this.el.append(view.render().el);
    },

    addAll: function() {
      Photos.each(this.addOne);
    },

  });

  // Finally, we kick things off by creating the **App**.
  window.App = new AppView;

});
