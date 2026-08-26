# Python package-set overlay that builds the monorepo components.
#
# Every derivation reads its dependency list and build backend from the
# component's own pyproject.toml, so the flake follows upstream as the trees
# move. The hand-maintained pieces are: the version-file locations, the
# packages nixpkgs does not carry (`skipped`), the exact-version table
# (`pinned`) for the few third-party packages whose version matters, and the
# native build wiring (Rust for angr, CMake for pyvex and pypcode).
{
  lib,
  src, # the monorepo root
  angrDataSrc, # checkout of github:angr/angr-data (flake input)
}:
python-final: python-prev:
let
  inherit (python-final) buildPythonPackage;
  pkgs = python-final.pkgs;
  system = pkgs.stdenv.hostPlatform.system;

  # PEP 503 normalisation; nixpkgs attribute names follow it.
  normalize = n: lib.toLower (builtins.replaceStrings [ "_" "." ] [ "-" "-" ] n);
  specName = spec: normalize (builtins.head (builtins.match "^[[:space:]]*([A-Za-z0-9][A-Za-z0-9._-]*).*$" spec));
  # Requirements whose environment marker excludes the platforms we build for.
  notForUs =
    spec:
    builtins.match ".*platform_system[[:space:]]*==[[:space:]]*['\"]Windows['\"].*" spec != null
    || builtins.match ".*sys_platform[[:space:]]*==[[:space:]]*['\"](win32|emscripten)['\"].*" spec != null;

  # Runtime requirements nixpkgs does not package. Upstream guards both imports
  # with try/except (cle/backends/pe/pe.py, cle/backends/uefi_firmware.py), so
  # only the PDB-via-DIA and UEFI-firmware paths lose functionality.
  skipped = [
    "pyxdia"
    "uefi-firmware"
  ];

  # ---------------------------------------------------------------------------
  # Exact-version table.
  #
  # Most third-party pins are relaxed (pythonRelaxDeps) and the nixpkgs version
  # is used. The packages below are the exception: their version changes
  # behaviour in ways the test suites catch (z3 4.16's Python binding types
  # Z3_fpa_get_numeral_sign's out-parameter as c_bool and blows up FP solves;
  # pyelftools 0.32 rejects SHT_NULL sh_link before cle's soname guard runs), so
  # the overlay provides the version upstream develops against and checks every
  # component requirement against it at evaluation time. When upstream bumps a
  # `==` pin or raises a floor above the provided version, evaluation fails
  # with a message naming the package; extend the table rather than relaxing.
  #
  # These packages are resolved only by the component derivations and exposed
  # as `vibrPinned.<name>`; they deliberately do NOT replace the canonical
  # attributes of the shared package set. Overriding `pyelftools` globally
  # would rebuild auto-patchelf (a python3 env with pyelftools) and with it
  # rustc's bootstrap, i.e. hours of rebuilding for every user.
  pinned = {
    "z3-solver" = {
      version = "4.13.0.0";
      package =
        let
          version = "4.13.0.0";
          # PyPI wheels: fastest reliable route (a source build of z3 takes
          # tens of minutes and nixpkgs' z3 recipe carries patches for 4.16).
          wheels = {
            x86_64-linux = {
              platform = "manylinux2014_x86_64";
              hash = "sha256-jELegrbj/37mEofQPHr4qZ+fZVTN0SBMa5vKlv8ct/s=";
            };
            aarch64-linux = {
              platform = "manylinux2014_aarch64";
              hash = "sha256-nWIgIqNRHAWZFcVrLCMchLXBvhuC9FfXVg3aPZFkdP4=";
            };
            aarch64-darwin = {
              platform = "macosx_11_0_arm64";
              hash = "sha256-vKfVmmmaRAJHU3whgMUZ1oLJ3zUgoWziiPztYacNJT0=";
            };
            x86_64-darwin = {
              platform = "macosx_11_0_x86_64";
              hash = "sha256-Skcx/e2Rsy4YYeHHyW5QDadDu5QxJGysUffD/8DyG10=";
            };
          };
          wheel = wheels.${system} or (throw "z3-solver ${version}: no wheel hash recorded for ${system} in nix/python-overlay.nix");
        in
        buildPythonPackage {
          pname = "z3-solver";
          inherit version;
          format = "wheel";
          src = python-final.fetchPypi {
            pname = "z3_solver";
            inherit version;
            format = "wheel";
            python = "py2.py3";
            abi = "none";
            inherit (wheel) platform hash;
          };
          # libz3.so in the wheel links libstdc++ from the manylinux toolchain.
          nativeBuildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.autoPatchelfHook ];
          buildInputs = lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.stdenv.cc.cc.lib ];
          doCheck = false;
          pythonImportsCheck = [ "z3" ];
          meta = {
            description = "Z3 theorem prover Python bindings (pinned by claripy)";
            homepage = "https://github.com/Z3Prover/z3";
            license = lib.licenses.mit;
          };
        };
    };
    "pyelftools" = {
      version = "0.33";
      package = python-prev.pyelftools.overridePythonAttrs (old: rec {
        version = "0.33";
        src = python-final.fetchPypi {
          pname = "pyelftools";
          inherit version;
          hash = "sha256-Zg2C3L646D0XAr2X8iP3YWJdoGERwMyYjqxrirDBth8=";
        };
        # The sdist ships no test tree.
        doCheck = false;
      });
    };
  };

  # Enforce the table against a requirement string from `component`.
  matchVersion = op: spec: builtins.match (".*" + op + "[[:space:]]*([0-9][0-9A-Za-z.!+-]*).*") spec;
  checkPinned =
    component: spec:
    let
      name = specName spec;
      entry = pinned.${name};
      exact = matchVersion "==" spec;
      floor = matchVersion ">=" spec;
      provided = entry.version;
    in
    if !(pinned ? ${name}) then
      spec
    else if exact != null && builtins.head exact != provided then
      throw "${component} requires ${name}==${builtins.head exact} but nix/python-overlay.nix provides ${provided}; update the `pinned` table"
    else if floor != null && !(lib.versionAtLeast provided (builtins.head floor)) then
      throw "${component} requires ${name}>=${builtins.head floor} but nix/python-overlay.nix provides ${provided}; update the `pinned` table"
    else
      spec;

  resolve = n: if pinned ? ${n} then pinned.${n}.package else python-final.${n};
  depsOf =
    component: specs:
    map resolve (
      lib.filter (n: !(lib.elem n skipped)) (
        map specName (map (checkPinned component) (lib.filter (s: !(notForUs s)) specs))
      )
    );

  readPyproject = dir: builtins.fromTOML (builtins.readFile (dir + "/pyproject.toml"));

  versionFrom =
    file:
    let
      re = "__version__ = \"([^\"]+)\".*";
      line = lib.findFirst (l: builtins.match re l != null) (throw "no __version__ in ${toString file}") (
        lib.splitString "\n" (builtins.readFile file)
      );
    in
    builtins.head (builtins.match re line);

  mkComponent =
    {
      pname,
      versionFile,
      extraDependencies ? [ ],
      nativeBuildInputs ? [ ],
      postPatch ? "",
      ...
    }@args:
    let
      # builtins.path copies the component directory into its own
      # content-addressed store path. Referencing `src + "/${pname}"`
      # directly would make every derivation depend on the whole tree, so an
      # edit to flake.nix or a check script would rebuild the Rust extension.
      dir = builtins.path {
        path = src + "/${pname}";
        name = "${pname}-source";
      };
      pyproject = readPyproject dir;
    in
    buildPythonPackage (
      (removeAttrs args [
        "versionFile"
        "extraDependencies"
      ])
      // {
        inherit pname;
        version = versionFrom (dir + "/${versionFile}");
        pyproject = true;
        src = dir;

        build-system = depsOf pname pyproject.build-system.requires;
        dependencies = depsOf pname (pyproject.project.dependencies or [ ]) ++ extraDependencies;

        # Sibling pins (cle==9.3.4.dev0 ...) and third-party exact pins
        # (lmdb==2.1.1 ...) are relaxed in the wheel metadata; the monorepo
        # snapshots are what we ship. Packages in `pinned` are provided at the
        # required version instead, checked above.
        pythonRelaxDeps = true;
        pythonRemoveDeps = skipped;

        nativeBuildInputs = nativeBuildInputs;
        postPatch = ''
          python ${./relax-build-requires.py} pyproject.toml
        ''
        + postPatch;

        # The monorepo ships no test fixtures (angr/binaries).
        doCheck = false;

        meta = {
          license = lib.licenses.bsd2;
          homepage = "https://angr.io/";
        } // (args.meta or { });
      }
    );
