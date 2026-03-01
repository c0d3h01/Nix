# Host registry — single source of truth for the entire fleet.
# To add a machine, add one block. To add a user, add one sub-block.
{
  laptop = {
    system = "x86_64-linux";
    modules = [./laptop.nix];

    users.c0d3h01 = {
      isMainUser = true;
      fullName = "Harshal Sawant";
      workstation = true;
      windowManager = "gnome";
    };

    users.lara = {
      fullName = "Lara";
      workstation = true;
      windowManager = "gnome";
    };

    # Host-level knobs
    bootloader = "limine";
  };
}
