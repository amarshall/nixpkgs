{
  bison,
  boost,
  cmake,
  config,
  cudaPackages,
  cudaSupport ? config.cudaSupport,
  fetchFromGitHub,
  flex,
  lib,
  libxml2,
  llvmPackages_19,
  openexr,
  openimageio,
  partio,
  pugixml,
  python3Packages,
  robin-map,
  stdenv,
  util-linux,
  zlib,
}:

let
  boost_static = boost.override { enableStatic = true; };
  inherit (llvmPackages_19) clang libclang llvm;
  stdenv' = if cudaSupport then cudaPackages.backendStdenv else stdenv;
  optix = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "optix-dev";
    tag = "v8.0.0";
    hash = "sha256-SXkXZHzQH8JOkXypjjxNvT/lUlWZkCuhh6hNCHE7FkY=";
  };
in
stdenv'.mkDerivation (finalAttrs: {
  pname = "openshadinglanguage";
  version = "1.15.1.0";

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = "OpenShadingLanguage";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+PNh4xFdH8onxK0OTnQHbdupTaB2hTgDumY0krJiWUE=";
  };

  cmakeFlags = [
    "-DVERBOSE=ON"
    "-DBoost_ROOT=${boost}"
    "-DUSE_BOOST_WAVE=ON"
    "-DENABLE_RTTI=ON"
    "-DPython3_ROOT=${python3Packages.python}"
    (lib.cmakeBool "OSL_USE_OPTIX" cudaSupport)

    # Build system implies llvm-config and llvm-as are in the same directory.
    # Override defaults.
    "-DLLVM_DIRECTORY=${llvm}"
    "-DLLVM_CONFIG=${llvm.dev}/bin/llvm-config"
    "-DLLVM_BC_GENERATOR=${clang}/bin/clang++"
  ] ++ lib.optionals cudaSupport [
    "-DOPTIXHOME=${optix}"
  ];

  prePatch = ''
    substituteInPlace src/cmake/modules/FindLLVM.cmake \
      --replace-fail "NO_DEFAULT_PATH" ""
    substituteInPlace src/cmake/cuda_macros.cmake --replace-fail '-D__CUDACC__' ""
  '';

  preConfigure = ''
    patchShebangs src/liboslexec/serialize-bc.bash
  '';

  hardeningDisable = lib.optional cudaSupport "zerocallusedregs";

  nativeBuildInputs = [
    bison
    clang
    cmake
    flex
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    boost_static
    libclang
    llvm
    openexr
    openimageio
    partio
    pugixml
    python3Packages.python
    python3Packages.pybind11
    robin-map
    util-linux # needed just for hexdump
    zlib
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_cccl
    cudaPackages.cuda_cudart
    cudaPackages.libcurand
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    libxml2
  ];

  propagatedBuildInputs = [
    python3Packages.openimageio
  ];

  postFixup = ''
    substituteInPlace "$out"/lib/pkgconfig/*.pc \
      --replace '=''${exec_prefix}//' '=/'
  '';

  __structuredAttrs = true;
  strictDeps = true;

  meta = {
    description = "Advanced shading language for production GI renderers";
    homepage = "http://openshadinglanguage.org";
    maintainers = [ ];
    license = lib.licenses.bsd3;
    platforms = lib.platforms.unix;
  };
})
