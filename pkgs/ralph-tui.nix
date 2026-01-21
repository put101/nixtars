{
  lib,
  stdenvNoCC,
  bun,
  makeWrapper,
  writableTmpDirAsHomeHook,
  src,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ralph-tui";
  version = "0.3.0";

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

      mkdir -p $out
      find . -type d -name node_modules -exec cp -R --parents {} $out \;

      runHook postInstall
    '';

    dontFixup = true;

    outputHash = "sha256-zvc29IvbNx4m7yENsI7ss01maM5mCYVEdE12g6eecjE=";
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

  buildPhase = ''
    runHook preBuild

    bun run build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/ralph-tui"
    cp -r dist "$out/lib/ralph-tui/dist"

    mkdir -p "$out/bin"
    makeWrapper "${lib.getExe bun}" "$out/bin/ralph-tui" \
      --chdir "$out/lib/ralph-tui" \
      --add-flags "$out/lib/ralph-tui/dist/cli.js"

    runHook postInstall
  '';

  meta = {
    description = "Ralph TUI - AI Agent Loop Orchestrator";
    homepage = "https://github.com/subsy/ralph-tui";
    license = lib.licenses.mit;
    mainProgram = "ralph-tui";
    platforms = lib.platforms.linux;
  };
})
