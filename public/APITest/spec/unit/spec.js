/* 		
	Beware:	
	
	parameters sent with the ajax calls are written like this:
	
	child[parameter1]:something
	
	This is because JSpec apparently can't handle when you write the parameters in real object syntax:
	
	child { parameter1: something }
	
	Real object notation will work fine when doing pure JQuery calls. Annoying, but true
	 
____________________________________________________________________________ */

describe 'API Test'

	var token
	var childid
	var response = {}
	var parameters = {}

	$.ajaxSetup({async:false})
	
	before_each
		response = {}
		parameters = {}
	end
	
	it 'should return a autentication token'
	
		parameters = {user_name: "ronze", password: "Enurmadsen1"}
		
		$.ajax({
			url: "http://localhost:3000/sessions",
			dataType: 'json',
			data: parameters,
			type: 'POST',
			cache: false,
			success: function(data)
			{
				response = data
		    },
			complete: function(request, textStatus) 
			{
				token = $.cookie('rftr_session_token')
			}
		})
		
		response.should.not.be_empty
		response.user_name.should.eql parameters.user_name
		
		token.should.not.be_empty
		
	end
	
	it 'should create a new child record'

		parameters = { "child[name]": "apichild", "child[last_known_location]": "New York City"}
		
		$.ajax({
			url: "http://localhost:3000/children",
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
			url: "http://localhost:3000/children",
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
			url: "http://localhost:3000/children/" + childid,
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
	
	it 'should update record of child with specified id'

		$.ajax({
			url: "http://localhost:3000/children/" + childid,
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

	it 'should return record of child with specified id'
	
		$.ajax({
			url: "http://localhost:3000/children/" + childid,
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