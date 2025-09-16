{ pkgs, ... }:
{
  # Nouveau driver configuration
  boot.kernelModules = [ "nouveau" ];
  services.xserver.videoDrivers = [ "nouveau" ];

  environment.systemPackages = with pkgs; [
    vulkan-tools
  ];

  # Kernel parameters for stability
  boot.kernelParams = [
    "video=DP-1:2560x1440@143.973"
    "video=DP-3:1920x1080@119.982" # Stable refresh rate for ZOWIE monitor
  ];

  # Nouveau-specific module options
  boot.extraModprobeConfig = ''
    options nouveau tv_disable=1
    options nouveau ignorelid=1
  '';

  # Graphics stack + Vulkan (NVK)
  hardware.graphics = {
    enable = true;
    # Enable 32-bit userspace for Vulkan (Steam/Wine).
    enable32Bit = true;
  };

  # Ensure NVIDIA firmware is available for nouveau.
  hardware.enableRedistributableFirmware = true;

  # Prefer NVK (nouveau Vulkan ICD) as the primary Vulkan driver.
  # Use the runtime OpenGL/Vulkan driver profile symlinks to avoid store-path mismatches.
  environment.sessionVariables = {
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nouveau_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nouveau_icd.i686.json";
  };

  # # Enable hardware acceleration for Nouveau
  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     # Mesa for OpenGL acceleration
  #     mesa
  #     mesa.drivers
  #   ];
  # };
}
