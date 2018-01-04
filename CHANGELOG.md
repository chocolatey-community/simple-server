# Chocolatey Simple Server CHANGELOG

## 0.2.0 (unreleased)
### BREAKING CHANGES
 * Now requires .NET Framework 4.6.x - [#14](https://github.com/chocolatey/simple-server/issues/14)

To use the same caching techniques mentioned below in [#10](https://github.com/chocolatey/simple-server/issues/10), we needed to upgrade to the same version of the .NET Framework that was being used by NuGet.Server. That means you need to take some extra steps of ensuring that your ASP.NET has .NET 4.6+ registered so that files are served properly.

### FEATURES
 * Use same caching techniques as NuGet.Server v3.4.x+ [#10](https://github.com/chocolatey/simple-server/issues/10)

No longer time out when serving up large-sized packages. This is accomplished by pulling the items out of packages ahead of time that are necessary when serving information.

### IMPROVEMENTS
 * Show version of Chocolatey Server on site - [#12](https://github.com/chocolatey/simple-server/issues/12)

## 0.1.4 (January 2, 2018)
### BUG FIXES
 * Fix - Turning on basic auth in web.config doesn't allow pushing packages

### IMPROVEMENTS
 * Use Chocolatey icon for favicon

## 0.1.3 (October 6, 2017)
### FEATURES
 * Allow specifying Basic Authentication credentials directly from the web.config file.

### IMPROVEMENTS
 * Increase timeout for pushing packages from the default of 110 seconds to 1200
seconds (20 minutes).


## 0.1.2 (November 17, 2016)
### IMPROVEMENTS
 * Package size allows for 2GB
 * Uses same NuGet enhancements that Chocolatey uses.


## 0.1.1 (September 20, 2014)
### BUG FIXES
 * Small fix to not do anything with respect to making changes.

### IMPROVEMENTS
 * Cleaned up files


## 0.1.0 (September 20, 2014)
 * Initial Release
