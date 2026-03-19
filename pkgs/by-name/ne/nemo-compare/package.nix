{
  python3,
  lib,
  fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "nemo-compare";
  version = "6.6.0";
  pyproject = true;

  # nixpkgs-update: no auto update
  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "nemo-extensions";
    rev = finalAttrs.version;
    hash = "sha256-tXeMkaCYnWzg+6ng8Tyg4Ms1aUeE3xiEkQ3tKEX6Vv8=";
  };

  sourceRoot = "${finalAttrs.src.name}/nemo-compare";

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "/usr/share" "share"

    substituteInPlace setup.py \
      --replace-fail "/usr/bin" "bin"
      
    substituteInPlace src/nemo-compare-preferences \
      --replace-fail "/usr/share/" "/run/current-system/sw/bin/"
    
    substituteInPlace src/nemo-compare.py \
      --replace-fail "/usr/share/" "/run/current-system/sw/bin/"

    substituteInPlace src/utils.py \
      --replace-fail "COMPARATOR_PATHS = [" "COMPARATOR_PATHS = ['/run/current-system/sw/bin/, "
  '';

  build-system = with python3.pkgs; [ setuptools ];

  meta = {
    homepage = "https://github.com/linuxmint/nemo-extensions/tree/master/nemo-compare";
    description = "Context menu comparison extension for Nemo file manager";
    longDescription = ''
      Context menu comparison extension for Nemo file manager
      When adding this to nemo-with-extensions you also need to add nemo-python,
      alongside a file comparison tool like meld. See the [debian control file for possible tools](https://github.com/linuxmint/nemo-extensions/blob/master/nemo-compare/debian/control)
    '';
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.denperidge ];
  };
})
