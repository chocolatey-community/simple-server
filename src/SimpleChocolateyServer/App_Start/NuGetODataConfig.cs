using System.Net.Http;
using System.Web.Http;
using System.Web.Http.Routing;
using NuGet.Server;
using NuGet.Server.V2;

[assembly: WebActivatorEx.PreApplicationStartMethod(typeof(SimpleChocolateyServer.App_Start.NuGetODataConfig), "Start")]

namespace SimpleChocolateyServer.App_Start 
{
    public static class NuGetODataConfig 
	{
        public static void Start() 
		{
            ServiceResolver.SetServiceResolver(new DefaultServiceResolver());

            var config = GlobalConfiguration.Configuration;

            NuGetV2WebApiEnabler.UseNuGetV2WebApiFeed(config, "ChocolateyDefault", "chocolatey", "PackagesOData");

            config.Routes.MapHttpRoute(
                name: "NuGetDefault_ClearCache",
                routeTemplate: "chocolatey/clear-cache",
                defaults: new { controller = "PackagesOData", action = "ClearCache" },
                constraints: new { httpMethod = new HttpMethodConstraint(HttpMethod.Get) }
            );

		    config.Routes.MapHttpRoute(
		        name: "root_upload",
		        routeTemplate: "api/v2/package",
		        defaults: new { controller = "PackagesOData", action = "UploadPackage" },
		        constraints: new { httpMethod = new HttpMethodConstraint(HttpMethod.Put) }
		    );

        }
    }
}
