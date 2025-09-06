{ ... }:
{
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
    options nvidia_drm nvidia_uvm modeset=1 fbdev=1
  '';
  services.kmscon.enable = true;
}
