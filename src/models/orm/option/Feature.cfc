component persistent="true" entityname="Feature" table="Feature" extends="models.orm.option.Base" {
	// primary key
	property name="FeatureID" column="FeatureID" fieldtype="id" generator="increment";
	// non-relational columns
	
	// one-to-one
	
	// one-to-many
	
	// many-to-one
	
	// many-to-many
	
	// calculated properties
	
	// object constraints
	
	// methods
	public Feature function init() {
		return this;
	}
} 