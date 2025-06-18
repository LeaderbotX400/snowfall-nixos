# INFO: `fzf`, a general-purpose command-line fuzzy finder (Home-manager module).

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.snowfall.theme)
    ui
    ;

  batOrCat =
    if config.programs.bat.enable then "${pkgs.bat}/bin/bat" else "${pkgs.coreutils}/bin/cat";
in

with lib;
{
  options.snowfall.cli.fzf = {
    enable = mkOption {
      description = "Whether to enable fzf, a general-purpose command-line fuzzy finder";
      type = with types; bool;
      default = true;
    };
  };

  config =
    let
      inherit (config.snowfall.cli.fzf)
        enable
        ;
    in
    mkIf enable {
      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
        enableZshIntegration = true;

        defaultCommand = null;
        defaultOptions = [
          "--reverse"
          "--border=sharp"
          "--height 40%"
          "--bind=tab:down"
          "--bind=btab:up"
          "--bind=alt-j:down"
          "--bind=alt-k:up"
          "--preview '${batOrCat} --color=always --style=numbers --line-range=:500 {}'"
        ];

        fileWidgetCommand = "${pkgs.fd}/bin/fd --type file --hidden";
        fileWidgetOptions = [
          "--preview '${batOrCat} --color=always --style=numbers --line-range=:500 {}'"
        ];

        changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type directory --hidden";
        # changeDirWidgetOptions = [
        #     "--preview 'erd --dirs-only --suppress-size --icons --layout inverted {} | head -n 100'"
        # ];

        historyWidgetOptions = [
          "--exact"
        ];

        # colors = rec {
        #   bg = "#${ui.bg.base}";
        #   fg = "#${ui.bg.surface2}";
        #   "bg+" = bg; # Background (current line).
        #   "fg+" = "#${ui.fg.text}"; # Text (current line).
        #   hl = fg; # Highlighted substrings.
        #   "hl+" = "#${ui.accent}"; # Highlighted substrings (current line).
        #   preview-bg = bg; # Background (preview window).
        #   preview-fg = "#${ui.fg.text}"; # Text (preview window).
        #   gutter = bg; # Gutter on the left (defaults to bg+).
        #   info = "#${ui.bg.surface2}";
        #   border = "#${ui.bg.surface0}"; # Border of the preview window and horizontal separators (--border).
        #   prompt = "#${ui.accent}";
        #   pointer = "#${ui.fg.text}";
        #   spinner = "#${ui.info}"; # Streaming input indicator.
        #   header = "#${ui.bg.surface2}";
        # };
      };
    };
}
