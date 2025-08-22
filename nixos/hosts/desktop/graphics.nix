{...}: {
  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics = {
    enable = true;
  };
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=0"
    # "nvidia.NVreg_PreserveVideoMemoryAllocations=1"  # Temporarily disabled due to display detection issues
  ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    forceFullCompositionPipeline = true;
  };
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';
}
