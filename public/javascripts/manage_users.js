var ManageUsers = ManageUsers || {};

ManageUsers.init = function () {
  window.User = Backbone.Model.extend ({
    changeDisabledStatus: function(disabledStatus) {
      var userAttributes = {"user[disabled]": disabledStatus, "authenticity_token": this.token()};
      $.ajax({
        url: this.url(),
        type: "PUT",
        data: userAttributes
      });
    },

    user_name: function() {
      return this.get("user_name");
    },

    token: function() {
      return this.get("token");
    },

    url: function() {
      return this.get("user_url");
    },

  });

  window.UserList = Backbone.Collection.extend ({
    model: User,

    getUser: function(userName) {
      return this.find(function(user) {
        return user.user_name() == userName;
      });
    }

  });

  window.Users = new UserList;

  window.AppView = Backbone.View.extend({
    el: $('table'),

    events: {
      "change input.user-disabled-status": "confirmChangeDisabledStatus"
    },

    getUserName: function(evt) {
      return $(evt.target).parents('.user-status').siblings('.user-name').text();
    },

    toggleDisabledStatus: function(user) {
      return (!user.disabled()).toString();
    },

    getDisabledStatus: function(evt){
      return $(evt.target).attr('checked');
    },

    confirmChangeDisabledStatus: function(evt){
      var userName   = this.getUserName(evt);
      var nextStatus = this.getDisabledStatus(evt) ? "disable" : "enable";
      $('#modal-dialog').dialog('option', {
        newStatus: this.getDisabledStatus(evt).toString(),
        userName : userName,
        title    : "Are you sure you want to " + nextStatus + " this user?"
      });
      $('#modal-dialog').dialog("open");
    },

    changeDisabledStatus: function(userName, newStatus){
      var user = Users.getUser(userName);
      user.changeDisabledStatus(newStatus);
    },

    toggleCheckbox: function(userName){
      var checkBox = $('#user-row-' + userName + ' input.user-disabled-status');
      if(checkBox.attr('checked')){
        checkBox.removeAttr('checked');
      } else {
        checkBox.attr('checked', 'checked');
      }
    },
  });

  window.App = new AppView;

  //create confirm dialog box
  $('#modal-dialog').dialog({
    autoOpen: false,
    modal: true,
    buttons: {
      "Yes" : function() {
        var opt = $(this).dialog('option');
        window.App.changeDisabledStatus(opt.userName, opt.newStatus);
        $(this).dialog("close");
      },
      "Cancel" : function() {
        var opt = $(this).dialog('option');
        window.App.toggleCheckbox(opt.userName);
        $(this).dialog("close");
      }
    }
  });


};

$(function() {
  ManageUsers.init();
});
