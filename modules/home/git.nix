{pkgs, ...}: let
  gpgBin = "${pkgs.gnupg}/bin/gpg";
in {
  programs.gpg = {
    enable = true;

    settings = {
      keyid-format = "0xlong";
      with-fingerprint = true;
      with-keygrip = true;
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      charset = "utf-8";

      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-cipher-preferences = "AES256 AES192 AES";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      s2k-count = "65011712";

      require-cross-certification = true;
      verify-options = "show-uid-validity";
      list-options = "show-uid-validity";
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-all;

    defaultCacheTtl = 28800;
    maxCacheTtl = 86400;
    defaultCacheTtlSsh = 28800;
    maxCacheTtlSsh = 86400;

    extraConfig = ''
      allow-loopback-pinentry
    '';
  };

  programs.git = {
    enable = true;
    lfs.enable = true;

    signing = {
      key = "A7A7A1725FBF10AB04BF1355B4242C21BAF74B7C";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Harshal Sawant";
        email = "harshalsawant.dev@gmail.com";
      };

      gpg.program = gpgBin;
      tag.gpgSign = true;

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      rebase.autoStash = true;
      merge.conflictStyle = "zdiff3";
      diff.algorithm = "histogram";
      rerere.enabled = true;
      core = {
        autocrlf = "input";
        whitespace = "trailing-space,space-before-tab";
        fsync = "committed";
      };

      credential.helper = "store --file ~/.git-credentials";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      side-by-side = false;
      line-numbers = true;
      syntax-theme = "base16";
    };
  };
}
