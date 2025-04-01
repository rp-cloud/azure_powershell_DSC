Configuration InstallNginx {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost" {
        Package Nginx {
            Ensure = "Present"
            Name = "nginx"
            Path = "/usr/bin/nginx"   # <-- Poprawiona ścieżka do binarki Nginx
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
