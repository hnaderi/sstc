let
  pkgs = import <nixpkgs> { };
  kicad = pkgs.kicad;
  compile = pkgs.writeShellScriptBin "compile" ''
    ${kicad}/bin/kicad-cli sch export $1 $2
  '';
  exportSTLs = pkgs.writeShellScriptBin "exportSTLs" ''
    ls parts/*.FCStd | xargs -i bash -c "freecad --console {} < parts/export.py"
  '';
in pkgs.mkShell {
  name = "sstc";
  buildInputs = [ compile exportSTLs kicad pkgs.freecad ];
}
