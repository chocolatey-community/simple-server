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
            View your <a href="<%= VirtualPathUtility.ToAbsolute("~/chocolatey/Packages") %>">packages</a> (Atom-based feed, will show up differently in different browsers. Some will show it as raw XML, while others will understand the contents and render it in a nicely formatted structure. Depending on your browser, there may be extensions that can help with the rendering of the content).
        </p>
        <p>
            To interact with this repository, you will be using Chocolatey from client machines.
        </p>
        <fieldset style="width:800px">
            <legend><strong>Information</strong></legend>
            <h3>Querying / Installing Packages</h3>
            <p>
                Add the following URL to the list of <a href="https://chocolatey.org/docs/commands-source">Chocolatey sources</a>:
                <blockquote>
                    <strong><%= Helpers.GetRepositoryUrl(Request.Url, Request.ApplicationPath) %></strong>
                </blockquote>
                Example: <code>choco source add --name=internal_machine --source=<%= Helpers.GetRepositoryUrl(Request.Url, Request.ApplicationPath) %></code><br />
                For more examples and switches, please see <a href="https://chocolatey.org/docs/commands-source">the source command</a>.<br />
                To add authentication, please see additional instructions ("Administrator Information" section) when you connect to this repo from localhost.
            </p>
            
            <h3>Adding/Pushing Packages</h3>
            <% if (string.IsNullOrEmpty(ConfigurationManager.AppSettings["apiKey"])) { %>
                To enable <a href="https://chocolatey.org/docs/commands-push">pushing packages</a> to this repository using the <a href="https://chocolatey.org/">Chocolatey command line tool</a> (choco.exe), set the <code>apiKey</code> appSetting in web.config.
            <% } else { %>
                To add the <a href="https://chocolatey.org/docs/commands-apikey">package push API key</a> to the client machines you use for packaging, use the following:
                <blockquote>
                    <strong>choco apikey --source="<%= Helpers.GetPushUrl(Request.Url, Request.ApplicationPath) %>" --api-key={apikey}</strong>
                </blockquote>
                Use the command below to <a href="https://chocolatey.org/docs/commands-push">push packages to this repository</a>:
                <blockquote>
                    <strong>choco push [{package file}] --source <%= Helpers.GetPushUrl(Request.Url, Request.ApplicationPath) %> [--api-key={apikey}]</strong>
                </blockquote>
            <% } %>

            <h3>Installing Chocolatey On Client Machines</h3>
            <ul>
                <li>Note the url used here is different from the url the scripts use on the <a href="https://chocolatey.org/install">Install page</a> of https://chocolatey.org.</li>
                <li>Check the <a href="https://chocolatey.org/install">official install documentation</a> page for requirements, etc.</li>
                <li>Choose PowerShell.exe, cmd.exe, or to install with an integrated tool like Boxstarter, Ansible, Chef, Puppet, SCCM, etc.</li>
            </ul>   
                    
                <p>PowerShell.exe - copy and paste the following into the shell and press enter:<br />
                    <blockquote>
                        <code>Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('<%= Request.Url.GetLeftPart(UriPartial.Authority) + VirtualPathUtility.ToAbsolute("~/") + "install.ps1" %>'))</code>
                    </blockquote>
                </p> 
                <p>Cmd.exe - copy and paste the following into cmd.exe and press enter:<br />
                    <blockquote>
                        <code>@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('<%= Request.Url.GetLeftPart(UriPartial.Authority) + VirtualPathUtility.ToAbsolute("~/") + "install.ps1" %>'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"</code>
                    </blockquote>
                </p>
                
                <p>Integrations:
                    When using <a href="https://chocolatey.org/docs/features-infrastructure-automation">Infrastructure Management Tools</a>, ensure you've put a chocolatey.nupkg on this repository.<br />
                    <ul>
                        <li><a href="https://www.ansible.com/"></a>Ansible - use <a href="https://docs.ansible.com/ansible/latest/modules/win_chocolatey_module.html">win_chocolatey module</a>. Support for internal/offline install was added in the 2.7 release. Set the module option <code>source</code> to <%= Helpers.GetRepositoryUrl(Request.Url, Request.ApplicationPath) %>. Once Chocolatey is installed, <a href="https://docs.ansible.com/ansible/latest/modules/win_chocolatey_source_module.html">win_chocolatey_source_module</a> can be used to configure this server as a package source.</li>
                        <li><a href="http://www.boxstarter.org/">Boxstarter</a> - installing Chocolatey is built-in to Boxstarter.</li>
                        <li><a href="https://www.chef.io/">Chef</a> - use <a href="https://supermarket.chef.io/cookbooks/chocolatey">Chocolatey cookbook</a> to ensure installation. Go to <a href="<%= Helpers.GetRepositoryUrl(Request.Url, Request.ApplicationPath) %>/Packages()?$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion" target="_blank">Chocolatey Search</a> and find <code>&lt;content type="application/zip" /&gt;</code> - copy the entire src url. Then set the attribute <code>node['chocolatey']['install_vars']['chocolateyDownloadUrl']</code> to that value.</li>
                        <li><a href="https://docs.microsoft.com/en-us/powershell/dsc/overview">PowerShell DSC</a> - use <a href="https://www.powershellgallery.com/packages/cChoco/2.3.1.0">cChoco DSC resource</a>. Set <code>cChocoInstaller</code>'s <code>ChocoInstallScriptUrl</code> to <%= Request.Url.GetLeftPart(UriPartial.Authority) + VirtualPathUtility.ToAbsolute("~/") + "install.ps1" %></li>
                        <li><a href="https://puppet.com">Puppet</a> - use <a href="https://forge.puppet.com/puppetlabs/chocolatey">puppetlabs/chocolatey</a>. Go to <a href="<%= Helpers.GetRepositoryUrl(Request.Url, Request.ApplicationPath) %>/Packages()?$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion" target="_blank">Chocolatey Search</a> and find <code>&lt;content type="application/zip" /&gt;</code> - copy the entire src url. That's what you will provide to <code>class {'chocolatey': chocolatey_download_url }</code>. See specific instructions at <a href="https://chocolatey.org/install#install-with-puppet">Install with Puppet</a> for examples.</li>
                        <li><a href="https://saltstack.com/">Salt</a> - use <a href="https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.chocolatey.html">Salt.Modules.Chocolatey</a>. The bootstrap doesn't support offline install - subscribe, vote, and comment on <a href="https://github.com/saltstack/salt/issues/45969">Salt issue #45969</a> for progress. There is a <a href="https://controlaltfail.wordpress.com/2017/08/03/salt-chocolatey-install-totally-offline/">workaround</a> available.</li>
                        <li>Others - use install script url: <%= Request.Url.GetLeftPart(UriPartial.Authority) + VirtualPathUtility.ToAbsolute("~/") + "install.ps1" %></li>
                    </ul>
                </p>
        </fieldset>

        <% if (Request.IsLocal) { %>
        <fieldset style="width:800px">
            <legend><strong>Administrator Information</strong></legend>
            <h2>The following settings are only shown when accessed from a localhost url</h2>

            <strong>NOTE: For organizational use, we want your experience with Chocolatey to be completely reliable, and that is not possible with the <a href="https://chocolatey.org/packages">community repository</a> or any reliance on the internet. That includes the installation of Chocolatey itself. The information/instructions here will get you set up for an internal experience.</strong>
           
            <h3>Chocolatey Install Script</h3>
            <p style="font-size:1.1em">
               The <a href="<%= VirtualPathUtility.ToAbsolute("~/install.ps1") %>" target="_blank">install script</a> for Chocolatey in this repository is dynamic - it will use this repo if you have the chocolatey.nupkg here (otherwise it uses the default community repo location). To make that happen, <a href="https://chocolatey.org/install#completely-offline-install" target="_blank">Go get the chocolatey.nupkg</a> and put it in the "<% = NuGet.Server.Infrastructure.PackageUtility.PackagePhysicalPath %>" directory. <br />
            </p>
        
            <h3>API Key (Pushing Packages)</h3>
            <ul style="font-size:1.1em">
                <li>The API key for this repository is set to <strong><%=ConfigurationManager.AppSettings["apiKey"]%></strong></li>
                <li>To set that API key on clients, please use the <code>choco apikey</code> command above, substituting '{apikey}' with the actual API key.</li>
                <li>To change the API key for this repository, you will need to do so in the web.config directly. Under <code>appSettings</code>, find <code>apiKey</code>.</li>
            </ul>
        
            <h3>Authentication (Querying / Using Packages)</h3>
            <ul style="font-size:1.1em">
                <li>This repository has basic authentication ready to be turned on.</li>
                <li>Users are managed directly in the web.config file.</li>
                <li>For instructions, please see the comments surrounding the <code>httpAuth</code> section of the web.config file.</li>
                <li>Please make sure you use SSL certificates so passwords are not sent in clear text.</li>
            </ul>
        
            <h3>Logs</h3>
            <p style="font-size:1.1em">
                View your <a href="<%= VirtualPathUtility.ToAbsolute("~/elmah.axd") %>">elmah logs</a>.
            </p>

            <h3>Packages</h3>
            <ul style="font-size:1.1em">
                <li>Package size limit is set to a default of 2GB, but is adjustable. See <code>maxAllowedContentLength</code> in the web.config. That said, attempting to use <code>choco push</code> with packages over 1GB may timeout/fail. But you can directly copy those packages to the package folder.</li>
                <li>To add packages to the repository put package files (.nupkg files) in the folder "<% = NuGet.Server.Infrastructure.PackageUtility.PackagePhysicalPath %>" or use <a href="https://chocolatey.org/docs/commands-push"><code>choco push</code></a>.</li>
                <li>Clear and rebuild the package information cache: <a href="<%= VirtualPathUtility.ToAbsolute("~/chocolatey/clear-cache") %>">clear cache</a>. This rebuilds the Lucene index that ensures responses stay quite fast, it doesn't delete any nupkg files.</li>
                <li>To change the packages folder, please see <code>packagesPath</code> in the web.config</li>
                <li>By default, you can't <a href="https://chocolatey.org/docs/how-to-host-feed#package-version-immutability">replace an existing package version</a>. This is recommended for <a href="https://chocolatey.org/docs/how-to-host-feed#package-version-immutability">package version immutability</a> and your sanity. If you absolutely understand what you are doing and want to enable replacing existing versions, please think about it a little longer. Then think about it some more as it is a very bad idea. Then set <code>allowOverrideExistingPackageOnPush</code> in <code>appSettings</code> to true. This is what causes the HTTP 406 return code.</li>
                <li>To delist (soft delete) packages in this repo, please use <code>nuget.exe delete</code>. Chocolatey doesn't have an unlist/remove command.</li>
                <li>To remove a package completely, just remove the nupkg from the package directory directly. NOTE: you may need to clear the cache afterwards.</li>
            </ul>
            
            <h3>Building Packages</h3>
            <ul style="font-size:1.1em">
                <li>The best way to get started creating packages is to run <code>choco new test</code> with at least Chocolatey v0.10.8 (or the latest) and look at the _TODO.txt and other output the default template produces. There is a lot of interweaved documentation to give you that "just in time" documentation kind of feel.</li>
                <li>Do not look at the <a href="https://chocolatey.org/packages">community repository</a> as an example for building packages, they are done that way due to constraints of a public repository. Make your packages fully reliable - embed the binaries.</li>
                <li><a href="https://chocolatey.org/docs/features-create-packages-from-installers">Package Builder</a> (Recommended) - For a "right click, create fully unnattended software deployment package in 5 seconds" kind of experience.</li>
            </ul>

            <h3>Internalize Community Packages, Don't Just Cache</h3>
            <span style="font-size:1.1em">If you copy packages (aka cache packages) into this repository from the <a href="https://chocolatey.org/packages">community repository</a>, the package(s) may still need to use the internet at runtime to download software <a href="https://chocolatey.org/docs/community-packages-disclaimer">due to distribution rights with a public repository</a>. We recommend internalizing packages you want to reuse if you find they don't contain the software they represent. There are two ways to internalize packages:</span>
            <ul style="font-size:1.1em">
                <li><a href="https://chocolatey.org/docs/how-to-recompile-packages">Manually</a> - includes a walkthrough</li>
                <li><a href="https://chocolatey.org/docs/features-automatically-recompile-packages">Package Internalizer</a> (Recommended) - scriptable, can be hooked up to automation like CI servers (Jenkins, TeamCity, etc) or scheduled tasks <a href="https://chocolatey.org/docs/features-automatically-recompile-packages#resources">easily</a>.</li>
            </ul>
        </fieldset>
        <% } %>
        <h5>Based on NuGet.Server v3.0.2<%--<%= typeof(NuGet.Server.DataServices.PackagesODataController).Assembly.GetName().Version %>--%></h5>
    </div>
</body>
</html>
