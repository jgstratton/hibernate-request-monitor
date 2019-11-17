component {
	property name="monitor";

	public component function init(struct config = {}) {
		for (var property in config) {
			variables[property] = config[property];
		}
		return this;
	}

	public struct function getExecutedQueries(required struct context) {
		var requestStatistic = monitor.getRequestById(context.requestId);
		if (!local.keyExists('requestStatistic')) {
			return {
				'success':false,
				'error': 'Request data not found.'
			};
		}
		var allQueries = requestStatistic.getExecutedQueries();

		var groupedQueries = queryExecute("
			Select count(*) as counts, body, line, template
			From allQueries
			Group by body, line, template
			Order by counts desc, template, line", {},{
				dbtype: 'query'
			});
		return {
			'result': 'ok',
			'data': groupedQueries};
	}
	
	public struct function getEntityStatistics() {
		var requestStatistics = monitor.getRequestById(context.requestId);
		var data = [];

		if (!local.keyExists('requestStatistics')) {
			return {
				'success':false,
				'error': 'Request data not found.'
			};
		}

		for (var entityStat in requestStatistics.getEntityStatistics()) {
			data.append(entityStat.toStruct());
		}
		return {
			'result': 'ok',
			'data': data
		};
	}

	public struct function getQueryStatistics() {
		var requestStatistics = monitor.getRequestById(context.requestId);
		var data = [];

		if (!local.keyExists('requestStatistics')) {
			return {
				'success':false,
				'error': 'Request data not found.'
			};
		}

		for (var qryStat in requestStatistics.getOrmQueryStatistics()) {
			data.append(qryStat.toStruct());
		}
		data.sort(function(a,b) {
			return a.totalTime > b.totalTime;
		});
		return {
			'result': 'ok',
			'data': data
		};
	}
}