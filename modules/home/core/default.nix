# INFO: Core Home-manager module.

{
  lib,
  config,
  ...
}:

with lib;
{
  options = {
    snowfall.core.enable = mkOption {
      description = "Whether to enable core Home-manager options";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.snowfall.core.enable {
    programs = {
      home-manager.enable = mkForce true; # Home-manager absolutely should stay enabled.
      nix-index.enable = true; # A files database for Nixpkgs.
    };

    # Inherit common Nix settings.
    nix = { inherit (lib.snowfall.nix) settings; };

    home = {
      homeDirectory = mkForce "/home/${config.home.username}";
      sessionVariables = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/Screenshots";
      };
    };

    xdg = {
      enable = true;
      userDirs =
        let
          inherit (config.home) homeDirectory;
        in
        {
          enable = true;
          createDirectories = true;

          # Create these automatically.
          desktop = "${homeDirectory}/Desktop";
          documents = "${homeDirectory}/Documents";
          music = "${homeDirectory}/Music";
          pictures = "${homeDirectory}/Images";

          # Don't need these.
          publicShare = null;
          templates = null;
        };

      mime.enable = true;
      mimeApps =
        let
          mimes = { };
        in
        {
          enable = true;
          associations.added = mimes;
          defaultApplications = mimes;
        };
    };

    # Nicely reload user services on rebuild.
    systemd.user.startServices = "sd-switch";

    # Hide Home-manager's news.
    news.display = "silent";
  };
}