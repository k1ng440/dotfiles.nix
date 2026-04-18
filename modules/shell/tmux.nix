{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    { pkgs, ... }:
    let
      # Implementation for loading plugins from home-manager:
      # https://github.com/nix-community/home-manager/blob/master/modules/programs/tmux.nix
      tmuxPlugin = p: "run-shell ${if lib.types.package.check p then p.rtp else p.plugin.rtp}";

      # Config content with placeholder for self-reference
      tmuxConfRaw = /* sh */ ''
        # Rose Pine Theme
        set -g @rose_pine_variant 'moon'
        set -g @rose_pine_host 'on'
        set -g @rose_pine_date_time '%H:%M'
        set -g @rose_pine_user 'on'
        set -g @rose_pine_directory 'on'
        set -g @rose_pine_bar_bg_disable 'on'
        set -g @rose_pine_only_windows 'on'
        set -g @rose_pine_disable_active_window_icon 'on'
        set -g @rose_pine_default_window_behavior 'on'
        set -g @rose_pine_show_current_program 'on'
        set -g @rose_pine_show_pane_directory 'on'

        # Load Nix-managed plugins
        ${tmuxPlugin pkgs.tmuxPlugins.sensible}
        ${lib.concatMapStringsSep "\n" tmuxPlugin (
          with pkgs.tmuxPlugins;
          [
            vim-tmux-navigator
            yank
            rose-pine
            tmux-floax
            resurrect
            continuum
          ]
        )}

        # Rebind "last pane" to C-;
        unbind -n C-\\
        bind -n C-\; last-pane

        # Prefix Settings
        unbind C-b
        set -g prefix C-Space
        set -g prefix2 C-@
        bind C-Space send-prefix
        bind C-@ send-prefix
        bind -N "Reload tmux config" R run-shell 'tmux source-file $(tmux display-message -p "#{config_files}" | cut -d"," -f1)' \; display-message "Config reloaded!"

        # Vi mode for copy
        setw -g mode-keys vi
        bind -T copy-mode-vi v send -X begin-selection
        bind -T copy-mode-vi y send -X copy-selection-and-cancel

        # Pane Controls
        bind -N "Split window vertically" h split-window -v -c "#{pane_current_path}"
        bind -N "Split window horizontally" v split-window -h -c "#{pane_current_path}"
        bind -N "Kill current pane" x kill-pane

        # Smart Pane Navigation (Ctrl-Meta-Arrows)
        bind -n -N "Select pane to the left" C-M-Left select-pane -L
        bind -n -N "Select pane to the right" C-M-Right select-pane -R
        bind -n -N "Select pane above" C-M-Up select-pane -U
        bind -n -N "Select pane below" C-M-Down select-pane -D

        # Resize (Ctrl-Meta-Shift-Arrows)
        bind -n -N "Resize pane left" C-M-S-Left resize-pane -L 5
        bind -n -N "Resize pane down" C-M-S-Down resize-pane -D 5
        bind -n -N "Resize pane up" C-M-S-Up resize-pane -U 5
        bind -n -N "Resize pane right" C-M-S-Right resize-pane -R 5

        # Window navigation
        bind -N "Rename current window" r command-prompt -I "#W" "rename-window -- '%%'"
        bind -N "Create new window" c new-window -c "#{pane_current_path}"
        bind -N "Kill current window" k kill-window

        # Alt + Number for Window Switching
        bind -n -N "Switch to window 1" M-1 select-window -t 1
        bind -n -N "Switch to window 2" M-2 select-window -t 2
        bind -n -N "Switch to window 3" M-3 select-window -t 3
        bind -n -N "Switch to window 4" M-4 select-window -t 4
        bind -n -N "Switch to window 5" M-5 select-window -t 5
        bind -n -N "Switch to window 6" M-6 select-window -t 6
        bind -n -N "Switch to window 7" M-7 select-window -t 7
        bind -n -N "Switch to window 8" M-8 select-window -t 8
        bind -n -N "Switch to window 9" M-9 select-window -t 9


        # Synchronize Panes
        bind C-a setw synchronize-panes \; display-message "Sync: #{?pane_synchronized,ON,OFF}"

        # General Settings
        set -g default-terminal "tmux-256color"
        set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
        set -ga terminal-overrides ',xterm-256color:Ms=\E]52;c;%p2%s\7'
        set -g mouse on
        set -g base-index 1
        setw -g pane-base-index 1
        set -g renumber-windows on
        set -g history-limit 50000
        set -g escape-time 0
        set -g focus-events on
        set -g set-clipboard on
        set -g allow-passthrough on
        setw -g aggressive-resize on
        set -g detach-on-destroy off
        set -g set-titles on
        set -g @resurrect-capture-pane-contents 'on'
        set -g @continuum-restore 'on'


        # Status Bar
        set -g status-position top
        set -g status-interval 5
        set -g status-left-length 30
        set -g status-right-length 50
        set -gw automatic-rename on
        set -gw automatic-rename-format '#W'
        set -g window-style 'bg=terminal'
        set -g window-active-style 'bg=terminal'

        # tmux-floax
        set -g @plugin 'omerxx/tmux-floax'
        set -g @floax-bind 't'
        set -g @floax-bind-menu 'T'
        set -g @floax-width '88%'
        set -g @floax-height '76%'
        set -g @floax-border-color '#ff6f00'
        set -g @floax-text-color '#c8d1dc'
        set -g @floax-session-name 'popup-shell'
        set -g @floax-title ' floax '
        bind g if-shell "command -v lazygit >/dev/null 2>&1" \
          "display-popup -E -x C -y C -w 88% -h 76% -T ' lazygit ' -d '#{pane_current_path}' 'lazygit'" \
          "display-message 'lazygit not found in PATH'"

        bind D if-shell "command -v lazydocker >/dev/null 2>&1" \
          "display-popup -E -x C -y C -w 88% -h 76% -T ' lazydocker ' -d '#{pane_current_path}' 'lazydocker'" \
          "display-message 'lazydocker not found in PATH'"


      '';
    in
    {
      packages.tmux = inputs.wrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.tmux;
        flags = {
          "-f" = toString (pkgs.writeText "tmux.conf" tmuxConfRaw);
        };
      };
    };

  flake.modules.nixos.core =
    { pkgs, ... }:
    {
      nixpkgs.overlays = [
        (_: _prev: {
          inherit (pkgs.custom) tmux;
        })
      ];

      environment.systemPackages = [
        pkgs.tmux # overlay-ed above
      ];

      custom.programs.print-config = {
        tmux = /* sh */ ''moor "${pkgs.custom.tmux.flags."-f"}"'';
      };
    };
}
