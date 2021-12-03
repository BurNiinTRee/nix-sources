builtins.map (n: import (./modules + ("/" + n)))
(builtins.attrNames (builtins.readDir ./modules))
