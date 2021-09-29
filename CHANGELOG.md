# Chocolatey Simple Server CHANGELOG

## 0.3.0 (September 29, 2021)
### IMPROVEMENTS
 * [Security] Moderate severity vulnerability that affects Microsoft.Data.OData (CVE-2018-8269) - see [#62](https://github.com/chocolatey-community/simple-server/issues/62)
 * [Security] Update 7za to 18.6 - see [#53](https://github.com/chocolatey-community/simple-server/issues/53)
 * Reorder some information on the Simple Chocolatey Package Repository webpage - see [#37](https://github.com/chocolatey-community/simple-server/issues/37)
 * Documentation note for viewing feed with Chrome - see [#36](https://github.com/chocolatey-community/simple-server/issues/36)


## 0.2.5 (June 13, 2018)
### BUG FIXES
 * Fix - Basic Auth doesn't allow installing Chocolatey.nupkg from local installation - [#43](https://github.com/chocolatey/simple-server/issues/43)


## 0.2.4 (February 26, 2018)
### BUG FIXES
 * Fix - install.ps1 - Function Download-Script is called before its definition - [#41](https://github.com/chocolatey/simple-server/issues/41)
 * Fix - Remove duplicate XDT file - [#39](https://github.com/chocolatey/simple-server/issues/39)


## 0.2.3 (February 11, 2018)
### FEATURES
 * Allow installation of Chocolatey with install.ps1 script - [#27](https://github.com/chocolatey/simple-server/issues/27)

### IMPROVEMENTS
 * Provide instructions on changing apikey versus what setapikey does - [#25](https://github.com/chocolatey/simple-server/issues/25)
 * Enhance documentation (multiple requests) enhancement - [#26](https://github.com/chocolatey/simple-server/issues/26)


## 0.2.2 (January 11, 2018)
### BUG FIXES
 * Fix - Turning on basic auth with HttpAuth Module no longer allows pushing in v0.2x - [#21](https://github.com/chocolatey/simple-server/issues/21)
 * Fix - Pushing to default url is missing in v0.2.x - [#20](https://github.com/chocolatey/simple-server/issues/20)


## 0.2.1 (January 8, 2018)
### BUG FIXES
 * Fix - New installation doesn't copy subfolders and files - [#18](https://github.com/chocolatey/simple-server/issues/18)


## 0.2.0 (January 4, 2018)
### BREAKING CHANGES
 * Require .NET Framework 4.6.x - [#14](https://github.com/chocolatey/simple-server/issues/14)

To use the same caching techniques mentioned below in [#10](https://github.com/chocolatey/simple-server/issues/10), we needed to upgrade to the same version of the .NET Framework that was being used by NuGet.Server. That means you need to take some extra steps of ensuring that your ASP.NET has .NET 4.6+ registered so that files are served properly.

### FEATURES
 * Use same caching techniques as NuGet.Server v3x+ (NuGet v3.4.x+) - [#10](https://github.com/chocolatey/simple-server/issues/10)

No longer time out when serving up large-sized packages. This is accomplished by pulling the items out of packages ahead of time that are necessary when serving information.

### BUG FIXES
 * Fix - Uploading large package results in System.OutOfMemoryException - [#15](https://github.com/chocolatey/simple-server/issues/15)

### IMPROVEMENTS
 * Show version of Chocolatey Server on site - [#12](https://github.com/chocolatey/simple-server/issues/12)
 * Manage upgrades and uninstalls gracefully - [#13](https://github.com/chocolatey/simple-server/issues/13)


## 0.1.4 (January 2, 2018)
### BUG FIXES
 * Fix - Turning on basic auth in web.config doesn't allow pushing packages - [#6](https://github.com/chocolatey/simple-server/issues/6)

### IMPROVEMENTS
 * Use Chocolatey icon for favicon


## 0.1.3 (October 6, 2017)
### FEATURES
 * Allow specifying Basic Authentication credentials directly from the web.config file - [#5](https://github.com/chocolatey/simple-server/issues/5)

### IMPROVEMENTS
 * Increase timeout for pushing packages from the default of 110 seconds to 1200
seconds (20 minutes) - [#3](https://github.com/chocolatey/simple-server/issues/3)


## 0.1.2 (November 17, 2016)
### IMPROVEMENTS
 * Package size allows for 2GB - [#1](https://github.com/chocolatey/simple-server/issues/1)
 * Uses same NuGet enhancements that Chocolatey uses.


## 0.1.1 (September 20, 2014)
### BUG FIXES
 * Small fix to not do anything with respect to making changes.

### IMPROVEMENTS
 * Cleaned up files


## 0.1.0 (September 20, 2014)
 * Initial Release
