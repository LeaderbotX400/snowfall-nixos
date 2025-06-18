# INFO: NixOS sops-nix module.

{
  config,
  lib,
  ...
}:

with lib;
{
  config = {
    sops = {
      defaultSopsFile = mkDefault ../../../lib/secrets.yaml;
      age = {
        keyFile = "${config.home-manager.users."leaderbotx400".xdg.configHome}/sops/age/keys.txt";
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        generateKey = true;
      };
    };
  };
}