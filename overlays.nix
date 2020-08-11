builtins.map (n: import (./overlays.d + ("/" + n)))
(builtins.attrNames (builtins.readDir ./overlays.d))
