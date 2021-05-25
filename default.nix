{
  pkgs ? import <nixpkgs> {}
}:

pkgs.stdenv.mkDerivation {
  name = "izzy-sh-website";
  src = ./.;
  buildInputs = with pkgs; [
    git
    hugo
  ];
  installPhase = ''
    hugo -D --destination $out
  '';
}
