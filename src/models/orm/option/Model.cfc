component persistent="true" entityname="Model" table="Model" extends="models.orm.option.Base" {
	property name="ModelID" column="ModelID" fieldtype="id" generator="increment";
	property name="MakeID" column="MakeID";
	property name="Make" column="MakeID" fieldtype="many-to-one" cfc="models.orm.option.Make" fkcolumn="MakeID" missingrowignored="true" insert="false" update="false";
	public Model function init() {
		return this;
	}
} 