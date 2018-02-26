Place files for download here. They must be all at this level, no subfolders.

WARNING: Definitely do not expose this to the outside world without a username/password and some authentication.

You can place the chocolatey.license.xml file here for ease of download in your organization with http://thisurl/downloads/chocolatey.license.xml
With PowerShell, it's as simple as running something like the following from a client:
New-Item $env:ChocolateyInstall\license -Type Directory -Force
iwr -UseBasicParsing -Uri http://thisurl/downloads/chocolatey.license.xml -UseDefaultCredentials | Out-File -FilePath $env:ChocolateyInstall\license\chocolatey.license.xml -Encoding UTF8 -Force

