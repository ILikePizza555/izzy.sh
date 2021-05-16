{
  pkgs ? import <nixpkgs> {}
}:

pkgs.stdenv.mkDerivation {
  name = "izzy-sh-website";
  buildInputs = with pkgs; [
    hugo
  ];
}
