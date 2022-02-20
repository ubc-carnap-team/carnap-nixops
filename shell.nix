let sources = import ./nix/sources.nix;
    nixpkgs = import sources.nixpkgs { };
    #nixpkgs = import ../nixpkgs { };
    nixops = import sources.nixops;
    # there's something broken with latest nixpkgs which we were accidentally using on here before
    # TODO: diagnose it
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

  shellHook = ''
    export NIXOPS_STATE=deployments.nixops
    export NIX_PATH="nixpkgs=${sources.nixpkgs}:."
  '';
  # shellHook = ''
  #   export NIX_PATH="nixpkgs=../nixpkgs:."
  # '';
}
