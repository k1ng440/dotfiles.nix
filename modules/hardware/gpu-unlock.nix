{
  flake.modules.nixos.hardware_gpu-unlock =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      kernel = config.boot.kernelPackages.kernel;
      # Pinned to the NV version baked into kernel/gpu_unlock recipes.h paths.
      nv = "610.43.03";
      gpuUnlock = pkgs.stdenv.mkDerivation rec {
        pname = "gpu-unlock";
        version = "2.0.0";

        src = pkgs.fetchFromGitHub {
          owner = "Zagitta";
          repo = "gpu-unlock";
          rev = "1fc6d628c49c7fba34ef3a2e7f758700d35ce890";
          sha256 = "sha256-E2fmxMc5nq0Jg+J+BVhIihaAoC8ay01DefHxmsa2uiM=";
        };

        # Same tarball/installer the Arch PKGBUILD pins; firmware paths in the
        # module source are hardcoded to gpu-unlock/${nv}/.
        nvSource = pkgs.fetchurl {
          url = "https://download.nvidia.com/XFree86/NVIDIA-kernel-module-source/NVIDIA-kernel-module-source-${nv}.tar.xz";
          hash = "sha256-fhGJI8eiPtw2EU1jJzpG4+BOmvmGlaQiA+esLf6fwdw=";
        };
        nvInstaller = pkgs.fetchurl {
          url = "https://download.nvidia.com/XFree86/Linux-x86_64/${nv}/NVIDIA-Linux-x86_64-${nv}-no-compat32.run";
          hash = "sha256-4IRFHbcwpt8p09dPZVdJxNI248lF99lLUgXoQxj+L5A=";
        };

        nativeBuildInputs =
          kernel.moduleBuildDependencies
          ++ (with pkgs; [
            python3
            zstd
          ]);

        hardeningDisable = [
          "pic"
          "format"
        ];

        postPatch = ''
          mkdir -p firmware_cache
          cp ${nvSource} firmware_cache/NVIDIA-kernel-module-source-${nv}.tar.xz
          cp ${nvInstaller} firmware_cache/NVIDIA-Linux-x86_64-${nv}-no-compat32.run
        '';

        buildPhase = ''
          runHook preBuild
          make firmware INPUTS=$PWD/firmware_cache ASSETS=$PWD/assets
          make -C kernel/gpu_unlock KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
          cp kernel/gpu_unlock/gpu_unlock.ko $out/lib/modules/${kernel.modDirVersion}/extra/

          mkdir -p $out/lib/firmware/gpu-unlock/${nv}
          cp assets/*.bin $out/lib/firmware/gpu-unlock/${nv}/
          runHook postInstall
        '';

        meta = {
          description = "Unlock full tensor core speed on GeForce RTX 20/30/40 series";
          homepage = "https://github.com/Zagitta/gpu-unlock";
          license = lib.licenses.gpl2Only;
          platforms = [ "x86_64-linux" ];
        };
      };
    in
    {
      # GSP/booter assets must be visible to request_firmware() in the initrd.
      hardware.firmware = [ gpuUnlock ];

      boot.extraModulePackages = [ gpuUnlock ];

      boot.initrd.kernelModules = lib.mkBefore [ "gpu_unlock" ];

      boot.kernelParams = lib.mkAfter [ "gpu_unlock.targets=all" ];
    };
}
