let inherit (import ./carnap.nix) machine;
in
{ sysType ? "hyperv" }:
{
  network.description = "carnap-staging";
  network.enableRollback = true;
  carnap-local = machine {
    staging = true;
    configs = (if sysType == "libvirt" then
                [ ./localtest-lv-hardware-config.nix ./localtest-config.nix ]
              else if sysType == "hyperv" then
                [ ./localtest-hardware-config.nix ./localtest-config.nix ]
              else abort "unrecognized sys type");
    localtest = true;
    deployment = {
      targetHost = "carnaptest";
      targetEnv = "none";
      provisionSSHKey = false;
      hasFastConnection = true;
    };
  };
}
