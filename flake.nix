{
  description = "Ruby Dev Env";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell/main";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs =
    { self
    , nixpkgs
    , flake-utils
    , devshell
    , flake-compat
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      cwd = builtins.toString ./.;
      overlays = map (x: x.overlays.default) [
        devshell
      ];
      pkgs = import nixpkgs { inherit system overlays; };
    in
    rec {

      # nix develop
      devShell = pkgs.devshell.mkShell {
        env = [
        ];
        commands = [
          {
            name = "release";
            command = "bundle exec rake release \"$@\"";
            help = "Run rake release, which adds a tag and pushes to RubyGems";
            category = "Ruby";
          }
          {
            name = "rubocop";
            command = "bundle exec rubocop \"$@\"";
            help = "Run rubocop";
            category = "Ruby";
          }
          {
            name = "lint";
            command = "bundle exec rubocop \"$@\"";
            help = "Run rubocop";
            category = "Ruby";
          }
          {
            name = "rspec";
            command = "bundle exec rspec \"$@\"";
            help = "Run test suite";
            category = "Ruby";
          }
          {
            name = "update-flakes";
            command = "make update-flakes \"$@\"";
            help = "Update all flakes";
            category = "Nix";
          }
        ];
        packages = with pkgs; [
          bash
          curl
          fd
          fzf
          gnused
          jq
          nodejs
          # rubocop
          # ruby
          # rubyfmt # Broken
          rubyPackages.ruby-lsp
          rubyPackages.solargraph
          rubyPackages.sorbet-runtime
          ripgrep
          wget
        ];
      };
    });
}
