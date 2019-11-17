component accessors="true" {
	property name="entityName" type="string";
	property name="loadCount" type="numeric" default="0";
	property name="updateCount" type="numeric" default="0";
	property name="insertCount" type="numeric" default="0";
	property name="deleteCount" type="numeric" default="0";
	property name="fetchCount" type="numeric" default="0";

	public component function init(string entityName = ""){
		setEntityName(entityName);
		return this;
	}

	// populates from org.hibernate.stat.EntityStatistics
	public void function populateFromHibernateStatistics(required any hibernateStatistics) {
		setLoadCount(hibernateStatistics.getLoadCount());
		setUpdateCount(hibernateStatistics.getUpdateCount());
		setInsertCount(hibernateStatistics.getInsertCount());
		setDeleteCount(hibernateStatistics.getDeleteCount());
		setFetchCount(hibernateStatistics.getFetchCount());
	}

	public boolean function hasAnyCounts() {
		var meta = getMetaData(this);
		for (var property in meta.properties) {
			if (findNoCase('Count',property.name) && invoke(this, "get#property.name#") > 0) {
				return true;
			}
		}
		return false;
	}

	public struct function toStruct() {
		var returnStruct = {};
		var meta = getMetaData(this);
		for (var property in meta.properties) {
			returnStruct[property.name] = invoke(this, "get#property.name#");
		}
		return returnStruct;
	}
}