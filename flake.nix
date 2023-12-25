{
  description = "";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {nixpkgs, ...}: let
    mkLib = pkgs:
      import ./lib {
        inherit (pkgs) lib newScope;
      };

    eachSystem = systems: f: let
      # Merge together the outputs for all systems.
      op = attrs: system: let
        ret = f system;
        op = attrs: key:
          attrs
          // {
            ${key} =
              (attrs.${key} or {})
              // {${system} = ret.${key};};
          };
      in
        builtins.foldl' op attrs (builtins.attrNames ret);
    in
      builtins.foldl' op {} systems;

    eachDefaultSystem = eachSystem [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  in
    {
      inherit mkLib;

      overlays.default = _final: _prev: {};

      templates = {};
    }
    // eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      lib = mkLib pkgs;
    in {
      inherit lib;

      formatter = pkgs.alejandra;

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          alejandra
        ];
      };
    });
}