in
{
  vibrPinned = lib.mapAttrs (_: entry: entry.package) pinned;

  angr-data = buildPythonPackage {
    pname = "angr-data";
    version = versionFrom (angrDataSrc + "/angr_data/__init__.py");
    pyproject = true;
    src = angrDataSrc;
    build-system = [ python-final.setuptools ];
    doCheck = false;
    pythonImportsCheck = [ "angr_data" ];
    meta.license = lib.licenses.bsd2;
  };

  archinfo = mkComponent {
    pname = "archinfo";
    versionFile = "archinfo/__init__.py";
    pythonImportsCheck = [ "archinfo" ];
  };

  pyvex = mkComponent {
    pname = "pyvex";
    versionFile = "pyvex/__init__.py";
    # scikit-build-core drives CMake itself; keep the nixpkgs cmake/ninja hooks
    # from configuring or building on their own.
    nativeBuildInputs = [
      pkgs.cmake
      pkgs.ninja
    ];
    dontUseCmakeConfigure = true;
    dontUseNinjaBuild = true;
    dontUseNinjaInstall = true;
    dontUseNinjaCheck = true;
    pythonImportsCheck = [ "pyvex" ];
    # angr's unicornlib compiles against these at build time.
    postInstall = ''
      test -d "$out/${python-final.python.sitePackages}/pyvex/include"
      test -d "$out/${python-final.python.sitePackages}/pyvex/lib"
    '';
    meta.license = with lib.licenses; [
      bsd2
      gpl2Only
    ];
  };

  pypcode = mkComponent {
    pname = "pypcode";
    versionFile = "pypcode/__version__.py";
    # setup.py invokes cmake itself (build tree under build/native).
    dontUseCmakeConfigure = true;
    pythonImportsCheck = [ "pypcode" ];
    meta.license = with lib.licenses; [
      bsd2
      asl20
      zlib
    ];
  };

  claripy = mkComponent {
    pname = "claripy";
    versionFile = "claripy/__init__.py";
    pythonImportsCheck = [ "claripy" ];
  };

  cle = mkComponent {
    pname = "cle";
    versionFile = "cle/__init__.py";
    pythonImportsCheck = [ "cle" ];
  };

  angr = mkComponent {
    pname = "angr";
    versionFile = "angr/__init__.py";

    # native/angr is a pyo3 cdylib built through setuptools-rust. The lock
    # file lists git dependencies (angr/icicle-emu); allowBuiltinFetchGit
    # fetches them by revision at evaluation time so no hashes are kept here.
    cargoDeps = pkgs.rustPlatform.importCargoLock {
      lockFile = builtins.path {
        path = src + "/angr/Cargo.lock";
        name = "angr-Cargo.lock";
      };
      allowBuiltinFetchGit = true;
    };
    nativeBuildInputs = [
      pkgs.rustPlatform.cargoSetupHook
      pkgs.cargo
      pkgs.rustc
    ];

    optional-dependencies = {
      angrdb = [ python-final.sqlalchemy ];
      keystone = [ python-final.keystone-engine ];
      unicorn = [ python-final.unicorn ];
    };

    pythonImportsCheck = [
      "angr"
      "angr.rustylib"
      "angr.ailment"
    ];
  };
}
