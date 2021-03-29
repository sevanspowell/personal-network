{ writeShellScriptBin }:

writeShellScriptBin "eyd-bootstrap-install" (builtins.readFile ./install.sh)
