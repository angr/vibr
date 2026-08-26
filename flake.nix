{
  description = "angr monorepo: angr, cle, claripy, pyvex, archinfo and pypcode from one tree";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/6b5e5b7a6631f065bf6908986990b37d845f847f";
    # angr's function/type definitions ship as a separate package; keep the
    # 200 MB of JSON out of this tree and pin it through flake.lock instead.
    angr-data = {
      url = "github:angr/angr-data";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      angr-data,
    }:
    let
      inherit (nixpkgs) lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems = lib.genAttrs systems;

      pythonOverlay =
        pkgs:
        import ./nix/python-overlay.nix {
          inherit (pkgs) lib;
          src = self;
          angrDataSrc = angr-data;
        };

      overlay = final: prev: {
        pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [ (pythonOverlay final) ];
      };

      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };

      # Python 3.12 matches the angr development shell; upstream supports 3.12-3.14.
      pythonFor = pkgs: pkgs.python312;

      # angr/binaries fixture for the CFG check, pinned by commit and hash.
      fauxware =
        pkgs:
        pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/angr/binaries/8646be4eafa4f1fc285d787fb2b73426a5e11d19/tests/x86_64/fauxware";
          hash = "sha256-wtkGRaRemSIVk1R+VcYBqQG4D4B66W+Uxgp2Yd8LPgs=";
        };
    in
    {
      overlays.default = overlay;

      packages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          python = pythonFor pkgs;
          ps = python.pkgs;
          env = python.withPackages (p: [
            p.angr
            p.unicorn
          ]);
        in
        {
          default = env;
          angr = env;
          angr-lib = ps.angr;
          cle-lib = ps.cle;
          claripy-lib = ps.claripy;
          pyvex-lib = ps.pyvex;
          archinfo-lib = ps.archinfo;
          pypcode-lib = ps.pypcode;
          angr-data-lib = ps.angr-data;
        }
      );

      legacyPackages = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
        in
        {
          pythonPackages = (pythonFor pkgs).pkgs;
          python = pythonFor pkgs;
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = pkgsFor system;
          env = self.packages.${system}.angr;
          runPython =
            name: script: args:
            pkgs.runCommand name { nativeBuildInputs = [ env ]; } ''
              export HOME=$TMPDIR XDG_CONFIG_HOME=$TMPDIR XDG_CACHE_HOME=$TMPDIR XDG_DATA_HOME=$TMPDIR
              python3 ${script} ${args}
              touch $out
            '';
        in
        {
          import-smoke = runPython "angr-import-smoke" ./nix/checks/import_smoke.py "";
          fauxware-cfg = runPython "angr-fauxware-cfg" ./nix/checks/fauxware_cfg.py "${fauxware pkgs}";
        }
      );
    };
}
