{ pkgs, lib, config, ... }:

{
  # Disable Stylix styling for Waybar so we can use our own custom config
  stylix.targets.waybar.enable = false;

  programs.waybar = {
    enable = true;
    # Use mkForce to override Stylix's attempt to inject styles
    style = lib.mkForce (builtins.readFile ./style.css);
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 36;
        margin-top = 6;
        margin-left = 10;
        margin-right = 10;
        
        modules-left = [ "niri/workspaces" "niri/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "pulseaudio" "network" "battery" "tray" ];

        "niri/workspaces" = {
          format = "{icon}";
          format-icons = {
            active = "";
            default = "";
          };
        };

        "niri/window" = {
            format = "{{}}";
            rewrite = {
                "(.*) - Mozilla Firefox" = "Firefox";
                "(.*) - Visual Studio Code" = "VS Code";
                "" = "Empty";
            };
        };

        "clock" = {
          format = "{%H:%M    %d/%m}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        "pulseaudio" = {
            format = "{icon} {volume}%";
            format-bluetooth = "{icon} {volume}%";
            format-muted = " Muted";
            format-icons = {
                headphone = "";
                hands-free = "";
                headset = "";
                phone = "";
                portable = "";
                car = "";
                default = ["" ""];
            };
            scroll-step = 1;
            on-click = "pavucontrol";
        };

        "network" = {
            format-wifi = "  {signalStrength}%";
            format-ethernet = " Connected";
            tooltip-format = "{essid} - {ifname} via {gwaddr}";
            format-linked = "{ifname} (No IP)";
            format-disconnected = "⚠ Disconnected";
            format-alt = "{ifname}:{essid} {ipaddr}/{cidr}";
        };

        "battery" = {
            states = {
                good = 95;
                warning = 30;
                critical = 15;
            };
            format = "{icon} {capacity}%";
            format-charging = " {capacity}%";
            format-plugged = " {capacity}%";
            format-alt = "{time} {icon}";
            format-icons = ["" "" "" "" ""];
        };

        "tray" = {
            icon-size = 18;
            spacing = 10;
        };
      };
    };
  };
}