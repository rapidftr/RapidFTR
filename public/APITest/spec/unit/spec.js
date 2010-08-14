/* 		
	Beware:	
	
	parameters sent with the ajax calls are written like this:
	
	child[parameter1]:something
	
	This is because JSpec apparently can't handle when you write the parameters in real object syntax:
	
	child { parameter1: something }
	
	Real object notation will work fine when doing pure JQuery calls. Annoying, but true
	 
____________________________________________________________________________ */

describe 'API Test'

    urlPrefix = "http://" + window.location.host;

	var token;
	var childid;
	var response = {};
	var parameters = {};
    var request = {};

	$.ajaxSetup({async:false});
	
	before_each
		response = {};
		parameters = {};
        request = {};
	end
	
		it 'should return a autentication token'

		parameters = {user_name: "rapidftr", password: "rapidftr"}

		$.ajax({
			url: urlPrefix + "/sessions",
			dataType: 'json',
			data: parameters,
			type: 'POST',
			cache: false,
			success: function(data, status)
			{
				response = data
		    },
			complete: function(xmlHttpRequest)
			{
                request = xmlHttpRequest;
                token = response.session.token

			}
		});

        request.status.should.eql 201
		response.should.not.be_empty
		token.should.not.be_empty

	end

    it 'should return 401 not authorized when authenticating with invalid password'

		parameters = {user_name: "rapidftr", password: "wrongpassword"};

		$.ajax({
			url: urlPrefix + "/sessions",
			dataType: 'json',
			data: parameters,
			type: 'POST',
			cache: false,
			complete: function(xmlHttpRequest)
			{
                request = xmlHttpRequest;

			}
		});

        request.status.should.eql 401
	end
	
	it 'should create a new child record'

		parameters = { "child[name]": "apichild", "child[last_known_location]": "New York City"}
		
		$.ajax({
			url: urlPrefix + "/children",
			dataType: 'json',
			type: 'POST',
			cache: false,
			data: parameters,
			beforeSend: function(request)
			{
				request.setRequestHeader('Authorization', "RFTR_Token " + token)
			},
			success: function(data)
			{
				response = data
		    }
		})
		
		response.should.not.be_empty
		response.should.have_property "name"
		response.should.have_property "last_known_location"
		response.name.should.eql parameters["child[name]"]
		response.last_known_location.should.eql parameters["child[last_known_location]"]
		
		childid = response._id
		
	end

	it 'should return list of all children in database'

		$.ajax({
			url: urlPrefix + "/children",
		  	dataType: 'json',
			cache: false,
			beforeSend: function(request)
			{
				request.setRequestHeader('Authorization', "RFTR_Token " + token)
			},
		  	success: function(data)
			{
				//alert(data.toSource());
				
				response = data
		    }
		})
		
		response.should.not.be_empty
		response.should.be_a Array
		
	end

	it 'should return record of child with specified id'

		$.ajax({
			url: urlPrefix + "/children/" + childid,
		  	dataType: 'json',
			cache: false,
			beforeSend: function(request)
			{
				request.setRequestHeader('Authorization', "RFTR_Token " + token)
			},
		  	success: function(data)
			{
				//alert(data.toSource());

				response = data
		    }
		})

		response.should.not.be_empty
		response.should.have_property "name"
		response.should.have_property "last_known_location"

	end

    it 'should return 401 not authorized when making a request with invalid token'

        $.ajax({
            url: urlPrefix + "/children/" + childid,
              dataType: 'json',
            cache: false,
            beforeSend: function(request)
            {
                request.setRequestHeader('Authorization', "RFTR_Token " + "Invalid token")
            },
            complete: function(xmlHttpRequest)
            {
                request = xmlHttpRequest;
            }
        })

        request.status.should.eql 401
    end

	it 'should update record of child with specified id'

		$.ajax({
			url: urlPrefix + "/children/" + childid,
			dataType: 'json',
			type: 'PUT',
			cache: false,
			data: { "child[name]": "apichild renamed" },
			beforeSend: function(request)
			{
				request.setRequestHeader('Authorization', "RFTR_Token " + token)
			},
			success: function(data)
			{
				//alert(data.toSource());
				
				response = data
		    }
		})
		
		response.should.not.be_empty
		response.should.have_property "name"
		response.should.have_property "last_known_location"
		
	end

	it 'should delete record of child with specified id'
	
		$.ajax({
			url: urlPrefix + "/children/" + childid,
			dataType: 'json',
			type: 'DELETE',
			cache: false,
			beforeSend: function(request)
			{
				request.setRequestHeader('Authorization', "RFTR_Token " + token)
			},
			success: function(data)
			{
				//alert(data.toSource());
				
				response = data
		    }
		})
		
		response.should.not.be_empty
		response.response.should.eql "ok"
	
	end

end
