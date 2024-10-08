let
  pkgs = import <nixpkgs> { };
  kicad = pkgs.kicad;
  compile = pkgs.writeShellScriptBin "compile" ''
    ${kicad}/bin/kicad-cli sch export $1 $2
  '';
in pkgs.mkShell {
  name = "sstc";
  buildInputs = [ compile kicad pkgs.freecad ];
}
