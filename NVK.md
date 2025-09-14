> Here’s what NVK needs on NixOS and what I changed to make it the primary Vulkan driver on your desktop host.

What NVK needs

- Kernel/Mesa: NVK requires Linux ≥ 6.6 and Mesa ≥ 24.1. On April 22, 2025 Collabora announced NVK is Vulkan 1.3 conformant and enabled by default
  for Maxwell/Pascal/Volta starting with Mesa 25.1; Mesa’s docs now list NVK as Vulkan 1.4 conformant on supported GPUs. (collabora.com (https://
  www.collabora.com/news-and-blog/news-and-events/nvk-enabled-for-maxwell%2C-pascal%2C-and-volta-gpus.html?utm_source=openai))
- Nouveau only: Ensure the proprietary NVIDIA stack is not in use or blacklisting Nouveau. NVK is the nouveau Vulkan driver (vulkan-nouveau in Arch terms).
  (wiki.archlinux.org (https://wiki.archlinux.org/title/Vulkan?utm_source=openai))
- Firmware: Nouveau needs the redistributable NVIDIA firmware available (from linux-firmware) for best functionality. (wiki.archlinux.org (https://
  wiki.archlinux.org/title/Nouveau?utm_source=openai))
- Where Vulkan ICDs live on NixOS: Vulkan driver manifests are under /run/opengl-driver/share/vulkan/icd.d; setting VK_ICD_FILENAMES forces the chosen ICD.
  (wiki.nixos.org (https://wiki.nixos.org/wiki/Graphics?utm_source=openai))

Your hardware and current state

- GPU: GeForce GTX 1080 (Pascal, GP104) with the nouveau kernel driver loaded; Wayland (niri). Kernel 6.16.6 on NixOS 25.11. This satisfies NVK’s kernel
  requirement and should pick up Mesa 25.x. Note: Maxwell/Pascal/Volta often run at boot clocks due to firmware limits, so expect limited performance even
  though Vulkan works. (collabora.com (https://www.collabora.com/news-and-blog/news-and-events/nvk-enabled-for-maxwell%2C-pascal%2C-and-volta-gpus.html?
  utm_source=openai))

Changes I made

- File: nixos/hosts/desktop/nouveau.nix - Enabled 32-bit Vulkan userspace (useful for Steam/Wine): hardware.graphics.enable32Bit = true; - Ensured firmware availability: hardware.enableRedistributableFirmware = true; - Forced NVK to be the primary Vulkan ICD via the runtime driver profile: - environment.sessionVariables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nouveau_icd.x86_64.json:/run/opengl-driver-32/share/
  vulkan/icd.d/nouveau_icd.i686.json"; - Left the nouveau X/WS driver and kernel module as you already had.
  These follow the NixOS guidance to select a specific Vulkan ICD using VK_ICD_FILENAMES and to rely on /run/opengl-driver for manifests.
  (infinisil.com (https://infinisil.com/docs/index.html?utm_source=openai))

Notes specific to your GTX 1080 (Pascal)

- You do not need the nouveau.config=NvGspRm=1 kernel parameter (that’s for Turing+ GSP firmware). Keep using nouveau as you have. (wiki.archlinux.org
  (https://wiki.archlinux.org/title/Nouveau?utm_source=openai))
- OpenGL: On Pascal, Mesa 25.1 did not switch GL to Zink by default (that change initially targeted Turing+). Vulkan goes through NVK; OpenGL likely still
  uses the classic Nouveau GL unless you explicitly opt into Zink. (collabora.com (https://www.collabora.com/news-and-blog/news-and-events/nvk-enabled-for-
  maxwell%2C-pascal%2C-and-volta-gpus.html?utm_source=openai))

How to rebuild and verify

- Rebuild:
  - just system-rebuild
- Verify NVK is active: - nix shell nixpkgs#vulkan-tools -c vulkaninfo | rg -i 'driver|api|nvidia|nvk' - You should see your NVIDIA GPU with a driver name showing NVK and Vulkan 1.3/1.4. The ICDs visible under /run/opengl-driver/share/vulkan/icd.d/
  should include nouveau_icd.x86_64.json. (wiki.nixos.org (https://wiki.nixos.org/wiki/Graphics?utm_source=openai))
- Optional quick test:
  - nix shell nixpkgs#vulkan-tools -c vkcube
