component output="false" accessors="false" persistent="true" modifier="final" {
    
    property name="id"			    type="string"	getter="true"	setter="false";
	property name="name"			type="string"	getter="true"	setter="false";
	property name="password"		type="string"	getter="true"	setter="false";
	property name="salt"			type="string"	getter="true"	setter="false";
	property name="displayName"		type="string"	getter="true"	setter="false";
    
    property name="sessionID"		type="string"	getter="true"	setter="true";
    property name="token"   		type="string"	getter="true"	setter="true";
    
	public User function init(required struct data) {
		if (structKeyExists(data, "dummy")) return this;

        variables.id = arguments.data.id;
		variables.name = arguments.data.name;
		variables.password = arguments.data.password;
		variables.salt = arguments.data.salt;
		variables.displayName = arguments.data.displayName;

		return this;
	}
}