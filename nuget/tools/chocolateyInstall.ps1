$packageName = 'chocolatey.server'

try { 
  $toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
  $webToolsDir = Join-Path $toolsDir $packageName
  $installDir = Get-BinRoot
  $webInstallDir = Join-Path $installDir $packageName
  
  #Enable Web Services
  #cinst IIS-WebServerRole -source WindowsFeatures
  #cinst IIS-ISAPIFilter -source WindowsFeatures
  #cinst IIS-ISAPIExtensions -source WindowsFeatures
  
  # https://github.com/chocolatey/chocolatey/wiki/DevelopmentEnvironmentSetup
  # cinst ASPNET -source webpi
  # cinst ASPNET_REGIIS -source webpi
  # cinst DefaultDocument -source webpi
  # cinst DynamicContentCompression -source webpi
  # cinst HTTPRedirection -source webpi
  # cinst IIS7_ExtensionLessURLs -source webpi
  # cinst IISManagementConsole -source webpi
  # cinst ISAPIExtensions -source webpi
  # cinst ISAPIFilters -source webpi
  # cinst NETExtensibility -source webpi
  # cinst RequestFiltering -source webpi
  # cinst StaticContent -source webpi
  # cinst StaticContentCompression -source webpi
  # cinst UrlRewrite2 -source webpi

  # W3SVC should be running
  
  # http://msdn.microsoft.com/en-us/library/windows/desktop/ms724832.aspx
  $osVersion = [Environment]::OSVersion.Version
  if ($osVersion -ge [Version]'6.2') #8/2012+
  {
    #cinst IIS-NetFxExtensibility45 -source WindowsFeatures
    #cinst NetFx4Extended-ASPNET45 -source WindowsFeatures
    #cinst IIS-ASPNet45 -source WindowsFeatures
   
  } else { #Windows 7/2008 and below
    ."$env:windir\microsoft.net\framework\v4.0.30319\aspnet_regiis.exe" -i
  }
  
  #TODO: if exists, copy the App_Data folder somewhere else for a moment so stuff doesn't get deleted
  
  Copy-Item $webToolsDir $webInstallDir -recurse -force
 
 
  #Import-Module WebAdministration
  #Remove-WebSite -Name "Default Web Site" -ErrorAction SilentlyContinue
  #Remove-WebSite -Name "ChocolateyServer" -ErrorAction SilentlyContinue
  #New-WebSite -ID 1 -Name "ChocolateyServer" -Port 80 -PhysicalPath "$webInstallDir" -Force

  # $networkSvc = 'NT AUTHORITY\NETWORK SERVICE'
  # Write-Host "Setting folder permissions on `'$webInstallDir`' to 'Read' for user $networkSvc"
  # $acl = Get-Acl $webInstallDir
  # $acl.SetAccessRuleProtection($False, $True)
  # $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$networkSvc","Read", "ContainerInherit, ObjectInherit", "None", "Allow");
  # $acl.AddAccessRule($rule);
  # Set-Acl $webInstallDir $acl  
  
  # $webInstallAppDataDir = Join-Path $webInstallDir 'App_Data'
  # Write-Host "Setting folder permissions on `'$webInstallAppDataDir`' to 'Modify' for user $networkSvc"
  # $acl = Get-Acl $webInstallAppDataDir
  # $acl.SetAccessRuleProtection($False, $True)
  # $rule = New-Object System.Security.AccessControl.FileSystemAccessRule("$networkSvc","Modify", "ContainerInherit, ObjectInherit", "None", "Allow");
  # $acl.AddAccessRule($rule);
  # Set-Acl $webInstallAppDataDir $acl
  # 
  # Import-Module WebAdministration
  # $appPoolPath = "IIS:\AppPools\$projectName"
  # #$pool = new-object
  # Write-Warning "You can safely ignore the next error if it occurs related to getting an app pool that doesn't exist"
  # $pool = Get-Item $appPoolPath
  # if ($pool -eq $null) {
  #   Write-Host "Creating the app pool `'$appPoolPath`'"
  #   $pool = New-Item $appPoolPath 
  # }
  # 
  # $pool.processModel.identityType = "NetworkService" 
  # $pool | Set-Item
  # Set-itemproperty $appPoolPath -Name "managedRuntimeVersion" -Value "v4.0"
  # #Set-itemproperty $appPoolPath -Name "managedPipelineMode" -Value "Integrated"
  # Start-WebAppPool "$projectName"
  # Write-Host "Creating the site `'$projectName`' with appPool `'$projectName`'"
  # New-WebApplication "$projectName" -Site "Default Web Site" -PhysicalPath $srcDir -ApplicationPool "$projectName" -Force

  #Client SKUs need to enable firewall
  #netsh advfirewall firewall add rule name="Open Port 80" dir=in action=allow protocol=TCP localport=80

  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw
}
