using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SimpleChocolateyServer.Contollers
{
    using System.Net;
    using System.Web.Http;
    using NuGet.Server.V2.Model;

    public class InstallController : ApiController
    {

        [HttpGet]
        public IHttpActionResult DownloadPowerShellInstallScript()
        {
            var thisUrl = Request.RequestUri.GetLeftPart(UriPartial.Authority) + VirtualPathUtility.ToAbsolute("~/");
            var url = Request.RequestUri.GetLeftPart(UriPartial.Authority) + VirtualPathUtility.ToAbsolute("~/");
            var apiPath = "chocolatey";

            var localChocolateyPackageFound = false;

            //find local package installed
            var client = new WebClient();
            var htmlOutput = client.DownloadString(url + apiPath + "/Packages()?$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion");

            if (htmlOutput.IndexOf("<content type=\"application/zip\"", 0, StringComparison.OrdinalIgnoreCase) >= 0)
            {
                localChocolateyPackageFound = true;
            }

            // otherwise use remote Chocolatey location
            if (!localChocolateyPackageFound)
            {
                url = "https://chocolatey.org/";
                apiPath = "api/v2";
            }

            return new PlainTextResult(InstallScript(url, apiPath, thisUrl), Request);
        }

        public string InstallScript(string url, string apiPath, string thisUrl)
        {
            return @"# =====================================================================
# Copyright 2017-2018 Chocolatey Software, Inc, and the
# original authors/contributors from ChocolateyGallery
# Copyright 2011 - 2017 RealDimensions Software, LLC, and the
# original authors/contributors from ChocolateyGallery
# at https://github.com/chocolatey/chocolatey.org
#
# Licensed under the Apache License, Version 2.0 (the ""License"");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an ""AS IS"" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# =====================================================================

$searchUrl = '[[URL]][[API_PATH]]/Packages()?$filter=((Id%20eq%20%27chocolatey%27)%20and%20(not%20IsPrerelease))%20and%20IsLatestVersion'
$7zipUrl = '[[THIS_URL]]7za.exe'
$unzipMethod = '7zip'

Write-Output ""Getting latest version of the Chocolatey package for download.""
[xml]$result = Download-String $searchUrl
$url = $result.feed.entry.content.src

if ($env:TEMP -eq $null) {
  $env:TEMP = Join-Path $env:SystemDrive 'temp'
}
$chocTempDir = Join-Path $env:TEMP ""chocolatey""
$tempDir = Join-Path $chocTempDir ""chocInstall""
if (![System.IO.Directory]::Exists($tempDir)) {[void] [System.IO.Directory]::CreateDirectory($tempDir)}
$file = Join-Path $tempDir ""chocolatey.zip""

# PowerShell v2/3 caches the output stream. Then it throws errors due
# to the FileStream not being what is expected. Fixes ""The OS handle's
# position is not what FileStream expected. Do not use a handle
# simultaneously in one FileStream and in Win32 code or another
# FileStream.""
function Fix-PowerShellOutputRedirectionBug {
  $poshMajorVerion = $PSVersionTable.PSVersion.Major

  if ($poshMajorVerion -lt 4) {
    try{
      # http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/ plus comments
      $bindingFlags = [Reflection.BindingFlags] ""Instance,NonPublic,GetField""
      $objectRef = $host.GetType().GetField(""externalHostRef"", $bindingFlags).GetValue($host)
      $bindingFlags = [Reflection.BindingFlags] ""Instance,NonPublic,GetProperty""
      $consoleHost = $objectRef.GetType().GetProperty(""Value"", $bindingFlags).GetValue($objectRef, @())
      [void] $consoleHost.GetType().GetProperty(""IsStandardOutputRedirected"", $bindingFlags).GetValue($consoleHost, @())
      $bindingFlags = [Reflection.BindingFlags] ""Instance,NonPublic,GetField""
      $field = $consoleHost.GetType().GetField(""standardOutputWriter"", $bindingFlags)
      $field.SetValue($consoleHost, [Console]::Out)
      [void] $consoleHost.GetType().GetProperty(""IsStandardErrorRedirected"", $bindingFlags).GetValue($consoleHost, @())
      $field2 = $consoleHost.GetType().GetField(""standardErrorWriter"", $bindingFlags)
      $field2.SetValue($consoleHost, [Console]::Error)
    } catch {
      Write-Output ""Unable to apply redirection fix.""
    }
  }
}

Fix-PowerShellOutputRedirectionBug

# Attempt to set highest encryption available for SecurityProtocol.
# PowerShell will not set this by default (until maybe .NET 4.6.x). This
# will typically produce a message for PowerShell v2 (just an info
# message though)
try {
  # Set TLS 1.2 (3072), then TLS 1.1 (768), then TLS 1.0 (192), finally SSL 3.0 (48)
  # Use integers because the enumeration values for TLS 1.2 and TLS 1.1 won't
  # exist in .NET 4.0, even though they are addressable if .NET 4.5+ is
  # installed (.NET 4.5 is an in-place upgrade).
  [System.Net.ServicePointManager]::SecurityProtocol = 3072 -bor 768 -bor 192 -bor 48
} catch {
  Write-Output 'Unable to set PowerShell to use TLS 1.2 and TLS 1.1 due to old .NET Framework installed. If you see underlying connection closed or trust errors, you may need to do one or more of the following: (1) upgrade to .NET Framework 4.5+ and PowerShell v3, (2) specify internal Chocolatey package location (set $env:chocolateyDownloadUrl prior to install or host the package internally), (3) use the Download + PowerShell method of install. See https://chocolatey.org/install for all install options.'
}

function Get-Downloader {
param(
  [string]$url
 )

  $downloader = new-object System.Net.WebClient

  $defaultCreds = [System.Net.CredentialCache]::DefaultCredentials
  if ($defaultCreds -ne $null)
{
    $downloader.Credentials = $defaultCreds
  }

  $ignoreProxy = $env:chocolateyIgnoreProxy
  if ($ignoreProxy -ne $null -and $ignoreProxy -eq 'true') {
    Write-Debug ""Explicitly bypassing proxy due to user environment variable""
    $downloader.Proxy = [System.Net.GlobalProxySelection]::GetEmptyWebProxy()
  } else {
    # check if a proxy is required
    $explicitProxy = $env:chocolateyProxyLocation
    $explicitProxyUser = $env:chocolateyProxyUser
    $explicitProxyPassword = $env:chocolateyProxyPassword
    if ($explicitProxy -ne $null -and $explicitProxy -ne '') {
      # explicit proxy
      $proxy = New-Object System.Net.WebProxy($explicitProxy, $true)
      if ($explicitProxyPassword -ne $null -and $explicitProxyPassword -ne '') {
        $passwd = ConvertTo-SecureString $explicitProxyPassword -AsPlainText -Force
        $proxy.Credentials = New-Object System.Management.Automation.PSCredential($explicitProxyUser, $passwd)
      }

      Write-Debug ""Using explicit proxy server '$explicitProxy'.""
      $downloader.Proxy = $proxy

    } elseif(!$downloader.Proxy.IsBypassed($url)) {
      # system proxy (pass through)
      $creds = $defaultCreds
      if ($creds -eq $null) {
        Write-Debug ""Default credentials were null. Attempting backup method""
        $cred = get-credential
        $creds = $cred.GetNetworkCredential();
      }

      $proxyaddress = $downloader.Proxy.GetProxy($url).Authority
      Write-Debug ""Using system proxy server '$proxyaddress'.""
      $proxy = New-Object System.Net.WebProxy($proxyaddress)
      $proxy.Credentials = $creds
      $downloader.Proxy = $proxy
    }
  }

  return $downloader
}

function Download-String {
param(
  [string]$url
 )
  $downloader = Get-Downloader $url

  return $downloader.DownloadString($url)
}

function Download-File {
param(
  [string]$url,
  [string]$file
 )
  #Write-Output ""Downloading $url to $file""
  $downloader = Get-Downloader $url

  $downloader.DownloadFile($url, $file)
}

# Download the Chocolatey package
Write-Output ""Getting Chocolatey from $url.""
Download-File $url $file

# Determine unzipping method
# 7zip is the most compatible so use it by default
$7zaExe = Join-Path $tempDir '7za.exe'

$useWindowsCompression = $env:chocolateyUseWindowsCompression
if ($useWindowsCompression -ne $null -and $useWindowsCompression -eq 'true') {
  Write-Output 'Using built-in compression to unzip'
  $unzipMethod = 'builtin'
} elseif (-Not (Test-Path ($7zaExe))) {
  Write-Output ""Downloading 7-Zip commandline tool prior to extraction.""
  # download 7zip
  Download-File $7zipUrl ""$7zaExe""
}


# unzip the package
Write-Output ""Extracting $file to $tempDir...""
if ($unzipMethod -eq '7zip') {
  $params = ""x -o`""$tempDir`"" -bd -y `""$file`""""
  # use more robust Process as compared to Start-Process -Wait (which doesn't
  # wait for the process to finish in PowerShell v3)
  $process = New-Object System.Diagnostics.Process
  $process.StartInfo = New-Object System.Diagnostics.ProcessStartInfo($7zaExe, $params)
  $process.StartInfo.RedirectStandardOutput = $true
  $process.StartInfo.UseShellExecute = $false
  $process.StartInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
  $process.Start() | Out-Null
  $process.BeginOutputReadLine()
  $process.WaitForExit()
  $exitCode = $process.ExitCode
  $process.Dispose()

  $errorMessage = ""Unable to unzip package using 7zip. Perhaps try setting `$env:chocolateyUseWindowsCompression = 'true' and call install again. Error:""
  switch ($exitCode) {
    0 { break }
    1 { throw ""$errorMessage Some files could not be extracted"" }
    2 { throw ""$errorMessage 7-Zip encountered a fatal error while extracting the files"" }
    7 { throw ""$errorMessage 7-Zip command line error"" }
    8 { throw ""$errorMessage 7-Zip out of memory"" }
    255 { throw ""$errorMessage Extraction cancelled by the user"" }
    default { throw ""$errorMessage 7-Zip signalled an unknown error (code $exitCode)"" }
  }
} else {
  if ($PSVersionTable.PSVersion.Major -lt 5) {
    try {
      $shellApplication = new-object -com shell.application
      $zipPackage = $shellApplication.NameSpace($file)
      $destinationFolder = $shellApplication.NameSpace($tempDir)
      $destinationFolder.CopyHere($zipPackage.Items(),0x10)
    } catch {
      throw ""Unable to unzip package using built-in compression. Set `$env:chocolateyUseWindowsCompression = 'false' and call install again to use 7zip to unzip. Error: `n $_""
    }
  } else {
    Expand-Archive -Path ""$file"" -DestinationPath ""$tempDir"" -Force
  }
}

# Call chocolatey install
Write-Output ""Installing chocolatey on this machine""
$toolsFolder = Join-Path $tempDir ""tools""
$chocInstallPS1 = Join-Path $toolsFolder ""chocolateyInstall.ps1""

& $chocInstallPS1

Write-Output 'Ensuring chocolatey commands are on the path'
$chocInstallVariableName = ""ChocolateyInstall""
$chocoPath = [Environment]::GetEnvironmentVariable($chocInstallVariableName)
if ($chocoPath -eq $null -or $chocoPath -eq '') {
  $chocoPath = ""$env:ALLUSERSPROFILE\Chocolatey""
}

if (!(Test-Path ($chocoPath))) {
  $chocoPath = ""$env:SYSTEMDRIVE\ProgramData\Chocolatey""
}

$chocoExePath = Join-Path $chocoPath 'bin'

if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower()) -eq $false) {
  $env:Path = [Environment]::GetEnvironmentVariable('Path',[System.EnvironmentVariableTarget]::Machine);
}

Write-Output 'Ensuring chocolatey.nupkg is in the lib folder'
$chocoPkgDir = Join-Path $chocoPath 'lib\chocolatey'
$nupkg = Join-Path $chocoPkgDir 'chocolatey.nupkg'
if (![System.IO.Directory]::Exists($chocoPkgDir)) { [System.IO.Directory]::CreateDirectory($chocoPkgDir); }
Copy-Item ""$file"" ""$nupkg"" -Force -ErrorAction SilentlyContinue
  ".Replace("[[URL]]", url).Replace("[[API_PATH]]", apiPath).Replace("[[THIS_URL]]",thisUrl);
        }

    }
}