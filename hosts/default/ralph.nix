{
  rustPlatform,
  pkg-config,
  openssl,
  src,
}:
rustPlatform.buildRustPackage {
  pname = "ralph-cli";
  version = "2.1.1";

  # We inherit the 'src' passed from the arguments
  inherit src;

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    allowBuiltinFetchGit = true;
  };

  nativeBuildInputs = [pkg-config];
  buildInputs = [openssl];

  # Skip tests to speed up the build
  doCheck = false;
}
