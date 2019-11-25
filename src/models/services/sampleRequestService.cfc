/**
 * Dropping sample cfm files into the views/sampleRequest folder should automatically add the file 
 * to the navigation menu.
 */
component accessors="true"{

	/**
	 * Get all links for the sample requests
	 */
	public array function getSampleRequestsArray() {
		var sampleRequestFiles = getFilesInSampleRequestsFolder();
		var sampleRequests = [];

		for (var fileName in sampleRequestFiles) {
			sampleRequests.append( {
				name: getViewNameFromFileName(fileName),
				path: getUrlFromFileName(fileName)
			});
		}

		return sampleRequests;
	}

	private array function getFilesInSampleRequestsFolder() {
		return directoryList("#getRequestsDir()#", false, "name");
	}

	private string function getUrlFromFileName(required string fileName) {
		var fileNameArray = listToArray(fileName,".");
		var viewName = fileNameArray[1];
		return getFramework().buildUrl("sampleRequests.#viewName#");
	}

	private string function getViewNameFromFileName(required string filename) {
		var fileNameArray = listToArray(fileName,".");
		return fileNameArray[1];
	}

	private string function getRequestsDir() {
		return "#application.rootPath#views/sampleRequests";
	}

	private component function getFramework() {
		return application.beanFactory.getBean("fw");
	}
}