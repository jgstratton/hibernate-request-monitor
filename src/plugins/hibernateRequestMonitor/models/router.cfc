component accessors="true" {
	property name="path";
	property name="monitor";
	property name="apiController";

	public component function init(struct config = {}) {
		for (var property in config) {
			variables[property] = config[property];
		}
		variables.apiController = createObject( 'component', getDotPath() & ".controller.api").init({
			monitor: variables.monitor
		});

		return this;
	}

	public string function processRoute() {
		var context = {};
		
		if ( isDefined('URL') ) {
			context.append(URL);
		}
		
		if ( isDefined('FORM')) {
			context.append(form);
		}

		var output = '';
		if (context.keyExists('api')) {
			output = runApi(context);
		} else {
			output = getView('views/requestLog.cfm');
		}

		writeOutput(output);
	}

	public string function runApi(required struct context) {
		cfheader(name="Content-Type", value="application/json");

		var response = invoke(getApiController(), "get" & context.api, {context: context});
		return serializeJSON(response,'struct',false);
	}
	
	public string function getView(required string viewPath) {
		var response = '';
		savecontent variable="response" {
			include '#getPath()#/#viewPath#';
		}
		return response;
	}

	private string function getDotPath() {
		var dotPath = replace(path,"/",".","all");
		if(left(dotPath,1) == ".") {
			dotPath = right(dotPath,len(dotPath)-1);
		}
		return dotPath;
	}
}