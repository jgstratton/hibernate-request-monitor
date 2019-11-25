# Hibernate Request Monitor

This is a simple dev tool to view hibernate statistics in a ColdFusion application. This repo includes both the plugin tool (/plugins/hibernateRequestMonitor) and small FW1 to show how it's used. The ORM components used in the demo app are from ortussolution's cborm demo app, found at https://github.com/coldbox-samples/Pink-Unicorns-Do-Exist.

# Instructions (Running the Demo App)

### Step 1 : CommandBox

You will need CommandBox installed in your machine in order to install and run dependencies.

_Get CommandBox_ : https://www.ortussolutions.com/products/commandbox

### Step 2 : Database Setup

This sample application was built using MySQL 5 and you can find the file `CarTracker.sql` in the **worbench** folder of the application that you can use to pre-load your application.

### Step 3 : Environment

This application is pre-configured to use CFConfig for loading the database into the engine and environment variables for connectivity. Copy the `.env.template` and rename it to `.env`. Open it and add your credentials for your MySQL database:

```env
DB_HOST=localhost
DB_USERNAME=root
DB_PASSWORD=mysql
DB_PORT=3306
```

In order for these env files and the cfconfig files to work, you must have the commandbox modules installed, so type the following in your shell:

```bash
box install commandbox-cfconfig,commandbox-dotenv
```

### Step 4: Dependencies

Go in to the CommandBox shell by typing `box` and enter. Then type `install` to configure all the necessary dependencies for this application.

### Step 5: Run it!

That's it, just run the application via CommandBox by typing `server start`. This will open the browser to http://localhost:3000. The port **3000** is configured inside the `server.json` file.

# Instructions (Using the plugin)

### Step 1 : Add the Plugin

Copy the /plugins/hibernateRequestMonitor to the folder of your choice inside your app.

### Step 2 : Configure your application to enable debugging

You need to make sure that debugging is enabled. Also make sure that orm sql is being logged `this.ormsettings.logsql = true`

### Step 3 : Create an instance of the monitor

Instantiate the hibernateMonitor. You can define a filter function that takes the requestName and requestPath as
arguments. This can be used to determine which requests you want to keep stats for. By default it will log stats for
all requests. You also need to define the path and client path to the folder where the plugin is located.

```
application.hibernateMonitor = new plugins.hibernateRequestMonitor.models.hibernateMonitor({
	requestFilter: function(requestName, requestPath) {
		return !findNoCase('hibernateRequestMonitor', requestName);
	},
	path: '/plugins/hibernateRequestMonitor',
	clientPath: '/plugins/hibernateRequestMonitor'
});
```

Note, if you are using FW1, you will also need ot add the path to the unhandled paths.

### Step 4: Wire into the application lifecycle methods

In order to track the statistics by request, you need to call the requestStart and the requestEnd in the onRequestStart and onRequestEnd methods of the application.cfc. In the requestStart, the hibernate method will clear the existing orm stats. In the requestEnd method it will gather the statistics and group it with the request by name/id.

```
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
```

### Step 5: View the request statistics

To view the request stats, browse to the folder where the plugin is installed.
