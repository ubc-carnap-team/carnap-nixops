let sources = import ./nix/sources.nix;
    nixpkgs = import sources.nixpkgs { };
    #nixpkgs = import ../nixpkgs { };
    nixops = import sources.nixops;
    nixops-digitalocean = import sources.nixops-digitalocean { };
    inherit (nixpkgs) mkShell;
in
mkShell {
  name = "environment";

  buildInputs = [
    nixops
    nixops-digitalocean
    nixpkgs.caddy
  ];

  # shellHook = ''
  #   export NIX_PATH="nixpkgs=${sources.nixpkgs}:."
  # '';
  shellHook = ''
    export NIX_PATH="nixpkgs=../nixpkgs:."
  '';
}
