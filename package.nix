{
  lib,
  stdenv,
  src,
  nx-tzdb,
  cmake,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  qt6,
  SDL2,
  boost,
  catch2_3,
  cubeb,
  enet,
  ffmpeg,
  fmt,
  glslang,
  libopus,
  libusb1,
  libva,
  lz4,
  nlohmann_json,
  openal,
  rapidjson,
  openssl,
  speexdsp,
  vulkan-headers,
  vulkan-loader,
  vulkan-utility-libraries,
  zlib,
  zstd,
  gamemode,
}: let
  inherit
    (qt6)
    qtbase
    qtmultimedia
    qttools
    qtwayland
    qtwebengine
    wrapQtAppsHook
    ;
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "citron";
    version = "0.11.0";

    inherit src;

    nativeBuildInputs = [
      cmake
      ninja
      pkg-config
      wrapGAppsHook3
      wrapQtAppsHook
      glslang
      qttools
    ];

    buildInputs = [
      # Qt6
      qtbase
      qtmultimedia
      qtwayland
      qtwebengine

      # Core deps
      SDL2
      boost
      enet
      ffmpeg
      fmt
      libopus
      libusb1
      libva
      lz4
      nlohmann_json
      openal
      rapidjson
      openssl
      speexdsp
      vulkan-headers
      vulkan-loader
      vulkan-utility-libraries
      zlib
      zstd

      # Optional
      catch2_3
      cubeb
      gamemode
    ];

    postPatch = ''
      # Fix for Qt 6.10.0 compatibility
      substituteInPlace CMakeLists.txt \
        --replace-fail "find_package(Qt6 REQUIRED COMPONENTS Widgets" \
                       "find_package(Qt6 REQUIRED COMPONENTS Widgets GuiPrivate"
      substituteInPlace CMakeLists.txt \
        --replace-fail "set(CITRON_QT_COMPONENTS2 Core" \
                       "set(CITRON_QT_COMPONENTS2 Core GuiPrivate"
      substituteInPlace src/citron/CMakeLists.txt \
        --replace-fail "target_link_libraries(citron PRIVATE Boost::headers" \
                       "target_link_libraries(citron PRIVATE Boost::headers Qt6::GuiPrivate"

      # Copy pre-downloaded timezone data (already unpacked by Nix)
      mkdir -p externals/nx_tzdb/nx_tzdb
      cp -r ${nx-tzdb}/* externals/nx_tzdb/nx_tzdb/
    '';

    # Copy timezone data to build directory where cmake expects it
    preConfigure = ''
      mkdir -p build/externals/nx_tzdb
      cp -r externals/nx_tzdb/* build/externals/nx_tzdb/
    '';

    cmakeFlags = [
      "-GNinja"
      "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
      "-DCITRON_USE_BUNDLED_VCPKG=OFF"
      "-DCITRON_USE_BUNDLED_QT=OFF"
      "-DCITRON_USE_BUNDLED_FFMPEG=OFF"
      "-DCITRON_USE_BUNDLED_SDL2=OFF"
      "-DCITRON_USE_EXTERNAL_SDL2=OFF"
      "-DCITRON_USE_EXTERNAL_VULKAN_HEADERS=OFF"
      "-DCITRON_USE_EXTERNAL_VULKAN_UTILITY_LIBRARIES=OFF"
      "-DCITRON_TESTS=OFF"
      "-DCITRON_CHECK_SUBMODULES=OFF"
      "-DCITRON_ENABLE_LTO=OFF"
      "-DCITRON_USE_QT_MULTIMEDIA=ON"
      "-DCITRON_USE_QT_WEB_ENGINE=ON"
      "-DCITRON_DOWNLOAD_TIME_ZONE_DATA=OFF"
      "-DENABLE_QT_TRANSLATION=ON"
      "-DUSE_DISCORD_PRESENCE=ON"
      "-DCITRON_USE_FASTER_LD=OFF"
      "-DTITLE_BAR_FORMAT_RUNNING=citron | ${finalAttrs.version} {}"
      "-DTITLE_BAR_FORMAT_IDLE=citron | ${finalAttrs.version}"
    ];

    # Ensure Vulkan loader is found at runtime
    qtWrapperArgs = [
      "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [vulkan-loader]}"
    ];

    dontWrapGApps = true;

    preFixup = ''
      qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
    '';

    postInstall = ''
      # Install udev rules for input devices
      install -Dm644 $src/dist/72-citron-input.rules $out/lib/udev/rules.d/72-citron-input.rules
    '';

    meta = {
      description = "Nintendo Switch emulator forked from yuzu";
      homepage = "https://citron-emu.org";
      license = lib.licenses.gpl2Plus;
      maintainers = [];
      platforms = ["x86_64-linux"];
      mainProgram = "citron";
    };
  })
