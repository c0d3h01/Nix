{
  services.libinput = {
    enable = true;

    # Mouse support for external USB/Bluetooth mice
    mouse = {
      accelProfile = "flat";
      naturalScrolling = true;
    };

    touchpad = {
      naturalScrolling = true; # Scroll direction matches finger movement
      tapping = true; # Enable tap-to-click
      tappingDragLock = true; # Hold finger to drag after double-tap
      clickMethod = "clickfinger"; # Left/Right/Middle based on button area
      disableWhileTyping = true; # Prevent accidental palm touches
      accelProfile = "adaptive"; # Smoother acceleration curve for precision
      accelSpeed = "0.2"; # Slightly faster than default for small trackpads
      sendEventsMode = "enabled"; # Auto-disable when mouse is plugged in
    };
  };
}
