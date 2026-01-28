# Ollama v0.15.2 Upgrade Guide

## Executive Summary

This document explains the upgrade process of Ollama from v0.14.x to v0.15.2 in the nixtars NixOS configuration, including technical details, implementation decisions, and system impacts.

## Current State Analysis

### Before Upgrade
- **Version**: 0.14.x (from the pinned nixpkgs input)
- **Source**: Official nixpkgs package
- **GPU Support**: CUDA via `ollama-cuda` package
- **Service**: systemd service enabled with preloaded models
- **Installation**: System-wide via `environment.systemPackages`

### Target State
- **Version**: 0.15.2
- **Source**: nixpkgs `ollama`/`ollama-cuda` overridden via flake overlay
- **GPU Support**: Preserved CUDA acceleration
- **Service**: Uninterrupted continuation of existing service

## Why Upgrade is Necessary

### New Features in v0.15.2
For a complete and accurate list of changes, use the upstream release notes:

- https://github.com/ollama/ollama/releases/tag/v0.15.2

### Security Considerations
- Latest security patches included
- Dependency updates for Go toolchain
- GPU acceleration security improvements

## Technical Implementation

### Package Architecture Analysis

The current nixpkgs ollama package follows this structure:

```
buildGoModule {
  pname = "ollama";
  version = "0.14.x";  # Will be overridden
  
  src = fetchFromGitHub {
    owner = "ollama";
    repo = "ollama";
    tag = "v${version}";
    hash = "sha256-...";  # Updated per version
  };
  
  vendorHash = "sha256-...";  # Calculated per version
  
  # GPU Support Variants
  nativeBuildInputs = [ cmake gitMinimal ];
  buildInputs = 
    lib.optionals enableCuda [ cudaLibs ] ++
    lib.optionals enableRocm [ rocmLibs ] ++
    lib.optionals enableVulkan [ vulkanLibs ];
  
  # Runtime library wrapping
  postFixup = wrapProgram "$out/bin/ollama" ${wrapperArgs};
}
```

### Key Components

#### 1. Source Fetching
- **Method**: `fetchFromGitHub` with tag-based releases
- **Verification**: SHA256 hash for integrity
- **Versioning**: Semantic versioning with `v` prefix

#### 2. Build System
- **Type**: `buildGoModule` for Go projects with vendor files
- **Compilation**: Native Go compilation with C integration via CGO
- **GPU Integration**: CUDA/ROCm/Vulkan library linking

#### 3. GPU Acceleration
- **CUDA**: NVIDIA GPU support via cudaPackages
- **ROCm**: AMD GPU support via rocmPackages  
- **Vulkan**: Generic GPU acceleration
- **Library Path**: Dynamic LD_LIBRARY_PATH configuration

#### 4. Runtime Wrapping
- **Purpose**: Expose GPU libraries to ollama binary
- **Method**: `makeBinaryWrapper` with library path suffixes
- **Configuration**: Environment variables for GPU detection

## Implementation Strategy

### Chosen Approach: Overlay Override (Recommended)

**Decision Rationale:**
1. **Minimal Diff**: Keep nixpkgs packaging logic (CPU/CUDA/ROCm/Vulkan variants)
2. **Stable Service Config**: `services.ollama.package = pkgs.ollama-cuda;` stays valid
3. **Easy Updates**: Bump `version` + `src.hash` + `vendorHash` in one place
4. **Rollback Safety**: Remove/adjust the overlay entry

### Alternative: Local Package Copy
**Not Needed:**
- Copying nixpkgs' `ollama` packaging into `pkgs/` added maintenance burden and was error-prone.

## File Structure Changes

### Modified Files

```
flake.nix  # overlay overrides `pkgs.ollama` + `pkgs.ollama-cuda` to 0.15.2
```

### Configuration Impact

#### No Changes Required
- `hosts/default/configuration.nix` - remains identical
- Service configuration preserved
- Model storage location preserved
- All existing settings maintained

