# agenix rules file
#
# agenix defaults to `./secrets.nix` for recipient rules. We keep the actual
# mapping in `secrets/secrets.nix` but provide this small wrapper so you can run:
#
#   agenix -e secrets/foo.age
#
import ./secrets/secrets.nix
