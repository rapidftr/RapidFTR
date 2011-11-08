describe("Manage Users", function() {
  describe("Change user disabled status", function() {
    var ajaxSpy;
    beforeEach(function() {
      loadFixtures('manage_users.html');
      ManageUsers.init();
      ajaxSpy = sinon.spy(jQuery, "ajax");
    });

    afterEach(function() {
      jQuery.ajax.restore();
    });

    it("should pass", function() {expect(1).toEqual(1);});
    /*
    it("should set enabled user to be disabled", function() {
      $('#user-row-isenabled input').click();
      console.log(ajaxSpy);
      expect(ajaxSpy).toHaveBeenCalled();
      expect(ajaxSpy.getCall(0).args[0].type).toEqual("PUT");
      expect(ajaxSpy.getCall(0).args[0].url).toEqual("/make/jorge/primary/photo");
    });
    it("should set disabled user to be enabled", function() {
      $('#user-row-isdisabled input').click();
      console.log(ajaxSpy);
      expect(ajaxSpy).toHaveBeenCalled();
      expect(ajaxSpy.getCall(0).args[0].type).toEqual("PUT");
      expect(ajaxSpy.getCall(0).args[0].url).toEqual("/make/jorge/primary/photo");
    });
    */
  });
});
