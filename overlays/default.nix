builtins.map (n: import (../overlays + ("/" + n)))
  (builtins.attrNames (builtins.readDir ../overlays))
