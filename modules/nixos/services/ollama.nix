{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.dotfiles.nixos.services.ollama;
in {
  options.dotfiles.nixos.services.ollama.enable = mkEnableOption "Ollama local LLM service";

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-rocm;

      environmentVariables = {
        OLLAMA_GPU_OVERHEAD = "0";
        HIP_VISIBLE_DEVICES = "0";
        OLLAMA_NUM_PARALLEL = "1";
      };
    };
  };
}
