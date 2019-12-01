component extends="framework.one"{
	this.name = "hibernate-montitor-app";
	
	ROOT_PATH = Replace(getDirectoryFromPath(getCurrentTemplatePath()), '\', '/', 'all');

	this.mappings["/plugins"] = ROOT_PATH & "plugins/";
	this.mappings["/models"] = ROOT_PATH & "models/";
	this.defaultdatasource="CarTracker";
	
	this.ormenabled = true;
	this.ormsettings = {
		cfclocation : "models/orm",
		datasource : "CarTracker",
		logsql : true,
		flushAtRequestEnd : true
	};

	variables.framework = {
		defaultSection = 'main',
		defaultItem = 'default',
		reload = 'reload',
		password = 'true',
		reloadApplicationOnEveryRequest = false,
		unhandledPaths = '/plugins/hibernateRequestMonitor',
		diLocations = "./models/orm,./models/services,./controllers",
		diConfig = {
			singulars : { orm : "bean" }
		},
		viewsFolder = "views"
	};

	public boolean function onRequestStart(required string targetPath) {
		super.onRequestStart(arguments.targetPath);
		application.hibernateMonitor.requestStart(this.getSectionAndItem(), targetPath);
		return true;
	}

	public void function onRequestEnd(required string targetPath) {
		application.hibernateMonitor.requestEnd();
		super.onRequestEnd(arguments.targetPath);
		setting showdebugoutput = false;
	}

	public void function setupRequest() {

	}
	
	/**
	 * Use the custom template engine to dump any errors in the view or layout where they occured.
	 */
	public any function customTemplateEngine( string type, string path, struct args ) {
		var response = '';
		structAppend( local, arguments.args );
		if(!local.keyExists('path')) {
			if(arguments.keyExists('path')) {
				local.path = arguments.path;
			} else if (arguments.keyExists('viewPath')) {
				local.path = arguments.viewPath;
			} else if (arguments.keyExists('layoutPath')) {
				local.path = arguments.layoutPath;
			}
		}

		if (!local.keyExists('path') || !len(local.path)) {
			savecontent variable="response" {
				writedump('Unable to resolve path');
				writedump(arguments);
			}
			return response;
		}

		try {
			savecontent variable="response" {
				include '#local.path#';
			}
		} catch (any e) {
			savecontent variable="response" {
				writedump(e);
			}
		}

		return response;	
	}

	public void function onError(any exception) {
		writedump(var="An error has occured");
		writedump(var="#exception#", top="10", format="html");
	}

	public void function setupApplication() {
		ormReload();
		application.rootPath = ROOT_PATH;
		application.beanfactory = this.getBeanFactory();
		application.hibernateMonitor = new plugins.hibernateRequestMonitor.models.hibernateMonitor({
			requestFilter: function(requestName, requestPath) {
				return !findNoCase('hibernateRequestMonitor', requestName);
			},
			path: '/plugins/hibernateRequestMonitor',
			clientPath: '/plugins/hibernateRequestMonitor'
		});
	}
}