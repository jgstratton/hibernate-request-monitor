component persistent="true" entityname="Position" table="Position" extends="models.orm.option.Base" {
	// primary key
	property name="PositionID" column="PositionID" fieldtype="id" generator="increment";
	// non-relational columns
	
	// one-to-one
	
	// one-to-many
	
	// many-to-one
	
	// many-to-many
	
	// calculated properties
	
	// object constraints
	
	// methods
	public Position function init() {
		return this;
	}
} 