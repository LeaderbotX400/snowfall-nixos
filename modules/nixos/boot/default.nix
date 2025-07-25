# INFO: NixOS Boot module.

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
{
  options.snowfall.boot = {
    # What type of bootloader module to use.
    type = mkOption {
      type =
        with types;
        enum [
          "bios"
          "uefi"
          "lanzaboote"
        ];
      default = "uefi";
    };

    # Whether to use LUKS2 encryption.
    encrypted = mkOption {
      type = with types; bool;
      default = false;
    };

    # Whether to enable Plymouth and reduce TTY verbosity.
    quiet = mkOption {
      type = with types; bool;
      default = false;
    };
  };

  config =
    let
      inherit (config.snowfall.boot) type quiet encrypted;
      # inherit (config.networking) hostName;
    in
    mkMerge [
      {
        boot.loader.systemd-boot.enable = true;

        systemd.services = {
          NetworkManager-wait-online.enable = false;
          plymouth-quit-wait.enable = false;
        };
      }

      # BIOS:
      (mkIf (type == "bios") {
        # boot.loader.grub.efiSupport = false;
      })

      # UEFI: common options.
      (mkIf (type == "uefi" || type == "lanzaboote") {
        # WARNING: NixOS will be able to modify the BIOS boot entries and their
        # order. The only risk is that wiping the root (say with `rm -rf /*`) may
        # empty all the EFI variables and that has lead to bricking some (buggy)
        # BIOSes in the past.
        # SOURCE: https://discourse.nixos.org/t/question-about-grub-and-nodev/37867/8
        boot.loader.efi.canTouchEfiVariables = true;

        # NOTE: Managed by disko.
        # fileSystems.${config.boot.loader.efi.efiSysMountPoint} = {
        #     device = "/dev/disk/by-label/NIXOS_EFI";
        #     fsType = "vfat";
        # };
      })

      # UEFI: GRUB2 non-secure boot.
      (mkIf (type == "uefi") {
        # boot.loader.systemd-boot.memtest86.enable = true;
        # boot.loader.grub = {
        #   efiSupport = true;
        #   efiInstallAsRemovable = mkDefault false;
        #   device = "nodev"; # INFO: https://discourse.nixos.org/t/question-about-grub-and-nodev
        # };
      })

      # UEFI: Secure boot.
      #
      # INFO: https://github.com/nix-community/lanzaboote/blob/master/docs/QUICK_START.md
      (mkIf (type == "lanzaboote") {
        environment.systemPackages = with pkgs; [ sbctl ];
        boot = {
          lanzaboote = {
            enable = true;
            # pkiBundle = "/etc/secureboot";
            pkiBundle = "/var/lib/sbctl";
          };
          loader = {
            # HACK: Lanzaboote currently replaces systemd-boot, so force it to false for now.
            systemd-boot.enable = mkForce false;
            grub.enable = mkForce false;
          };
        };
      })

      # LUKS2 support.
      (mkIf encrypted {
        boot = {
          # loader.grub.enableCryptodisk = true;
          # initrd = let
          #     FDE = type != "lanzaboote";
          #     keyfile = "/keyfile-${toLower hostName}.bin";
          # in {
          #     luks.devices."root" = {
          #         device = "/dev/disk/by-label/${toUpper hostName}_LUKS";
          #         preLVM = true;
          #         allowDiscards = true;
          #         keyFile = mkIf FDE keyfile;
          #     };

          #     # Include necessary keyfiles in the InitRD.
          #     secrets = mkIf FDE {
          #         ${keyfile} = "/etc/secrets/initrd/keyfile-${toLower hostName}.bin";
          #     };
          # };
        };
      })

      # Quiet boot with minimal logging.
      (mkIf quiet {
        boot = {
          plymouth = {
            enable = true;
            theme = "breeze";
          };

          consoleLogLevel = 0;
          kernelParams = [
            "quiet"
            "loglevel=3"
            "systemd.show_status=auto"
            "udev.log_level=3"
            "rd.udev.log_level=3"
            "vt.global_cursor_default=0"
          ];

          initrd = {
            systemd.enable = true;
            verbose = false;
          };
        };
      })
    ];
}
