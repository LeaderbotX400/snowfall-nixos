# INFO: NixOS firmware module.

{
  config,
  lib,
  ...
}:

with lib;
{
  options.snowfall.hardware = {
    firmware = mkOption {
      type =
        with types;
        enum [
          "free"
          "redistributable"
          "all"
        ];
      default = "all";
    };
  };

  config =
    let
      inherit (config.snowfall.hardware)
        firmware
        ;
    in
    mkMerge [
      (mkIf (firmware == "redistributable") {
        hardware.enableRedistributableFirmware = true;
      })

      (mkIf (firmware == "all") {
        hardware.enableAllFirmware = true;
      })

      (mkIf (firmware == "redistributable" || firmware == "all") {
        hardware = {
          cpu = {
            amd.updateMicrocode = true;
            intel.updateMicrocode = true;
          };
        };
      })
    ];
}