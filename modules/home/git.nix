{pkgs, ...}: {
  programs.gpg = {
    enable = true;
    settings = {
      keyid-format = "0xlong";
      with-fingerprint = true;
      charset = "utf-8";
      personal-digest-preferences = "SHA512";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      s2k-count = "65011712";
      no-comments = true;
      no-emit-version = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-gnome3;
    defaultCacheTtl = 14400;
    maxCacheTtl = 28800;
    extraConfig = "allow-loopback-pinentry";
  };

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
      gpg.program = "${pkgs.gnupg}/bin/gpg";
      tag.gpgSign = true;
      init.defaultBranch = "main";
      pull.rebase = true;
      core = {
        fsync = "committed";
        sshCommand = "ssh -T";
      };
      credential.helper = "libsecret";
    };
  };

  environment.sessionVariables = {
    GPG_TTY = "$TTY";
  };
}