#### Seamless Upgrade Path
- No config change required: your system continues to use `pkgs.ollama-cuda`, now pinned to 0.15.2 via overlay
- Systemd service continues uninterrupted
- Model library remains accessible

## Build Process

### Phase 1: Hash Calculation
When bumping versions, you may need to update the Go vendor hash.

1. Temporarily set `vendorHash` to `lib.fakeHash` in `flake.nix`
2. Build once to get the correct hash from the error output
3. Put the reported hash back into `flake.nix`
4. Rebuild to verify

### Phase 2: Integration
1. Update `flake.nix` overlay overrides for `ollama` + `ollama-cuda`
2. Run dry-run build verification
3. Switch to new configuration
4. Verify service status and functionality

### Phase 3: Validation
1. Version verification: `ollama --version`
2. GPU acceleration test: `nvidia-smi` integration
3. Model loading: Verify existing models still accessible
4. API compatibility: Test existing client connections

## System Impact Analysis

### Storage Impact
- **Build Artifacts**: ~2GB additional during build
- **Final Installation**: Similar size to current (~400MB)
- **Model Storage**: No change, remains in `/var/lib/ollama/`

### Performance Impact
- **Startup Time**: Similar (small improvements in v0.15.2)
- **Memory Usage**: Reduced for GLM-4.7-Flash models
- **GPU Performance**: Enhanced CUDA optimizations

### Service Impact
- **Downtime**: None - seamless upgrade
- **Configuration**: Preserved entirely
- **Dependencies**: Updated Go runtime, potentially improved stability

## Risk Assessment

### Low Risk Factors
- **Package Structure**: Based on proven nixpkgs definition
- **Build Method**: Standard `buildGoModule` process
- **GPU Support**: Same approach as current package

### Mitigation Strategies
1. **Backup Current**: System generation automatically saved by NixOS
2. **Test Build**: Dry-run before system switch
3. **Service Check**: Verify ollama service post-upgrade
4. **Rollback Plan**: Revert flake.nix changes if issues occur

### Known Limitations
- **Build Time**: First build requires full compilation (~15 minutes)
- **Network**: Requires GitHub access during build
- **Storage**: Temporary space needed for build artifacts

## Future Maintenance

### Update Process
1. Check for new Ollama releases
2. Update `version`, `src.hash`, and `vendorHash` in `flake.nix`
4. Rebuild and test

### Automation Potential
```bash
#!/usr/bin/env bash
# update-ollama.sh
NEW_VERSION=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest | jq -r .tag_name | sed 's/v//')
echo "Update flake.nix overlay to version=$NEW_VERSION"
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Build Failures
- **Issue**: Vendor hash mismatch
- **Solution**: Set `vendorHash = lib.fakeHash` in `flake.nix`, rebuild, then copy the expected hash from the error.

#### GPU Issues
- **Issue**: CUDA libraries not found
- **Solution**: Verify `nixos-rebuild dry-run` shows correct dependencies

#### Service Issues
- **Issue**: Service fails to start
- **Solution**: Check journalctl logs, verify library paths with `ldd`

### Verification Commands
```bash
# Version check
ollama --version

# Service status
systemctl status ollama

# GPU verification
nvidia-smi
ollama run llama3.2:latest "What GPU are you using?"

# Model list
ollama list
```

## Conclusion

This upgrade provides the desired Ollama version while keeping nixpkgs' packaging logic and preserving existing configuration. The overlay approach keeps the change small and easy to update.

### Success Criteria
- [ ] `ollama --version` shows 0.15.2
- [ ] `systemctl status ollama` is healthy
- [ ] Models load successfully (e.g. `ollama list`, `ollama run ...`)
- [ ] CUDA acceleration works on this host

---

*Document Version: 1.1*  
*Last Updated: 2026-01-28*  
*Author: Generated for nixtars configuration*
