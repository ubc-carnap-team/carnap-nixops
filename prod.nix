let inherit (import ./carnap.nix) machine nixpkgs;
    inherit (import ./secrets/private.nix { inherit nixpkgs; }) digitaloceanToken;
in
{
  network.description = "carnap-prod";
  network.enableRollback = true;

  resources.sshKeyPairs.ssh-key = {
    privateKey = builtins.readFile ./secrets/carnapprod;
    publicKey = builtins.readFile ./secrets/carnapprod.pub;
  };

  carnap-do = machine {
    staging = false;
    localtest = false;
    deployment = {
      targetHost = "carnapprod";
      targetEnv = "droplet";
      droplet = {
        size = "s-1vcpu-2gb";
        region = "tor1";
        authToken = digitaloceanToken;
      };
    };
  };
}
