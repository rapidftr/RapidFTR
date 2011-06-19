
$(function() {

  _.templateSettings = {
    interpolate : /\{\{(.+?)\}\}/g
  };

  window.Photo = Backbone.Model.extend({
    initialize: function() {
      this.selected = false;
    },

    makePrimaryPhoto: function() {
      $.ajax({
        url: this.get("select_primary_photo_url"),
        success: function() {
          alert("Set primary photo!");
        },
        type: "PUT"
      });
    },

    select: function() {
      if (this.isSelected()) {
        this.unselect();
      } else {
        Photos.unselectAll();
        this.selected = true;
        this.view.select();
      }
    },

    unselect: function() {
      this.selected = false;
      this.view.unselect();
    },

    isSelected: function() {
      return this.selected == true;
    },
  });

  window.PhotoList = Backbone.Collection.extend({
    model: Photo,

    unselectAll: function() {
      this.each(function(photo) {
        photo.unselect();
      });
    },

    getSelectedPhoto: function() {
      return this.find(function(photo) {
        return photo.isSelected();
      });
    }
  });

  window.Photos = new PhotoList;

  window.PhotoView = Backbone.View.extend({
    tagName: "div",

    // Cache the template function for a single item.
    template: _.template($('#photo-template').html()),

    initialize: function() {
      this.model.bind('change', this.render);
      this.model.view = this;
    },

    events: {
      "click .thumbnail": "clickThumbnail"
    },

    render: function() {
      $(this.el).html(this.template({thumbnail_url: this.model.get("thumbnail_url")}));
      return this;
    },

    select: function() {
      $(this.el).find(".thumbnail").addClass("selected");
    },

    unselect: function() {
      $(this.el).find(".thumbnail").removeClass("selected");
    },

    clickThumbnail: function() {
      this.model.select();
    }

  });

  window.AppView = Backbone.View.extend({

    // Instead of generating a new element, bind to the existing skeleton of
    // the App already present in the HTML.
    el: $(".thumbnails"),

    initialize: function() {
      _.bindAll(this, 'addOne', 'addAll');

      Photos.bind('add',     this.addOne);
      Photos.bind('refresh', this.addAll);

      $("#selectPrimaryPhotoButton").click(function() {
        var selectedPhoto = Photos.getSelectedPhoto();
        if (selectedPhoto) {
          selectedPhoto.makePrimaryPhoto();
        }
      });
    },

    addOne: function(photo) {
      var view = new PhotoView({model: photo});
      this.el.append(view.render().el);
    },

    addAll: function() {
      Photos.each(this.addOne);
    },

  });

  window.App = new AppView;

});
