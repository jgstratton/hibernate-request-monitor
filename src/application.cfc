component {
	this.name = "hibernate-montitor-app";
	
	ROOT_PATH = Replace(getDirectoryFromPath(getCurrentTemplatePath()), '\', '/', 'all');

	this.mappings["/plugins"] = ROOT_PATH & "plugins/";
	this.mappings["/models"] = ROOT_PATH & "models/";
	
	this.ormenabled = true;
	this.ormsettings = {
		cfclocation : "models/orm",
		datasource : "CarTracker",
		logsql : true,
		flushAtRequestEnd : true
	};

	public boolean function onApplicationStart() {
		setupApplication();
		return true;
	}

	public boolean function onRequestStart(required string targetPath) {
		if (isReloadRequest()) {
			setupApplication();
		}
		application.hibernateMonitor.requestStart(targetPath);
		return true;
	}

	public void function onRequestEnd(required string targetPath) {
		application.hibernateMonitor.requestEnd();
		setting showdebugoutput = false;
	}

	private void function setupApplication() {
		application.hibernateMonitor = new plugins.hibernateRequestMonitor.models.hibernateMonitor({
			requestFilter: function(requestName, requestPath) {
				return !findNoCase('hibernateRequestMonitor', requestName);
			},
			path: '/plugins/hibernateRequestMonitor',
			clientPath: '/plugins/hibernateRequestMonitor'
		});
	}

	private boolean function isReloadRequest() {
		return isDefined('URL')  && URL.keyExists('reload') && URL.reload == 'true';
	}
}