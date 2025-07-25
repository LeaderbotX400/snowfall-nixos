# INFO: Home-manager CLI module.

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;
{
  options.snowfall.cli = {
    enable = mkOption {
      description = "Whether to enable core CLI functionality";
      type = with types; bool;
      default = true;
    };
  };

  config = mkIf config.snowfall.cli.enable {
    programs = {
      htop.enable = true; # The well-known TUI process viewer.
      bottom.enable = true; # The cool new TUI process viewer.
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };

    home.packages = with pkgs; [
      # System information stuff.
      dua # View disk space usage and delete unwanted data.
      duf # Neat disk monitor.
      kondo # Disposal of build artifacts.

      # Networking.
      bandwhich # Bandwidth utilization tool.
      doggo # CLI DNS Client, written in Go (`dig` alternative).
      ethtool # For controlling network drivers and hardware.
      gping # `ping`, but with a graph.
      # hurl # Perform HTTP requests defined in plain text.
      netdiscover # Discover hosts in LAN.
      nmap # Port scanner.
      rustscan # The "Modern Port Scanner".
      # speedtest-rs # CLI internet speedtest tool in Rust.

      # Alternative implementations of the basic tools.
      erdtree # Tree-like `ls` with a load of features.
      killall # Basically `pkill`.
      ripgrep # Oxidized `grep`.
      sd # A friendlier `sed`.
      srm # Secure `rm`.

      # Text & image processors.
      # bc # Arbitrary precision calculator.
      # binsider # TUI ELF binary analyzer.
      # exiftool # View EXIF metadata of files.
      # heh # Hex editor.
      # hexyl # Hex viewer.
      # jaq # `jq` clone in Rust.
      # jc # Parse output of various commands to JSON.
      # jq # JSON processor.
      # mpv # Based video player.
      # timg # CLI image viewer.
      # toml2nix # Convert TOML to Nix.

      # Color processors.
      # matugen # Material You color generation tool.
      # pastel # Generate, analyze, convert and manipulate colors.

      # Build systems & automation.
      # cmake # Cross-platform, open-source build system generator (dumpster fire).
      # comma # Run any binary (with `nix-index` and `nix run`)
      # gnumake # GNU make.
      # meson # Open source, fast and friendly build system made in Python.
      # ninja # Small build system with a focus on speed.

      # Archiving tools.
      unrar
      unzip
      zip

      # Fetches and other cool TUI stuff.
      # cbonsai
      # cmatrix
      # lolcat
      # neofetch
      # nitch
      # onefetch
      # pipes-rs

      # Terminal recording and fun.
      # asciinema
      # minesweep-rs
      # vhs

      # Benchmarking.
      # hyperfine

      # Command managers.
      # mprocs

      # Other TUIs.
      # porsmo # Pomodoro timer.
    ];
  };
}
