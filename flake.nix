{
    description = "Description of flake";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs";
        flake-parts.url = "github:hercules-ci/flake-parts";
        devshell.url = "github:numtide/devshell";
    };
    outputs = inputs@{flake-parts, ...}:
        flake-parts.lib.mkFlake { inherit inputs; } {
            imports = [
                inputs.devshell.flakeModule
            ];
            systems = [
                "x86_64-linux"
                "aarch64-darwin"
            ];
            perSystem = { config, pkgs, ... }: {
                devshells.default = {
                    packages = [
                        pkgs.hugo
                    ];
                };
            };
        };
}