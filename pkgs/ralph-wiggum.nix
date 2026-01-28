{
  lib,
  stdenvNoCC,
  bun,
  makeWrapper,
  writableTmpDirAsHomeHook,
  opencode,
  src,
}:

# Ralph Wiggum for OpenCode (upstream: Th0rgal/opencode-ralph-wiggum)
#
# Goal: make `ralph` available system-wide on NixOS, with the same UX as the upstream
# README's `npm install -g @th0rgal/ralph-wiggum`.
#
# Upstream behavior:
# - `ralph` is a CLI entrypoint.
# - It shells out to `opencode` and persists loop state in the current repo under `.opencode/`.
# - It requires Bun at runtime and executes `bun ralph.ts ...args`.
#
# Nix approach:
# - Pin the upstream git source via flake input/lock.
# - Build `node_modules` as a fixed-output derivation (offline after first build).
# - Install a `ralph` wrapper that runs Bun on the shipped `ralph.ts`.
# - Prefix PATH so `opencode` is found even without user PATH setup.

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ralph-wiggum";
  version = "1.0.9";

  inherit src;

  node_modules = stdenvNoCC.mkDerivation {
    pname = "${finalAttrs.pname}-node_modules";
    inherit (finalAttrs) version src;

    nativeBuildInputs = [
      bun
      writableTmpDirAsHomeHook
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      bun install \
        --cpu="*" \
        --frozen-lockfile \
        --ignore-scripts \
        --no-progress \
        --os="*"

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      find . -type d -name node_modules -exec cp -R --parents {} "$out" \;

      runHook postInstall
    '';

    dontFixup = true;

    # First build will fail with a hash mismatch.
    # Copy the suggested sha256 here to make the build reproducible.
    outputHash = "sha256-a85RbfPGyHMx/mHzqUZxcuQv9yBNqW+3w2jHV1o033Y=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
  };

  nativeBuildInputs = [
    bun
    makeWrapper
    writableTmpDirAsHomeHook
  ];

  configurePhase = ''
    runHook preConfigure

    cp -R ${finalAttrs.node_modules}/. .

    runHook postConfigure
  '';

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/ralph-wiggum"
    cp -v ralph.ts "$out/lib/ralph-wiggum/ralph.ts"

    mkdir -p "$out/bin"
    makeWrapper "${lib.getExe bun}" "$out/bin/ralph" \
      --add-flags "$out/lib/ralph-wiggum/ralph.ts" \
      --prefix PATH : "${lib.makeBinPath [ opencode ]}"

    runHook postInstall
  '';

  meta = {
    description = "Ralph Wiggum technique for OpenCode (CLI loop)";
    homepage = "https://github.com/Th0rgal/opencode-ralph-wiggum";
    license = lib.licenses.mit;
    mainProgram = "ralph";
    platforms = lib.platforms.linux;
  };
})
