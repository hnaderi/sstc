let
  pkgs = import <nixpkgs> { };
  kicad = pkgs.kicad-small;
  compile = pkgs.writeShellScriptBin "compile" ''
    ${kicad}/bin/kicad-cli sch export $1 $2
  '';
  exportSTLs = pkgs.writeShellScriptBin "exportSTLs" ''
    ls parts/*.FCStd | xargs -i bash -c "freecad --console {} < parts/export.py"
  '';
  generate = pkgs.writeShellScriptBin "generate" ''
    compile pdf sstc-v1/sstc.kicad_sch
    compile svg sstc-v1/sstc.kicad_sch
    compile pdf sstc-v2/sstc-v2.kicad_sch
    compile svg sstc-v2/sstc-v2.kicad_sch
    exportSTLs

    mkdir -p public;
    mv *.pdf public
    mv *.svg public
    mv parts/*.stl public
  '';
in pkgs.mkShell {
  name = "sstc";
  buildInputs = [ compile exportSTLs generate kicad pkgs.freecad ];
}
