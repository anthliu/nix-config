{ config, pkgs, lib, inputs, ... }:

{
  imports = [ inputs.mango.hmModules.mango ];

  wayland.windowManager.mango = {
    enable = true;
    systemd.enable = true;

    settings = ''
      # === NVIDIA + wlroots (must be before any rendering) ===
      env=WLR_RENDERER,vulkan
      env=GBM_BACKEND,nvidia-drm
      env=WLR_NO_HARDWARE_CURSORS,1
      env=XDG_CURRENT_DESKTOP,mango
      env=NIXOS_OZONE_WL,1
      env=ELECTRON_OZONE_PLATFORM_HINT,auto

      # === Effects ===
      blur=0
      shadows=1
      shadow_only_floating=1
      shadows_size=12
      shadows_blur=15
      shadows_position_x=0
      shadows_position_y=0
      shadowscolor=0x000000ff

      border_radius=12
      focused_opacity=1.0
      unfocused_opacity=0.9

      # === Animations ===
      animations=1
      layer_animations=1
      animation_type_open=zoom
      animation_type_close=slide
      layer_animation_type_open=slide
      layer_animation_type_close=slide
      animation_fade_in=1
      animation_fade_out=1
      tag_animation_direction=1
      zoom_initial_ratio=0.4
      zoom_end_ratio=0.7
      animation_duration_move=500
      animation_duration_open=400
      animation_duration_tag=350
      animation_duration_close=800
      animation_duration_focus=400
      animation_curve_open=0.46,1.0,0.29,1.1
      animation_curve_move=0.46,1.0,0.29,1
      animation_curve_tag=0.46,1.0,0.29,1
      animation_curve_close=0.08,0.92,0,1
      animation_curve_focus=0.46,1.0,0.29,1

      # === Layout ===
      scroller_structs=20
      scroller_default_proportion=0.8
      scroller_focus_center=0
      scroller_prefer_center=1
      scroller_default_proportion_single=1.0
      scroller_proportion_preset=0.5,0.8,1.0

      new_is_master=1
      smartgaps=0
      default_mfact=0.55
      default_nmaster=1

      # === Overview ===
      hotarea_size=10
      enable_hotarea=1
      ov_tab_mode=0
      overviewgappi=5
      overviewgappo=30

      # === Misc ===
      xwayland_persistence=1
      syncobj_enable=0
      focus_on_activate=1
      sloppyfocus=1
      warpcursor=1
      focus_cross_monitor=0
      focus_cross_tag=0
      circle_layout=tile,scroller
      enable_floating_snap=1
      snap_distance=50
      drag_tile_to_tile=1

      # === Keyboard ===
      repeat_rate=25
      repeat_delay=600
      numlockon=1

      # === Trackpad ===
      tap_to_click=1
      tap_and_drag=1
      drag_lock=1
      mouse_natural_scrolling=0
      trackpad_natural_scrolling=1
      disable_while_typing=1

      # === Appearance ===
      gappih=4
      gappiv=4
      gappoh=8
      gappov=8
      borderpx=4
      rootcolor=0x1a1a2eff
      bordercolor=0x444444ff
      focuscolor=0x8BAA9Bff
      urgentcolor=0xad401fff
      scratchpadcolor=0xc4939dff

      # === Monitor Rules ===
      # Dell AW3423DWF (ultrawide)
      monitorrule=make:Dell Inc.,model:AW3423DWF,width:3440,height:1440,refresh:165,x:0,y:0,scale:1,vrr:0,rr:0
      # Samsung Odyssey G81SF
      monitorrule=make:Samsung Electric Company,model:Odyssey G81SF,width:3840,height:2160,refresh:240,x:3440,y:0,scale:1.25,vrr:0,rr:0

      # === Keybindings ===
      # Uses Super as the preferred modifier, staying close to mango defaults

      # Terminal and launcher
      bind=SUPER,Return,spawn,foot
      bind=SUPER,space,spawn,fuzzel
      bind=SUPER,e,spawn,thunar

      # Quit mango
      bind=SUPER,m,quit

      # Kill client
      bind=SUPER,q,killclient,

      # Focus direction (arrow keys)
      bind=SUPER,Left,focusdir,left
      bind=SUPER,Right,focusdir,right
      bind=SUPER,Up,focusdir,up
      bind=SUPER,Down,focusdir,down

      # Focus direction (vim keys)
      bind=SUPER,h,focusdir,left
      bind=SUPER,l,focusdir,right
      bind=SUPER,k,focusdir,up
      bind=SUPER,j,focusdir,down

      # Focus stack
      bind=SUPER,Tab,focusstack,next
      bind=SUPER,u,focuslast

      # Swap windows
      bind=SUPER+SHIFT,Left,exchange_client,left
      bind=SUPER+SHIFT,Right,exchange_client,right
      bind=SUPER+SHIFT,Up,exchange_client,up
      bind=SUPER+SHIFT,Down,exchange_client,down
      bind=SUPER+SHIFT,h,exchange_client,left
      bind=SUPER+SHIFT,l,exchange_client,right
      bind=SUPER+SHIFT,k,exchange_client,up
      bind=SUPER+SHIFT,j,exchange_client,down

      # Window states
      bind=SUPER,f,togglefullscreen,
      bind=SUPER+SHIFT,f,togglefakefullscreen,
      bind=SUPER,backslash,togglefloating,
      bind=SUPER,a,togglemaximizescreen,
      bind=SUPER,o,toggleoverlay,
      bind=SUPER,g,toggleglobal,
      bind=SUPER,i,minimized,
      bind=SUPER+SHIFT,i,restore_minimized

      # Overview
      bind=SUPER,grave,toggleoverview,0

      # Scratchpad
      bind=SUPER,z,toggle_scratchpad

      # Scroller layout controls
      bind=SUPER+CTRL,x,switch_proportion_preset,

      # Tile layout controls
      bind=SUPER+CTRL,e,incnmaster,1
      bind=SUPER+CTRL,t,incnmaster,-1
      bind=SUPER,s,zoom,

      # Switch layout
      bind=SUPER,n,switch_layout

      # Tag switching (Ctrl+1-9 to view tag, Super+1-9 to toggleview)
      bind=Ctrl,1,view,1,0
      bind=Ctrl,2,view,2,0
      bind=Ctrl,3,view,3,0
      bind=Ctrl,4,view,4,0
      bind=Ctrl,5,view,5,0
      bind=Ctrl,6,view,6,0
      bind=Ctrl,7,view,7,0
      bind=Ctrl,8,view,8,0
      bind=Ctrl,9,view,9,0

      # Move window to tag
      bind=SUPER+CTRL,1,tag,1,0
      bind=SUPER+CTRL,2,tag,2,0
      bind=SUPER+CTRL,3,tag,3,0
      bind=SUPER+CTRL,4,tag,4,0
      bind=SUPER+CTRL,5,tag,5,0
      bind=SUPER+CTRL,6,tag,6,0
      bind=SUPER+CTRL,7,tag,7,0
      bind=SUPER+CTRL,8,tag,8,0
      bind=SUPER+CTRL,9,tag,9,0

      # Toggle view tag
      bind=Super,1,toggleview,1
      bind=Super,2,toggleview,2
      bind=Super,3,toggleview,3
      bind=Super,4,toggleview,4
      bind=Super,5,toggleview,5
      bind=Super,6,toggleview,6
      bind=Super,7,toggleview,7
      bind=Super,8,toggleview,8
      bind=Super,9,toggleview,9

      # Monitor focus
      bind=SUPER+ALT,Left,focusmon,left
      bind=SUPER+ALT,Right,focusmon,right
      bind=SUPER+ALT,Up,focusmon,up
      bind=SUPER+ALT,Down,focusmon,down
      bind=SUPER+ALT,h,focusmon,left
      bind=SUPER+ALT,l,focusmon,right
      bind=SUPER+ALT,k,focusmon,up
      bind=SUPER+ALT,j,focusmon,down

      # Move window to monitor
      bind=SUPER+SHIFT+ALT,Left,tagmon,left
      bind=SUPER+SHIFT+ALT,Right,tagmon,right
      bind=SUPER+SHIFT+ALT,Up,tagmon,up
      bind=SUPER+SHIFT+ALT,Down,tagmon,down

      # Gaps
      bind=SUPER+SHIFT,equal,incgaps,1
      bind=SUPER+SHIFT,minus,incgaps,-1
      bind=SUPER+SHIFT,g,togglegaps

      # Volume & media keys
      bind=none,XF86AudioRaiseVolume,spawn_shell,wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0
      bind=none,XF86AudioLowerVolume,spawn_shell,wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-
      bind=none,XF86AudioMute,spawn_shell,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bind=none,XF86AudioMicMute,spawn_shell,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      bind=none,XF86AudioPlay,spawn,playerctl play-pause
      bind=none,XF86AudioStop,spawn,playerctl stop
      bind=none,XF86AudioPrev,spawn,playerctl previous
      bind=none,XF86AudioNext,spawn,playerctl next

      # Screenshot
      bind=SUPER,p,spawn_shell,grim -g "$(slurp)" - | wl-copy
      bind=none,Print,spawn_shell,grim - | wl-copy

      # Mouse bindings
      mousebind=SUPER,btn_left,moveresize,curmove
      mousebind=SUPER,btn_right,moveresize,curresize

      # Axis bindings
      axisbind=SUPER,UP,viewtoleft_have_client
      axisbind=SUPER,DOWN,viewtoright_have_client

      # Run autostart (activates systemd graphical-session.target → DMS Shell)
      exec-once=~/.config/mango/autostart.sh

      # Essential services
      exec-once=polkit-kde-authentication-agent-1
      exec-once=xwayland-satellite
      exec-once=mako
    '';

    autostart_sh = ''
      # Give compositor a moment to fully initialize
      # sleep 1
      # Start DMS shell (fallback in case systemd target doesn't trigger it)
      dms run &
    '';
  };

  # Set idle display commands for swayidle
  custom.idle = {
    displayOffCommand = "${pkgs.wlopm}/bin/wlopm --off '*'";
    displayOnCommand = "${pkgs.wlopm}/bin/wlopm --on '*'";
  };
}
