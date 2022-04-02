let sources = import ./nix/sources.nix;
    nixpkgs = import sources.nixpkgs { };
    #nixpkgs = import ../nixpkgs { };
    nixops = import sources.nixops;
    nixops-digitalocean = import sources.nixops-digitalocean { pkgs = nixpkgs; };
    inherit (nixpkgs) mkShell;
in
mkShell {
  name = "environment";

  buildInputs = [
    nixops
    nixops-digitalocean
    nixpkgs.caddy
  ];

  # FIXME(jade): this is split because I don't want to update nixops while
  # they are still (2022-04) in the middle of fiddling with their state
  # format
  shellHook = ''
    export NIXOPS_STATE=deployments.nixops
    export NIX_PATH="nixpkgs=${sources.system-nixpkgs}:."
  '';
  # shellHook = ''
  #   export NIX_PATH="nixpkgs=../nixpkgs:."
  # '';
}
