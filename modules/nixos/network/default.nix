# INFO: NixOS networking module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.net = {
    # Whether or not to use NetworkManager.
    networkmanager = mkOption {
      type = types.bool;
      default = true;
    };

    # Whether to open port 9 for WakeOnLAN.
    allowWOL = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config =
    let
      inherit (config.snowfall.net) networkmanager allowWOL;
      ports.open = if allowWOL then [ 9 ] else [ ];
    in
    {
      networking = {
        useDHCP = lib.mkDefault true;
        networkmanager.enable = networkmanager;
        firewall = {
          enable = true;
          allowedTCPPorts = ports.open;
          allowedUDPPorts = ports.open;
        };
      };

      environment = {
        systemPackages = with pkgs; [
          dig
          ethtool
          iperf3
          wakeonlan
        ];

        etc."nix/open_ports.json".text =
          let
            inherit (config.networking.firewall)
              allowedTCPPorts
              allowedTCPPortRanges
              allowedUDPPorts
              allowedUDPPortRanges
              ;
            rangesToList =
              ranges: ranges |> builtins.map (range: "${toString range.from}-${toString range.to}");
          in
          # json
          builtins.toJSON {
            tcp = allowedTCPPorts ++ rangesToList allowedTCPPortRanges;
            udp = allowedUDPPorts ++ rangesToList allowedUDPPortRanges;
          };
      };
    };
}