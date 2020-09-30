let inherit (import ./carnap.nix) machine;
in
{
  network.description = "carnap-staging";
  network.enableRollback = true;
  carnap-local = machine {
    staging = true;
    localtest = true;
    deployment = {
      targetHost = "carnaptest";
      targetEnv = "none";
      provisionSSHKey = false;
    };
  };
}
