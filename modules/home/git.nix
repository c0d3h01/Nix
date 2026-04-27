{pkgs, ...}: {
  programs.git = {
    enable = true;
    signing = {
      key = "A7A7A1725FBF10AB04BF1355B4242C21BAF74B7C";
      signByDefault = true;
    };
    settings = {
      user = {
        name = "Harshal Sawant";
        email = "harshalsawant.dev@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = "merges";
      push.autoSetupRemote = true;
      credential.helper = "libsecret";
      gpg.program = "gpg";
      tag.gpgsign = true;
      commit.gpgsign = true;
      core = {
        fsync = "committed";
        sshCommand = "${pkgs.openssh}/bin/ssh -T";
        editor = "nvim";
      };
      merge.conflictStyle = "diff3";
      diff.algorithm = "histogram";
      url."git@github.com:".insteadOf = "https://github.com/";
      url."git@gitlab.com:".insteadOf = "https://gitlab.com/";
    };
  };
}
