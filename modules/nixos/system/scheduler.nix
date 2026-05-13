{pkgs, ...}: {
  services.scx = {
    enable = false;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_beerland";
  };
}
