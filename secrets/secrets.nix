let
  # Add recipients (SSH public keys or age keys) here.
  #
  # Example (SSH key):
  #   tobi = "ssh-ed25519 AAAA...";
  #
  # Then reference it in `publicKeys` below.

  # Placeholder recipient set (replace with your real key(s)).
  recipients = {
    tobi = "age193h8ckeenu9uslugdgv28s598660my054tu2sptvwr92uu4jn4mqh7epwh";
  };

  # Convenience list used by most secrets.
  systems = builtins.attrValues recipients;
in
{
  # Hugging Face token (classic read token recommended).
  "secrets/huggingface.token.age".publicKeys = systems;

  # Private Internet Access environment file (optional).
  "secrets/pia.env.age".publicKeys = systems;
}
