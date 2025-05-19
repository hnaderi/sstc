let
  pkgs = import <nixpkgs> { };
  kicad = pkgs.kicad-small;
  compile = pkgs.writeShellScriptBin "compile" ''
    ${kicad}/bin/kicad-cli sch export $1 $2
  '';
  renderPCB = pkgs.writeShellScriptBin "renderPCB" ''
    ${kicad}/bin/kicad-cli pcb render $1 -o $2
  '';
  exportSTLs = pkgs.writeShellScriptBin "exportSTLs" ''
    ls parts/*.FCStd | xargs -i bash -c "freecad --console {} < parts/export.py"
  '';
  makeWebsite = pkgs.writeShellScriptBin "makeWebsite" ''
    ${pkgs.ejs}/bin/ejs -f webpage/data.json -o public/index.html webpage/index.ejs
  '';
  generate = pkgs.writeShellScriptBin "generate" ''
    echo "Generating schematics ..."

    # Version 1
    compile pdf sstc-v1/sstc.kicad_sch
    compile svg sstc-v1/sstc.kicad_sch

    # Version 2
    compile pdf sstc-v2/sstc-v2.kicad_sch
    compile svg sstc-v2/sstc-v2.kicad_sch

    # Version 3
    compile pdf sstc-v3/sstc-v3.kicad_sch
    compile svg sstc-v3/sstc-v3.kicad_sch
    compile bom sstc-v3/sstc-v3.kicad_sch
    renderPCB sstc-v3/sstc-v3.kicad_pcb sstc-v3-pcb.png

    echo "Generating part objects ..."
    exportSTLs

    echo "Generating fabrication outputs ..."

    for fab in **/fab*/
    do
    echo Generating archive for $fab
    NAME=$(echo "$fab" | sed "s/.*\(fab[^\/]*\).*/\1/g")
    zip -jr "$NAME.zip" $fab
    done

    echo "Generating website ..."

    mkdir -p public;
    mv *.{pdf,svg,csv,png,zip} public
    mv parts/*.stl public

    makeWebsite
  '';
  serve = pkgs.writeShellScriptBin "serve" ''
    ${pkgs.http-server}/bin/http-server -o
  '';

in pkgs.mkShell {
  name = "sstc";
  buildInputs = [
    compile
    renderPCB
    makeWebsite
    exportSTLs
    generate
    serve
    kicad
    pkgs.freecad
  ];
}
