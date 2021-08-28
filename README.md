# NixOps configuration for a Carnap deployment

This set of config files lets you make a deployment of Carnap to DigitalOcean
or elsewhere. It's sort of specialized for my application, but may still be
useful as a starting point.

## Files you need to make in the root of the repo

`localtest-hardware-config.nix`: NixOS hardware config file. Get it from
`/etc/nixos` of your test system.

`localtest-config.nix`: NixOS config file. Get it from `/etc/nixos` of your test
system. It just needs to be good enough to get NixOps ssh into your machine.

## Files you need to make in secrets/

`private.nix`:
```nix
{ nixpkgs }:
let inherit (nixpkgs.lib) optional optionalString;
in
{
  hostname = staging: "carnap${optionalString staging "-staging"}.example.com";
  email = "letsencrypt@example.com";

  localCaddyConfig = staging: "";

  googlekeys = staging: if !staging then {
    # prod keys
    GOOGLEKEY = "secretsecretsecret";
    GOOGLESECRET = "secretsecretsecret";
  } else {
    # staging keys
    GOOGLEKEY = "secretsecretsecret";
    GOOGLESECRET = "secretsecretsecret";
  };
  sshKeys = ["ssh-rsa secretsecretsecret"];

  digitaloceanToken = "secretsecretsecret";
}
```

`carnapprod` ssh key:

Create it with `ssh-keygen -f carnapprod`.

## TODO

- Document usage more.
