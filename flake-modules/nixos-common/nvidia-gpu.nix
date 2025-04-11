{ lib, ... }:
{
  hardware.nvidia-container-toolkit.mount-nvidia-executables = lib.mkDefault true;
  hardware.nvidia-container-toolkit.mount-nvidia-docker-1-directories = lib.mkDefault true;
  hardware.nvidia.nvidiaSettings = lib.mkDefault true;
  virtualisation.docker.enableNvidia = lib.mkDefault true;
}
