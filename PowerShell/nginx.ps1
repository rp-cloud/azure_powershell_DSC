Configuration InstallNginx {
    Node "localhost" {
        Package Nginx {
            Ensure = "Present"
            Name = "nginx"
            PackageManager = "apt"
        }

        Service NginxService {
            Name = "nginx"
            Ensure = "Running"
            Enabled = $true
            DependsOn = "[Package]Nginx"
        }
    }
}
