# Python package-set overlay that builds the monorepo components.
#
# Every derivation reads its dependency list and build backend from the
# component's own pyproject.toml, so the flake follows upstream as the trees
# move. The only hand-maintained pieces are: the version-file locations, the
# packages nixpkgs does not carry (`skipped`), and the native build wiring
# (Rust for angr, CMake for pyvex and pypcode).
{
  lib,
  src, # the monorepo root
  angrDataSrc, # checkout of github:angr/angr-data (flake input)
}:
python-final: python-prev:
let
  inherit (python-final) buildPythonPackage;
  pkgs = python-final.pkgs;

  # PEP 503 normalisation; nixpkgs attribute names follow it.
  normalize = n: lib.toLower (builtins.replaceStrings [ "_" "." ] [ "-" "-" ] n);
  specName = spec: normalize (builtins.head (builtins.match "^[[:space:]]*([A-Za-z0-9][A-Za-z0-9._-]*).*$" spec));
  windowsOnly = spec: builtins.match ".*platform_system[[:space:]]*==[[:space:]]*['\"]Windows['\"].*" spec != null;

  # Runtime requirements nixpkgs does not package. Upstream guards both imports
  # with try/except (cle/backends/pe/pe.py, cle/backends/uefi_firmware.py), so
  # only the PDB-via-DIA and UEFI-firmware paths lose functionality.
  skipped = [
    "pyxdia"
    "uefi-firmware"
  ];
  # z3 ships no dist-info, so the runtime-deps check cannot see it; the module
  # is still propagated through `dependencies`.
  removedFromMetadata = skipped ++ [ "z3-solver" ];

  depsOf =
    specs:
    map (n: python-final.${n}) (
      lib.filter (n: !(lib.elem n skipped)) (map specName (lib.filter (s: !(windowsOnly s)) specs))
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

        build-system = depsOf pyproject.build-system.requires;
        dependencies = depsOf (pyproject.project.dependencies or [ ]) ++ extraDependencies;

        # Sibling pins (cle==9.3.4.dev0 ...) and third-party exact pins
        # (lmdb==2.1.1, z3-solver==4.13.0.0 ...) are relaxed in the wheel
        # metadata; the monorepo snapshots are what we ship.
        pythonRelaxDeps = true;
        pythonRemoveDeps = removedFromMetadata;

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
    extraDependencies = python-final.z3-solver.requiredPythonModules or [ ];
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
      unicorn = [ python-final.unicorn ];
    };

    pythonImportsCheck = [
      "angr"
      "angr.rustylib"
      "angr.ailment"
    ];
  };
}
