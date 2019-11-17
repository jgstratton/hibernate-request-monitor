component accessors="true" {
	property name="hql" type="string";
	property name="count" type="numeric";
	property name="rowCount" type="numeric";
	property name="avgCount" type="numeric";
	property name="avgTime" type="numeric";
	property name="totalTime" type="numeric";

	public component function init(string hql = ""){
		setHql(hql);
		return this;
	}

	// populates from org.hibernate.stat.QueryStatistics 
	public void function populateFromHibernateStatistics(required any hibernateStatistics) {
		setCount(hibernateStatistics.getExecutionCount());
		setRowCount(hibernateStatistics.getExecutionRowCount());
		setAvgCount(hibernateStatistics.getExecutionRowCount() \ hibernateStatistics.getExecutionCount());
		setAvgTime(hibernateStatistics.getExecutionAvgTime());
		setTotalTime(hibernateStatistics.getExecutionAvgTime() * hibernateStatistics.getExecutionCount());
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