<%@ Page Language="C#" %>
<%@ Import Namespace="NuGet.Server" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>Simple Chocolatey Server (Internal Repository)</title>
    <style>
        body { font-family: Calibri; }
    </style>
</head>
<body>
    <div>
        <h2>You are running a Simple Chocolatey Package Repository v<%= typeof(ForReference).Assembly.GetName().Version %></h2>
        <img src="<%= VirtualPathUtility.ToAbsolute("~/Content/images/chocolatey.png") %>" width="80" height="80" alt="chocolatey logo" />
        <p>
            View your <a href="<%= VirtualPathUtility.ToAbsolute("~/chocolatey/Packages") %>">packages</a>.
        </p>
        <fieldset style="width:800px">
            <legend><strong>Repository URLs</strong></legend>
            In the package manager settings, add the following URL to the list of 
            Package Sources:
            <blockquote>
                <strong><%= Helpers.GetRepositoryUrl(Request.Url, Request.ApplicationPath) %></strong>
            </blockquote>
            <% if (string.IsNullOrEmpty(ConfigurationManager.AppSettings["apiKey"])) { %>
            To enable pushing packages to this feed using the <a href="https://chocolatey.org/">Chocolatey command line tool</a> (choco.exe), set the <code>apiKey</code> appSetting in web.config.
            <% } else { %>
            Use the command below to push packages to this feed using the <a href="https://chocolatey.org/">Chocolatey command line tool</a> (choco.exe).
            <blockquote>
                <strong>choco.exe push [{package file}] --source <%= Helpers.GetPushUrl(Request.Url, Request.ApplicationPath) %> [--api-key={apikey}]</strong>
            </blockquote>
            You can set the ApiKey for this repository with 
            <blockquote>
                <strong>choco setapikey --source="<%= Helpers.GetPushUrl(Request.Url, Request.ApplicationPath) %>" --api-key={apikey}</strong>
            </blockquote>  
            <% } %> 
        </fieldset>

        <% if (Request.IsLocal) { %>
        <fieldset style="width:800px">
            <legend><strong>Administrator Information</strong></legend>
            <h2>The following settings are only shown when accessed from a localhost url</h2>
            
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

            To add packages to the feed put package files (.nupkg files) in the folder "<code><% = NuGet.Server.Infrastructure.PackageUtility.PackagePhysicalPath %></code>". <br /><br />
            
            Click <a href="<%= VirtualPathUtility.ToAbsolute("~/chocolatey/clear-cache") %>">here</a> to clear the package cache.
        </fieldset>
        <% } %>
        <h5>Based on NuGet.Server v3.0.2<%--<%= typeof(NuGet.Server.DataServices.PackagesODataController).Assembly.GetName().Version %>--%></h5>
    </div>
</body>
</html>
