component accessors="true" {
	property name="requestId" type="string";
	property name="requestName" type="string";
	property name="insertCount" type="numeric";
	property name="loadCount" type="numeric";
	property name="deleteCount" type="numeric";
	property name="updateCount" type="numeric";
	property name="fetchCount" type="numeric";
	property name="ormQueryStatistics" type="array";
	property name="entityStatistics" type="array";
	property name="executedQueries" type="query";
	property name="executedQueryCount" type="numeric";
	property name="requestStart" type="numeric";
	property name="requestTime" type="numeric";
	property name="flushCount" type="numeric";
	property name="transactionCount" type="numeric";
	property name="collisions" type="array";

	public component function init(required component monitor, required string requestId = "", string requestName = "") {

		this.setOrmQueryStatistics([])
			.setOrmQueryStatistics([])
			.setEntityStatistics([])
			.setCollisions([])
			.setRequestStart(getTickCount())
			.setRequestName(requestName)
			.setRequestId(requestId);
		variables.monitor = arguments.monitor;
		variables.collisionLookup = {};
		return this;
	}

	public void function populateRequestStats() {
		var sessionFactory = ormGetSessionFactory();
		var statistics = sessionFactory.getStatistics();

		//enable stats
		statistics.setStatisticsEnabled(javacast("boolean",true));
		setInsertCount(statistics.getEntityInsertCount());
		setLoadCount(statistics.getEntityLoadCount());
		setDeleteCount(statistics.getEntityDeleteCount());
		setUpdateCount(statistics.getEntityUpdateCount());
		setUpdateCount(statistics.getEntityFetchCount());

		//grab the query stats
		for (var hql in statistics.getQueries()){
			var queryStatsObj = new ormQueryStats(hql);
			queryStatsObj.populateFromHibernateStatistics(statistics.getQueryStatistics(hql));
			getOrmQueryStatistics().append(queryStatsObj);
		}

		//grab the entity stats
		for (var entityName in statistics.getEntityNames()) {
			var entityStatsObj = new entityStats(entityName);
			entityStatsObj.populateFromHibernateStatistics(statistics.getEntityStatistics(entityName));
			if (entityStatsObj.hasAnyCounts()) {
				getEntityStatistics().append(entityStatsObj);
			}
		}

		populateGeneratedQueries();

		setFlushCount(statistics.getFlushCount());
		setTransactionCount(statistics.getTransactionCount());
		setRequestTime(getTickCount() - getRequestStart());

	}

	public void function populateGeneratedQueries() {
		if (variables.monitor.getSupportedFeatures().executedQueries) {

			tempFactory = createObject("java", "coldfusion.server.ServiceFactory");
			tempCfdebugger = tempFactory.getDebuggingService();
			tempDebugger = tempCfdebugger.getDebugger(); 
			qEvents = tempDebugger.getData();
			
			executedQueries = queryExecute("
				SELECT *
				FROM qEvents 
				WHERE type = 'ORMSqlQuery'
				",{},{
					dbtype: 'query'
				});
			
			for (var i = 1; i <= executedQueries.recordcount; i++) {
				//clean up the body so the queries are the same
				var body = executedQueries.body[i];
				var startSelect = find("select",body);
				executedQueries.body[i] = right(body,len(body)-startSelect+1);
			}

			executedQueries = queryExecute("
				SELECT body, template, line, stacktrace
				FROM executedQueries 
				WHERE type = 'ORMSqlQuery'
				",{},{
					dbtype: 'query'
				});
			setExecutedQueries(executedQueries);
		}
	}

	public void function addCollision(required string id, required string name) {
		if (!variables.collisionLookup.keyExists(id)) {
			getCollisions().append(name);
			variables.collisionLookup[id] = name;
		}
	}

	public numeric function getTotalFetchCount() {
		var entityStats = getEntityStatistics();
		var totalFetches = 0;
		for (var entity in entityStats) {
			var totalFetches += entity.getFetchCount();
		}
		return totalFetches;
	}

	public numeric function getTotalLoadCount() {
		var totalLoads = 0;
		for (var entity in getEntityStatistics()) {
			var totalLoads += entity.getLoadCount();
		}
		return totalLoads;
	}
}