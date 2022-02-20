let
  carnap = import ../carnap {};
  inherit (carnap) nixpkgs;
  inherit (nixpkgs.lib) optional optionalString;
  inherit (import ./secrets/private.nix {inherit nixpkgs; }) hostname localCaddyConfig email googlekeys sshKeys;

  machine = { staging, localtest ? false, configs ? [], deployment }: {pkgs, ...}: {
    imports = configs;
    inherit deployment;
    users.users.jade = {
      isNormalUser = true;
      extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
      openssh.authorizedKeys.keys = sshKeys;
    };
    # for debugging mostly, but it would be useful to correlate these
    security.auditd.enable = true;
    security.audit.enable = true;
    security.audit.rules = [
      "-w /var/lib/carnap -p wa -k carnap-file-write"
      "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -S rmdir -F dir=/var/lib/carnap -k carnap-delete"
      "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -S rmdir -F dir=/var/lib/carnap -k carnap-delete"
    ];

    users.users.carnap = {
      isSystemUser = true;
      home = "/var/lib/carnap";
      uid = 500;
    };
    users.groups.carnap.gid = 500;

    services.openssh.enable = true;
    services.openssh.passwordAuthentication = false;
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    documentation.enable = false;

    services.postgresql.enable = true;
    services.postgresql.package = nixpkgs.postgresql_12;
    services.postgresql.ensureDatabases = [ "carnapdb" ];
    services.postgresql.ensureUsers = [
      {
        name = "carnap";
        ensurePermissions = {
          # TODO: possibly should be hardened but requirements are undocumented :/
          "DATABASE carnapdb" = "ALL PRIVILEGES";
        };
      }
    ];

    systemd.services.carnap = {
      description = "Carnap server";
      after = [ "postgresql.service" ];
      path = [ carnap.server ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        cp -r --no-preserve=mode ${carnap.server}/share/* /var/lib/carnap/
        for book in /var/lib/carnap/books/*; do mkdir -p $book/cache; done
        mkdir -p /var/lib/carnap/data
      '';

      environment = {
        APPROOT = "https://${hostname staging}";
        DATAROOT = "/var/lib/carnap";
        BOOKROOT = "/var/lib/carnap/books/forallx-ubc";
        SQLITE = "false";
        PGPORT = "";
        PGHOST = "";
        PGUSER = "";
        PGPASS = "";
      } // googlekeys staging;

      serviceConfig = {
        ExecStart = ''
          ${carnap.server}/bin/Carnap-Server
        '';
        User = "carnap";
        Group = "carnap";
        WorkingDirectory = "/var/lib/carnap";
      };
    };

    # create the Carnap home directory
    systemd.tmpfiles.rules = [
      "d '/var/lib/carnap' 0755 carnap carnap"
    ];

    # caddy proxy config. keter is possible for sure but doesn't have a nixos
    # module
    services.caddy.package = pkgs.caddy;
    services.caddy.enable = true;
    services.caddy.email = email;
    services.caddy.ca = if staging then "https://acme-staging-v02.api.letsencrypt.org/directory"
      else "https://acme-v02.api.letsencrypt.org/directory";
    services.caddy.config = ''
      {

      }

      ${localCaddyConfig staging}

      https://${hostname staging} {
        encode zstd gzip
        log
        ${optionalString staging "tls internal"}
        reverse_proxy localhost:3000
      }
    '';
  };
in
{
  inherit machine nixpkgs;
}
