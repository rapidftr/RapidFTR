describe("Manage Users", function() {
  describe("Change user disabled status", function() {
    var ajaxSpy;
    beforeEach(function() {
      loadFixtures('manage_users.html');
      ManageUsers.init();
      window.Users.refresh([{
        'user_url' : "isdisabled/url",
        'user_name': "isdisabled",
        'token'    : "sometoken"
      },
      {
        'user_url' : "isenabled/url",
        'user_name': "isenabled",
        'token'    : "sometoken"
      }]);

      ajaxSpy = sinon.spy(jQuery, "ajax");
    });

    afterEach(function() {
      jQuery.ajax.restore();
    });

    describe("When it is confirmed", function(){
      var clickAndConfirmCheckbox = function(userRow){
        var checkBox = $(userRow + ' input.user-disabled-status');
        checkBox.click();
        checkBox.change();
        $('#modal-dialog').parent().find('button:first').click();
      };

      var expectAjaxIsCalledWith = function(obj){
        expect(ajaxSpy).toHaveBeenCalled();
        var ajaxArgs = ajaxSpy.getCall(0).args[0];
        expect(ajaxArgs.type).toEqual("PUT");
        expect(ajaxArgs.url).toEqual(obj.url);
        expect(ajaxArgs.data["user[disabled]"]).toEqual(obj.newStatus);
        expect(ajaxArgs.data["authenticity_token"]).toEqual(obj.token);
      };

      it("should set enabled user to be disabled", function() {
        clickAndConfirmCheckbox("#user-row-isenabled");
        expectAjaxIsCalledWith({
          url: "isenabled/url",
          newStatus: "true",
          token: "sometoken"
        });
      });


      it("should set disabled user to be enabled", function() {
        clickAndConfirmCheckbox("#user-row-isdisabled");
        expectAjaxIsCalledWith({
          url: "isdisabled/url",
          newStatus: "false",
          token: "sometoken"
        });
      });
    });

    describe("When it was not confirmed", function(){
      var clickAndCancelCheckbox = function(userRow){
        var checkBox = $(userRow + ' input.user-disabled-status');
        checkBox.click();
        checkBox.change();
        $('#modal-dialog').parent().find('button:last').click();
      };

      it("should not perform update", function(){
        clickAndCancelCheckbox("#user-row-isdisabled");
        clickAndCancelCheckbox("#user-row-isenabled");
        expect(ajaxSpy).not.toHaveBeenCalled();
      });

      it("should reset the checkbox to its previous state", function(){
        clickAndCancelCheckbox("#user-row-isdisabled");
        var checkBox = $('#user-row-isdisabled input.user-disabled-status');
        expect(checkBox.attr('checked')).toEqual(true);
      });
    });

  });
});
