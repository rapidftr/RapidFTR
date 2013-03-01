describe("Manage Photos", function() {
  beforeEach(function() {
    loadFixtures('manage_photos.html');
    ManagePhotos.init();
    window.Photos.refresh([{ 'photo_url': '/spec/resources/jorge.jpg', 'thumbnail_url': '/spec/resources/jorge.jpg', 'select_primary_photo_url': '/make/jorge/primary/photo'}]);
  });

  //demonstrates use of expected exceptions
  describe("choosing primary photo button", function() {
    var ajaxSpy;

    beforeEach(function() {
      ajaxSpy = sinon.spy(jQuery, "ajax");
    });

    afterEach(function() {
      jQuery.ajax.restore();
    });

    it("sets the currently selected photo as the primary photo", function() {
      $('.thumbnail').click();
      $('#selectPrimaryPhotoButton').click();

      expect(ajaxSpy).toHaveBeenCalled();
      expect(ajaxSpy.getCall(0).args[0].type).toEqual("PUT");
      expect(ajaxSpy.getCall(0).args[0].url).toEqual("/make/jorge/primary/photo");
    });

    it("doesn't do anything if no photo is selected", function() {
      $('#selectPrimaryPhotoButton').click();
      expect(ajaxSpy).not.toHaveBeenCalled();
    });
  });

  describe("viewing full size photo button", function() {
    var ajaxSpy;

    beforeEach(function() {
      windowSpy = sinon.spy(window, "open");
    });

    afterEach(function() {
      window.open.restore();
    });

    it("opens a new tab with the full size image", function() {
      $('.thumbnail').click();
      $('#viewFullSizePhotoButton').click();

      expect(windowSpy).toHaveBeenCalled();
      expect(windowSpy.getCall(0).args[0]).toEqual(window.Photos.getSelectedPhoto().attributes.photo_url);
    });

    it("doesn't do anything if no photo is selected", function() {
      $('#viewFullSizePhotoButton').click();
      expect(windowSpy).not.toHaveBeenCalled();
    });
  });
});
