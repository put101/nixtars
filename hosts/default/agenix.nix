{ lib, ... }:

{
  # agenix decrypt identity
  #
  # By default we use a dedicated age identity file.
  # On a fresh machine you must have this private key available for decryption.
  #
  # Create it with:
  #   mkdir -p ~/.config/agenix
  #   age-keygen -o ~/.config/agenix/keys.txt
  age.identityPaths = lib.mkDefault [
    "/home/tobi/.config/agenix/keys.txt"
  ];
}
