<%@ Page Language="C#" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Simple Chocolatey Repository</title>
    <style>
        body { font-family: Calibri; }
    </style>
</head>
<body>
    <div>
        <h2>You are running a Simple Chocolatey Package Repository</h2>
        <img src="<%= VirtualPathUtility.ToAbsolute("~/Content/images/chocolatey.png") %>" width="80" height="80" alt="chocolatey logo" />
        
        <p>
            View your <a href="<%= VirtualPathUtility.ToAbsolute("~/chocolatey/Packages") %>">packages</a>.
        </p>
        <fieldset style="width:800px">
            <legend><strong>Repository URLs</strong></legend>
            In the package manager settings, add the following URL to the list of 
            Package Sources:
            <blockquote>
                <strong><%= Helpers.GetPushUrl(Request.Url, Request.ApplicationPath) %>chocolatey</strong>
            </blockquote>
            <% if (String.IsNullOrEmpty(ConfigurationManager.AppSettings["apiKey"])) { %>
            To enable pushing packages to this feed using the chocolatey (choco.exe), you must set the apiKey in the configuration.
            <% } %> 
            <% else { %>
            Use the command below to push packages to this feed using chocolatey (choco.exe).
            <% } %>
            <blockquote>
                <strong>choco push [{package file}] --source="<%= Helpers.GetPushUrl(Request.Url, Request.ApplicationPath) %>" [--api-key={apikey}]</strong>
            </blockquote> 
            You can set the ApiKey for this repository with 
             <blockquote>
                <strong>choco setapikey --source="<%= Helpers.GetPushUrl(Request.Url, Request.ApplicationPath) %>" --api-key={apikey}</strong>
            </blockquote>            
        </fieldset>

        <% if (Request.IsLocal) { %>
        <fieldset style="width:800px">
            <legend><strong>Administrator Information</strong></legend>
            <h1>The following settings are only shown when accessed from a localhost url</h1>
            <p style="font-size:1.1em">
                To add packages to the feed put package files (.nupkg files) in the folder "<% = NuGet.Server.Infrastructure.PackageUtility.PackagePhysicalPath%>".
            </p>
            <p style="font-size:1.1em">
                The ApiKey for this repository is set to <strong><%=ConfigurationManager.AppSettings["apiKey"]%></strong><br />
                Please set that using the setapikey command above, substituting that value for '{apikey}'.
            </p>
            <p style="font-size:1.1em">
                View your <a href="<%= VirtualPathUtility.ToAbsolute("~/elmah.axd") %>">elmah logs</a>.
            </p>
            <p style="font-size:1.1em">
                Package size limit is set to a default of 2GB, but is adjustable. See maxAllowedContentLength in the web.config.
            </p>
        </fieldset>
        <% } %>
        <h5>Based on NuGet.Server v<%= typeof(NuGet.Server.DataServices.Package).Assembly.GetName().Version %></h5>
    </div>
</body>
</html>
