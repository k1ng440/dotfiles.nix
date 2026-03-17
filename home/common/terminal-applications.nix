{
  config,
  pkgs,
  ...
}:
{
  programs = {
    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "ansi";
      };
      extraPackages = with pkgs.bat-extras; [
        batman
        batpipe
        batgrep
      ];
    };

    btop = {
      enable = true;
      package = pkgs.btop.override {
        rocmSupport = true;
        cudaSupport = true;
      };
      settings = {
        color_theme = "rose-pine";
        vim_keys = true;
        rounded_corners = true;
        proc_tree = true;
        show_gpu_info = "on";
        show_uptime = true;
        show_coretemp = true;
        cpu_sensor = "auto";
        show_disks = true;
        only_physical = true;
        io_mode = true;
        io_graph_combined = false;
      };
    };

    htop = {
      enable = true;
      settings = {
        color_scheme = 6;
        cpu_count_from_one = 0;
        delay = 15;
        fields = with config.lib.htop.fields; [
          PID
          USER
          PRIORITY
          NICE
          M_SIZE
          M_RESIDENT
          M_SHARE
          STATE
          PERCENT_CPU
          PERCENT_MEM
          TIME
          COMM
        ];
        highlight_base_name = 1;
        highlight_megabytes = 1;
        highlight_threads = 1;
      }
      // (
        with config.lib.htop;
        leftMeters [
          (bar "AllCPUs2")
          (bar "Memory")
          (bar "Swap")
          (text "Zram")
        ]
      )
      // (
        with config.lib.htop;
        rightMeters [
          (text "Tasks")
          (text "LoadAverage")
          (text "Uptime")
          (text "Systemd")
        ]
      );
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      options = [
        "--cmd cd"
      ];
    };
  };

  # Custom themes for terminal applications
  xdg.configFile =
    let
      theme = import ./theme.nix { };
      inherit (theme) colors;
    in
    {
      "btop/themes/rose-pine.theme".text = ''
        # Rosé Pine btop theme
        theme[main_bg]="${colors.base}"
        theme[main_fg]="${colors.text}"
        theme[title]="${colors.text}"
        theme[hi_fg]="${colors.love}"
        theme[selected_bg]="${colors.overlay}"
        theme[selected_fg]="${colors.text}"
        theme[inactive_fg]="${colors.muted}"
        theme[graph_text]="${colors.pine}"
        theme[meter_bg]="${colors.surface}"
        theme[proc_misc]="${colors.iris}"
        theme[proc_grad_col]="${colors.pine}"
        theme[proc_grad_mid]="${colors.foam}"
        theme[proc_grad_top]="${colors.love}"
        theme[cpu_grad_low]="${colors.pine}"
        theme[cpu_grad_mid]="${colors.foam}"
        theme[cpu_grad_top]="${colors.love}"
        theme[mem_grad_low]="${colors.pine}"
        theme[mem_grad_mid]="${colors.foam}"
        theme[mem_grad_top]="${colors.love}"
        theme[net_grad_low]="${colors.pine}"
        theme[net_grad_mid]="${colors.foam}"
        theme[net_grad_top]="${colors.love}"
        theme[gpu_grad_low]="${colors.pine}"
        theme[gpu_grad_mid]="${colors.foam}"
        theme[gpu_grad_top]="${colors.love}"
        theme[temp_grad_low]="${colors.pine}"
        theme[temp_grad_mid]="${colors.gold}"
        theme[temp_grad_top]="${colors.love}"
        theme[cpu_bar_free]="${colors.pine}"
        theme[cpu_bar_mid]="${colors.foam}"
        theme[cpu_bar_top]="${colors.love}"
        theme[mem_bar_free]="${colors.pine}"
        theme[mem_bar_mid]="${colors.foam}"
        theme[mem_bar_top]="${colors.love}"
        theme[net_bar_free]="${colors.pine}"
        theme[net_bar_mid]="${colors.foam}"
        theme[net_bar_top]="${colors.love}"
        theme[gpu_bar_free]="${colors.pine}"
        theme[gpu_bar_mid]="${colors.foam}"
        theme[gpu_bar_top]="${colors.love}"
      '';
    };
}
