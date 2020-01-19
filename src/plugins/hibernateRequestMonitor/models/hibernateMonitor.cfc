/**
 * This monitor takes the hibernate statistics and breaks them up by request.  It is only a dev tool.  It's not thread save 
 * and will not work as expected when multiple requests are being made simulaneously.  It's meant as a means of debugging 
 * orm.
 * 
 * To wire into application:
 * 
 * 1 - Initialize the component in the application
 * 2 - Call the request start and request end in application.cfc
 * 3 - If using fw1, add path to unhandled requests.
 */

 component accessors="true" {
	property name="maxRequests" type="numeric" default="100";
	property name="requestFilter" type="function";
	property name="path" type="string" default="";
	property name="clientPath" type="string";
	property name="router";
	property name="errors" type="array";
	property name="supportedFeatures" type="struct" setter="false";
	property name="debugEnabled" type="boolean";

	/**
	 * When initializing the component, the caller can pass a config 
	 * struct to set the default property values.
	 */
	public component function init(struct config = {}){
		variables.requestHistory = [];
		variables.requestLookup = {};
		variables.collisions = {};
		variables.errors = [];
		variables.debugEnabled = false;
		variables.requestFilter = function(requestString, requestPath) {
			return true;
		};
		variables.logger = {
			debug: function(debugText){
				writeLog(type="debug", file="hrm", text="#debugText#"); 
			}
		};

		for (var property in config) {
			variables[property] = config[property];
		}
		variables.router = new router({
			path: this.getPath(),
			monitor: this
		});

		determineSupportedFeatures();
		return this;
	}

	/**
	 * This function needs to be run at the start of the request.  
	 * The request name is not required but recommended so we can
	 * search/filter/sort by request.
	 */
	public void function requestStart(string requestName = "", string requestPath = ""){
		try {
			lock name="hibernateRequestMonitor_lifecycle" timeout="10" {
				//fw1 deletes the lifecycle methods for unhandled paths so we need to completely ignore any requests to the plugin
				if (requestIsPluginPath(requestPath)) {
					debug('Request to plugin ignored: #requestName#, #requestPath#');
					return;
				}

				if (!variables.requestFilter(requestName, requestPath)) {
					debug('Request ignored by filter: #requestName#, #requestPath#');
					return;
				}

				setMonitoredRequest();

				if (isNull(variables.currentRequest)) {
					var sessionFactory = ormGetSessionFactory();
					var statistics = sessionFactory.getStatistics();
					statistics.clear();
					variables.currentRequest = new requestStats(this, getRequestId(), requestName);
					debug('Started monitoring new request: #requestName#, #requestPath#');

					if (structCount(variables.collisions)) {
						for (var collisionId in variables.collisions) {
							variables.currentRequest.addCollision(collisionId, variables.collisions[collisionId]);
						}
						debug("#structCount(variables.collisions)# existing collision requests added to new monitored request");
					}
					
				} else {
					debug('request monitoring in progress, adding collision: #requestName#, #requestPath#');
					variables.collisions[getRequestId()] = requestName;
					variables.currentRequest.addCollision(getRequestId(), variables.collisions[getRequestId()]);
				}

			}
		} catch(any e) {
			addError(e);
		}
	}

	/**
	 * This function needs to be run at the end of the request. It grabs 
	 * the current request's statistics and adds it to the request history.
	 */
	public void function requestEnd() {
		lock name="hibernateRequestMonitor_lifecycle" timeout="10" {

			if (!isMonitoredRequest()){
				debug("Request not monitored");
				return;
			}

			if (!variables.keyExists('currentRequest')) {
				debug("No current monitored request exists");
				if (variables.collisions.keyExists(getRequestId())) {
					variables.collisions.delete(getRequestId());
					debug("Collision request cleared");
				}
				return;
			}

			if (variables.collisions.keyExists(getRequestId())) {
				debug("Adding collision to currently running request");
				variables.currentRequest.addCollision(getRequestId(), variables.collisions[getRequestId()]);
				variables.collisions.delete(getRequestId());
				return;
			}

			debug("Saving statistics for monitored request");
			variables.currentRequest.populateRequestStats();

			//if we've reached the max Requests, then delete the oldest before adding a new request
			if (variables.requestHistory.len() > getMaxRequests()) {
				debug("Max history reached, deleting oldest entry");
				variables.requestLookup.delete(variables.requestHistory[1]);
				variables.requestHistory.deleteAt(1);
			}
			variables.requestHistory.append(variables.currentRequest);
			variables.requestLookup[variables.currentRequest.getRequestId()] = variables.currentRequest;
			variables.delete('currentRequest');

			debug("Monitored request completed");
		}
	}

	/**
	 * This returns the entire requestHistory array and all it's data.
	 */
	public array function getRequestStatistics(){
		return variables.requestHistory;
	}

	/**
	 * This returns the request history fall all requests that occured after the given request ID
	 */
	public array function getNewRequestStatistics(required string lastKnownRequestId) {
		var startIndex = 1;
		var requestLength = variables.requestHistory.len();
		for (var i = requestLength; i > 0; i--) {
			if (variables.requestHistory[i].getRequestId() == lastKnownRequestId) {
				startIndex = i + 1;
				break;
			}
		}
		return variables.requestHistory.slice(startIndex, requestLength);
	}

	/**
	 * Gets the entity statistics for all stats in the request history
	 */
	public query function getEntityStatisticsData() {
		var returnArray = [];
		for (var requestStatistics in requestHistory) {
			for (var entityStatistics in requestStatistics.getEntityStatistics()) {
				var dataStruct = entityStatistics.toStruct();
				dataStruct.append({
					'requestStart': requestStatistics.getRequestStart(),
					'requestTime' : requestStatistics.getRequestTime(),
					'requestName': requestStatistics.getRequestName()
				});
				returnArray.append(dataStruct);
			}
		}
		return arrayOfStructuresToQuery(returnArray);
	}

	/**
	 * Gets the hql statistics for the ormExecuteQueries
	 */
	public query function getOrmQueryStatisticsData() {
		var returnArray = [];
		for (var requestStatistics in requestHistory) {
			for (var ormQueryStatistics in requestStatistics.getOrmQueryStatistics()) {
				var dataStruct = ormQueryStatistics.toStruct();
				dataStruct.append({
					'requestStart': requestStatistics.getRequestStart(),
					'requestTime' : requestStatistics.getRequestTime(),
					'requestName': requestStatistics.getRequestName(),
					'percentOfRequest' : numberformat(ormQueryStatistics.getTotalTime() / requestStatistics.getRequestTime() * 100, "0")
				});
				returnArray.append(dataStruct);
			}
		}
		return arrayOfStructuresToQuery(returnArray);
	}
	
	/**
	 * Get the request by id
	 */
	public any function getRequestById(required string requestId) {
		if(variables.requestLookup.keyExists(requestId)) {
			return variables.requestLookup[requestId];
		}
	}

	//clear all the statistics
	public void function resetStatistics() {
		variables.requestHistory = [];
	}

	public void function addError(required any error) {
		getErrors().append(error);
	}

	private boolean function requestIsPluginPath(required string requestPath) {
		if (findNoCase(getPath(),requestPath)) {
			return true;
		}
		return false;
	}

	private void function debug(required string logText) {
		if(getDebugEnabled()) {
			var requestId = isMonitoredRequest() ? "[#getRequestId()#]" : "";
			variables.logger.debug("#requestId# #logtext#");
		}
	}

	private boolean function isMonitoredRequest() {
		return request.keyExists('_hibernateRequestMonitor_id');
	}

	private void function setMonitoredRequest() {
		request._hibernateRequestMonitor_id = CreateUUID();
	}

	private string function getRequestId() {
		return request._hibernateRequestMonitor_id;
	}

	private void function getNull() {
		return;
	}

	
	/**
	 * The actual executed queries (sql) is logged in the qEvents in ColdFusion. In Lucee, I haven't found a way to
	 * get the sql.  With a hibernate interceptor we should be able to get the sql in the OnPrepareStatement method, but
	 * I can't figure out how to apply my own interceptor with the exposed orm methods.  For now, Lucee implementations
	 * will just display the executed query count using the orm statistics.
	 */
	private void function determineSupportedFeatures() {
		try {
			tempFactory = createObject("java", "coldfusion.server.ServiceFactory");
			tempCfdebugger = tempFactory.getDebuggingService();
			tempDebugger = tempCfdebugger.getDebugger(); 
			qEvents = tempDebugger.getData();
			variables.supportedFeatures.executedQueries = true;
		} catch (any e) {
			variables.supportedFeatures.executedQueries = false;
		}
	}

	public boolean function isFeatureSupported(required string featureName) {
		var supportedFeatures = getSupportedFeatures();
		return supportedFeatures.keyExists(featureName) && supportedFeatures[featureName];
	}

	/**
	* Converts an array of structures to a CF Query Object.
	* http://cflib.org/udf/ArrayOfStructuresToQuery
	* @param Array 	 The array of structures to be converted to a query object. Assumes each array element contains structure with same (Required)
	* @return Returns a query object.
	* @author David Crawford (dcrawford@acteksoft.com)
	* @version 2, March 19, 2003
	*/
	private query function arrayOfStructuresToQuery(required array sourceArray, string listOfColumnsForEmptyArray = "", string listOfDataTypesForColumns = ""){
		var returnQuery = queryNew(arguments.listOfColumnsForEmptyArray);

		//if there's nothing in the array, return the empty query
		if(!sourceArray.len()) {
			return returnQuery;
		}

		//get the column names into an array =
		var colNames = structKeyArray(sourceArray[1]);
		//build the query based on the colNames
		if (len(listOfDataTypesForColumns)) {
			returnQuery = queryNew(arrayToList(colNames), listOfDataTypesForColumns);
		} else {
			returnQuery = queryNew(arrayToList(colNames));
		}

		//add the right number of rows to the query
		queryAddRow(returnQuery, arrayLen(sourceArray));

		//for each element in the array, loop through the columns, populating the query
		for(var i = 1; i <= arrayLen(sourceArray); i++){
			for(var j = 1; j <= arrayLen(colNames); j++){
				if(!structKeyExists(sourceArray[i],colNames[j]) || isNull(sourceArray[i][colNames[j]])) {
					querySetCell(returnQuery, colNames[j], "", i);
				}else {
					querySetCell(returnQuery, colNames[j], sourceArray[i][colNames[j]], i);
				}
			}
		}
		return returnQuery;
	}
}