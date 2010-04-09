@focus
Feature: As a mobile user
I want access to an xform for capturing child information
So that I can use a mobile client to capture child data

Scenario: model part of xform looks correct 
  When I go to the javarosa form for "rapid_ftr"
	Then I should see a superset of the following xml
	"""
	<html>
	  <head>
		  <title>RapidFTR Missing Child Form</title>
			<model>
				<instance>
				  <xform>
					  <name/>
						<age/>
						<age_is/>
						<gender/>
						<origin/>
						<last_known_location/>
						<date_of_separation/>
						<current_photo_key/>
					</xform>
				</instance>
			  <bind nodeset="/xform/name" type="string" />
			  <bind nodeset="/xform/age" type="string" />
			  <bind nodeset="/xform/current_photo_key" type="binary" />
			</model>
		</head>
	</html>
	"""

Scenario: body part of xform looks correct 
  When I go to the javarosa form for "rapid_ftr"
	Then I should see a superset of the following xml
	"""
	<html>
	  <body>
		  <input ref="name">
			  <label>Name</label>
		  </input>
		  <input ref="age">
			  <label>Age</label>
		  </input>
			<select1 ref="age_is">
			  <label>Age is</label>
				<item>
				  <label>Approximate</label>
				  <value>Approximate</value>
				</item>
				<item>
				  <label>Exact</label>
				  <value>Exact</value>
				</item>
			</select1>

			<select1 ref="gender">
			  <label>Gender</label>
				<item>
				  <label>Male</label>
				  <value>Male</value>
				</item>
				<item>
				  <label>Female</label>
				  <value>Female</value>
				</item>
			</select1>

			<upload ref="current_photo_key" mediatype="image/*">
				<label>Current photo key</label>
			</upload>

		</body>
	</html>
	"""
