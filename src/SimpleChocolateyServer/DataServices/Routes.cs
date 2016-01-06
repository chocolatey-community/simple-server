using SimpleChocolateyServer;
using WebActivatorEx;

[assembly: PreApplicationStartMethod(typeof (NuGetRoutes), "Start")]

namespace SimpleChocolateyServer
{
    using System.Data.Services;
    using System.ServiceModel.Activation;
    using System.Web.Routing;
    using Ninject;
    using NuGet.Server;
    using NuGet.Server.DataServices;
    using NuGet.Server.Infrastructure;

    public static class NuGetRoutes
    {
        public static void Start()
        {
            MapRoutes(RouteTable.Routes);
        }

        private static void MapRoutes(RouteCollection routes)
        {
            // The default route is http://{root}/chocolatey/Packages
            var factory = new DataServiceHostFactory();
            var serviceRoute = new ServiceRoute("chocolatey", factory, typeof (Packages));
            serviceRoute.Defaults = new RouteValueDictionary {{"serviceType", "odata"}};
            serviceRoute.Constraints = new RouteValueDictionary {{"serviceType", "odata"}};
            routes.Add("chocolatey", serviceRoute);
        }

        private static PackageService CreatePackageService()
        {
            return NinjectBootstrapper.Kernel.Get<PackageService>();
        }
    }
}