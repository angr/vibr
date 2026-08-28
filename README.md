# vibr

vibr is a generated preview of the angr ecosystem: every component (`angr`,
`cle`, `claripy`, `pyvex`, `archinfo`, `pypcode`, ...) at its upstream
default-branch head with the maintainer's green open pull requests merged on
top, in one tree, installable with nix. It is not on PyPI, and nothing in it is
edited by hand: the `angr-maintain-vibr` skill in
[zardus/angr-agentic](https://github.com/zardus/angr-agentic) regenerates the
whole tree, and `vibr.json` records exactly what went in.

Do not send pull requests to this repository; they would be overwritten by the
next refresh. Send them to the upstream component, and they show up here once
they are open and green.

## Use it

```sh
nix shell github:angr/vibr#angr                        # python3 with angr on PATH
nix run github:angr/vibr#angr -- -c 'import angr'      # one-off interpreter
nix build github:angr/vibr#angr                        # ./result/bin/python3
nix flake check github:angr/vibr                       # import smoke test + a CFG on fauxware
```

The per-component derivations are `#angr-lib`, `#cle-lib`, `#claripy-lib`,
`#pyvex-lib`, `#archinfo-lib`, `#pypcode-lib` and `#angr-data-lib`. To build
your own environment, add the overlay to nixpkgs; it teaches every
`pythonXPackages` set the packages from this tree:

```nix
{
  inputs.vibr.url = "github:angr/vibr";
  outputs = { nixpkgs, vibr, ... }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; overlays = [ vibr.overlays.default ]; };
    in { packages.x86_64-linux.default = pkgs.python312.withPackages (p: [ p.angr p.unicorn ]); };
}
```

Test fixtures (`angr/binaries`) are never included.

## Contents

<!-- vibr:begin -->
Generated 2026-08-28T06:16:40+00:00 from a selection made 2026-08-28T06:16:40+00:00.

| Component | Base | Applied | Skipped | Excluded |
| --- | --- | ---: | ---: | ---: |
| [angr](https://github.com/angr/angr) | [b0feae57a9](https://github.com/angr/angr/commit/b0feae57a9e401292e03a6f9ffbd4b388d172bf5) | 84 (20 resolved) | 11 | 24 |
| [archinfo](https://github.com/angr/archinfo) | [f92307b32e](https://github.com/angr/archinfo/commit/f92307b32e138de45b6ed4e8ca7794b67fdff6f8) | 3 (1 resolved) | 1 | 1 |
| [claripy](https://github.com/angr/claripy) | [6ff4486278](https://github.com/angr/claripy/commit/6ff4486278af191304ae8188ed6faa643cf43087) | 1 | 0 | 1 |
| [cle](https://github.com/angr/cle) | [a4fb800319](https://github.com/angr/cle/commit/a4fb8003198229d33c84df6a82f749729232fd31) | 36 (5 resolved) | 6 | 11 |
| [pypcode](https://github.com/angr/pypcode) | [559aacdc9d](https://github.com/angr/pypcode/commit/559aacdc9d363fd19477d9daa40721279cd99248) | 3 | 0 | 0 |
| [pyvex](https://github.com/angr/pyvex) | [ab18a834ba](https://github.com/angr/pyvex/commit/ab18a834ba4a5320c3415eff971092ef2b940779) | 9 (5 resolved) | 0 | 0 |

### angr

Applied:
- [#6655](https://github.com/angr/angr/pull/6655) CFGFast: rebuild function graphs for fresh models
- [#6658](https://github.com/angr/angr/pull/6658) Add first-class WebAssembly runtime support
- [#6697](https://github.com/angr/angr/pull/6697) Decompiler: recognize convergent conditional exits
- [#6731](https://github.com/angr/angr/pull/6731) Decompiler: terminate trailing C labels with null statements
- [#6736](https://github.com/angr/angr/pull/6736) Decompiler: preserve supergraph statement order
- [#6742](https://github.com/angr/angr/pull/6742) Decompiler: preserve equal replacement block keys
- [#6745](https://github.com/angr/angr/pull/6745) Decompiler: preserve outer-switch exits through nested switches
- [#6746](https://github.com/angr/angr/pull/6746) AIL: preserve unary VEX conversion types
- [#6748](https://github.com/angr/angr/pull/6748) Ssailification: handle missing address-taken stack definitions
- [#6751](https://github.com/angr/angr/pull/6751) Preserve DirtyExpression guard and memory address during rewriting
- [#6794](https://github.com/angr/angr/pull/6794) SimWindows: Add the Windows ARM and AArch64 syscall calling conventions.
- [#6796](https://github.com/angr/angr/pull/6796) AIL: Support addresses that do not fit in a signed 64-bit integer.
- [#6798](https://github.com/angr/angr/pull/6798) AIL: Support processor-specific p-code memory spaces
- [#6804](https://github.com/angr/angr/pull/6804) Tolerate an architecture that has no program counter.
- [#6805](https://github.com/angr/angr/pull/6805) CFGFast: Fix the default exit of one-instruction blocks on delay-slot architectures -- resolved: union merge of tests: tests/analyses/cfg/test_cfgfast.py
- [#6807](https://github.com/angr/angr/pull/6807) Fix unbounded recursion when creating a state on PIC-24 and dsPIC
- [#6809](https://github.com/angr/angr/pull/6809) CFGFast: Stop aborting when a pre-executed block ends in a failure exit -- tolerated: pre-commit.ci - pr is ERROR
- [#6814](https://github.com/angr/angr/pull/6814) PcodeLifter: Give each project its own Sleigh context -- resolved: union merge of tests: tests/engines/pcode/test_pcode.py
- [#6815](https://github.com/angr/angr/pull/6815) Decompiler: Structure every overlay child before its parent
- [#6817](https://github.com/angr/angr/pull/6817) Pcode: Disassemble lazily and match VEX's block cache size. -- resolved: union merge of tests: tests/engines/pcode/test_pcode.py
- [#6822](https://github.com/angr/angr/pull/6822) JumpTableResolver: Follow the PowerPC branch alignment mask
- [#6823](https://github.com/angr/angr/pull/6823) CFGFast: Stop static_exits from running an unrelated SimProcedure and aborting the scan -- resolved: union merge of tests: tests/analyses/cfg/test_cfgfast.py
- [#6824](https://github.com/angr/angr/pull/6824) Spilling stores: Fix copy() and stop remapping LMDB under an open transaction.
- [#6828](https://github.com/angr/angr/pull/6828) CFGFast: Keep a function whose block ends in an undefined instruction -- resolved: union merge of tests: tests/analyses/cfg/test_cfgfast.py -- tolerated: pre-commit.ci - pr is ERROR
- [#6829](https://github.com/angr/angr/pull/6829) Decompiler: Keep the provisional call return read by machine code -- resolved: union merge of tests: tests/ailment/test_irsb.py
- [#6839](https://github.com/angr/angr/pull/6839) CFGFast: Read the bytes after a failed lift from memory
- [#6844](https://github.com/angr/angr/pull/6844) CFGFast: Resolve pending indirect jumps in the order the scan found them
- [#6845](https://github.com/angr/angr/pull/6845) Decompiler: preserve function entries during deduplication
- [#6846](https://github.com/angr/angr/pull/6846) Decompiler: Preserve path context in guarding conditions -- resolved: union merge of tests: tests/analyses/decompiler/test_condition_processor.py
- [#6847](https://github.com/angr/angr/pull/6847) Decompiler: Recover link registers used as general-purpose registers
- [#6848](https://github.com/angr/angr/pull/6848) Decompiler: Reset Thumb IT state at function entry
- [#6850](https://github.com/angr/angr/pull/6850) Decompiler: Preserve indirect store addresses across type casts
- [#6853](https://github.com/angr/angr/pull/6853) Decompiler: Preserve virtual-variable bindings across index collisions
- [#6854](https://github.com/angr/angr/pull/6854) Decompiler: Lower guarded loads to conditional expressions
- [#6900](https://github.com/angr/angr/pull/6900) Decompiler: Track ARM registers that save and restore the stack pointer
- [#6901](https://github.com/angr/angr/pull/6901) CFGFast: Do not delete a block another function still owns -- resolved: union merge of tests: tests/analyses/cfg/test_cfgfast.py
- [#6903](https://github.com/angr/angr/pull/6903) CFGFast: Correct a returning status that no return site supports -- resolved: union merge of tests: tests/analyses/cfg/test_cfgfast.py
- [#6905](https://github.com/angr/angr/pull/6905) Decompiler: Preserve Phoenix switch entry identities
- [#6908](https://github.com/angr/angr/pull/6908) Decompiler: Isolate structuring optimization probes -- resolved: union merge of tests: tests/analyses/decompiler/test_variable_map.py
- [#6910](https://github.com/angr/angr/pull/6910) CFGBase: Track the functions with no jobs left instead of rescanning
- [#6930](https://github.com/angr/angr/pull/6930) Serialize Soot addresses
- [#6932](https://github.com/angr/angr/pull/6932) Pcode: Lift an architecture whose word is not a power of two -- resolved: union merge of tests: tests/engines/pcode/test_pcode.py
- [#6933](https://github.com/angr/angr/pull/6933) SimState: Cover the registration order and single initialization of state plugins
- [#6934](https://github.com/angr/angr/pull/6934) Pcode: Fix partial reads of a unique written wide
- [#6935](https://github.com/angr/angr/pull/6935) Suppress pthread static-exit register fill warnings
- [#6938](https://github.com/angr/angr/pull/6938) Decompiler: stop rewriting outer-switch gotos inside nested loops
- [#6939](https://github.com/angr/angr/pull/6939) Decompiler: Decide the last-resort cycle fallback by the parent region
- [#6940](https://github.com/angr/angr/pull/6940) Decompiler: Render program bytes that are not valid UTF-8
- [#6943](https://github.com/angr/angr/pull/6943) CFGFast: Stop reporting a null terminator the string scan never saw -- resolved: union merge of tests: tests/analyses/cfg/test_cfgfast.py
- [#6944](https://github.com/angr/angr/pull/6944) Serialize the AIL switch-case head marker instead of losing the cache
- [#6945](https://github.com/angr/angr/pull/6945) Decompiler: Recover syslog variadic arguments
- [#6946](https://github.com/angr/angr/pull/6946) Decompiler: Preserve intra-function tail jumps
- [#6947](https://github.com/angr/angr/pull/6947) Ssailification: Drop a stack phi whose sources do not match its destination
- [#6948](https://github.com/angr/angr/pull/6948) CFGFast: Preserve authoritative function starts during reconstruction -- resolved: union merge of tests: tests/analyses/cfg/test_cfgfast.py
- [#6950](https://github.com/angr/angr/pull/6950) Recover semantic main prototypes from libc startup
- [#6951](https://github.com/angr/angr/pull/6951) sim_type: stop name-keyed memos collapsing distinct anonymous aggregates
- [#6953](https://github.com/angr/angr/pull/6953) Ssailification: seed the SSA traversal from the entry Clinic resolves
- [#6954](https://github.com/angr/angr/pull/6954) Preserve loop-header variables during expression folding
- [#6955](https://github.com/angr/angr/pull/6955) Decompiler: Preserve dereference precedence in member access -- resolved: union merge of tests: tests/analyses/decompiler/test_structured_codegen.py
- [#6957](https://github.com/angr/angr/pull/6957) CFGFast: Recognize i686 MinGW stack probes
- [#6958](https://github.com/angr/angr/pull/6958) Decompiler: resolve chained AIL merge graph splits
- [#6960](https://github.com/angr/angr/pull/6960) CFGBase: Do not let a zero-size node anchor a normalization group
- [#6961](https://github.com/angr/angr/pull/6961) AIL: Carry a gymrat Dirty statement through with its memory effects unset -- resolved: union merge of tests: tests/ailment/test_irsb.py
- [#6962](https://github.com/angr/angr/pull/6962) Decompiler: Respect the updated entry node address in DeadblockRemover
- [#6964](https://github.com/angr/angr/pull/6964) SimType: check the alignment sentinel before converting it to bits
- [#6966](https://github.com/angr/angr/pull/6966) Decompiler: handle sizeless children in widening casts -- resolved: union merge of tests: tests/analyses/decompiler/test_structured_codegen.py
- [#6969](https://github.com/angr/angr/pull/6969) SwitchDefaultCaseDuplicator: do not select constructs with no default-case block
- [#6970](https://github.com/angr/angr/pull/6970) ReturnMaker: report a return register the architecture does not have
- [#6971](https://github.com/angr/angr/pull/6971) MultiValues: make copy construction copy the offset map
- [#6973](https://github.com/angr/angr/pull/6973) StructurerBase: do not cut a block where a temporary crosses the cut
- [#6974](https://github.com/angr/angr/pull/6974) Decompiler: render expression jumps as computed gotos -- resolved: union merge of tests: tests/analyses/decompiler/test_structured_codegen.py
- [#6976](https://github.com/angr/angr/pull/6976) CFGFast: Restore the nodecode threshold that lets the smart scan escape -- tolerated: pre-commit.ci - pr is ERROR
- [#6979](https://github.com/angr/angr/pull/6979) SimType: a type narrower than one byte aligns to one byte, not to zero
- [#6980](https://github.com/angr/angr/pull/6980) CCodeGen: stop rendering an anonymous aggregate that contains itself forever -- resolved: union merge of tests: tests/analyses/decompiler/test_structured_codegen.py
- [#6981](https://github.com/angr/angr/pull/6981) CCodeGen: emit the class-key of a C++ class definition once -- resolved: union merge of tests: tests/analyses/decompiler/test_structured_codegen.py
- [#6983](https://github.com/angr/angr/pull/6983) Decompiler: emit legal C prototypes for array returns
- [#6987](https://github.com/angr/angr/pull/6987) Decompiler: identify the function entry block by the entry node, not the address
- [#6988](https://github.com/angr/angr/pull/6988) SimEngineLightAIL: dispatch an unlisted operator to the default handler
- [#6991](https://github.com/angr/angr/pull/6991) RegisterSaveAreaSimplifier: Drop a link register that is only restored
- [#6992](https://github.com/angr/angr/pull/6992) Bound stack variable extents at a size the ssailification traversal can afford
- [#6996](https://github.com/angr/angr/pull/6996) RustCodeGen: keep the operands of an operator with no renderer
- [#6998](https://github.com/angr/angr/pull/6998) Atom.from_argument: report a register the architecture does not have
- [#6999](https://github.com/angr/angr/pull/6999) CodeGen: size a store from the store, not from its value's type -- resolved: union merge of tests: tests/analyses/decompiler/test_structured_codegen.py
- [#7000](https://github.com/angr/angr/pull/7000) Emit every leftover node when structuring does not complete

Skipped at assembly:
- [#6808](https://github.com/angr/angr/pull/6808) SpillingCFG: Index the nodes that an edge inserts into the graph -- conflicts in tests could not be union-merged: tests/analyses/cfg/test_cfgfast.py
- [#6818](https://github.com/angr/angr/pull/6818) SimProcedures: Fix pthread_create.static_exits(). -- conflicts with the applied set: angr/procedures/posix/pthread.py
- [#6827](https://github.com/angr/angr/pull/6827) CFGFast: Recognize NOP padding instead of seeding a function at it -- conflicts in tests could not be union-merged: tests/analyses/cfg/test_cfgfast.py
- [#6911](https://github.com/angr/angr/pull/6911) Decompiler: Preserve recorded goto identities -- conflicts with the applied set: angr/analyses/decompiler/optimization_passes/duplication_reverter/duplication_reverter.py, tests/analyses/decompiler/test_structured_codegen.py
- [#6936](https://github.com/angr/angr/pull/6936) Make function graphs observable and owned -- conflicts with the applied set: angr/knowledge_plugins/functions/function_manager.py, angr/knowledge_plugins/functions/soot_function.py
- [#6941](https://github.com/angr/angr/pull/6941) Bound the memory kb.decompilations holds when decompiling many functions -- conflicts with the applied set: angr/knowledge_plugins/structured_code.py
- [#6956](https://github.com/angr/angr/pull/6956) Decompiler: Recover variadic arguments through gettext -- conflicts in tests could not be union-merged: tests/analyses/decompiler/test_variadic_callsite_args.py
- [#6959](https://github.com/angr/angr/pull/6959) Decompiler: handle shift counts wider than shifted values -- conflicts in tests could not be union-merged: tests/analyses/decompiler/test_condition_processor.py
- [#6963](https://github.com/angr/angr/pull/6963) Decompiler: rebuild duplication reverter jump targets -- conflicts with the applied set: angr/analyses/decompiler/optimization_passes/duplication_reverter/ail_merge_graph.py, angr/analyses/decompiler/optimization_passes/duplication_reverter/duplication_reverter.py
- [#6982](https://github.com/angr/angr/pull/6982) Register MIPS n32 calling conventions -- conflicts with the applied set: pyproject.toml
- [#6984](https://github.com/angr/angr/pull/6984) CFGFast: Do not delete a block another function still owns -- conflicts with the applied set: angr/analyses/cfg/cfg_fast.py, tests/analyses/cfg/test_cfgfast.py

Excluded by selection:
- [#6679](https://github.com/angr/angr/pull/6679) AIL: preserve LL/SC result definitions and effects -- draft
- [#6685](https://github.com/angr/angr/pull/6685) SSA: guard missing loop stack outstates -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6743](https://github.com/angr/angr/pull/6743) Decompiler: reject ambiguous duplication reinsertion candidates -- draft
- [#6793](https://github.com/angr/angr/pull/6793) Support narrow p-code pointer widths -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6795](https://github.com/angr/angr/pull/6795) SimCGC: Keep the CGC defaults when a dump omits its optional backers. -- checks not green: Test Results concluded FAILURE
- [#6810](https://github.com/angr/angr/pull/6810) CFGFast: Do not record a call return site in an unmapped alignment hole -- checks not green: docs/readthedocs.org:angr is FAILURE
- [#6813](https://github.com/angr/angr/pull/6813) ArmElfFastResolver: Stop aborting CFGFast on an add of two registers -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6816](https://github.com/angr/angr/pull/6816) PcodeLifter: Stop a block from running past the bytes it was given -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6826](https://github.com/angr/angr/pull/6826) CFGBase: Leave overlapping blocks alone when their decodings conflict. -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6841](https://github.com/angr/angr/pull/6841) Decompiler: Remove GCC x87 clearing artifacts -- draft
- [#6861](https://github.com/angr/angr/pull/6861) CFGFast: Use a Mach-O function-start table for what it does not otherwise find -- checks not green: Test Results concluded FAILURE
- [#6864](https://github.com/angr/angr/pull/6864) CFG: Read a blob's executable map from its segments when it has one -- checks not green: Test Results concluded FAILURE
- [#6865](https://github.com/angr/angr/pull/6865) CFGFast: Do not judge a function by the block past a non-returning call -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6867](https://github.com/angr/angr/pull/6867) CFGFast: Delete the function that starts inside an instruction, not another one -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6880](https://github.com/angr/angr/pull/6880) JumpTableResolver: Recognize Mach-O zero fill and refuse a table read out of it -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6889](https://github.com/angr/angr/pull/6889) CFGFast: Do not decode an object CLE invented -- depends on angr/cle#765 which is excluded: moves a rebased object above the image instead of to 0; fails #730's test_overlap.py::test_outer_object_does_not_move_rebased_objects and #721's test_tls_resiliency.py::test_tls_24bit_arch, which assert the old placement
- [#6902](https://github.com/angr/angr/pull/6902) CFGFast: Fix a KeyError from _remove_redundant_overlapping_blocks on ARM. -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6904](https://github.com/angr/angr/pull/6904) Decompiler: Distinguish retries from structuring updates -- checks not green: docs/readthedocs.org:angr is FAILURE
- [#6929](https://github.com/angr/angr/pull/6929) CFGFast: Skip a whole undecodable RISC-V instruction, not one byte -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6952](https://github.com/angr/angr/pull/6952) Decompiler: rebind breaks and continues that no longer reach their target -- BreakRebinder rewrites switch-end breaks into a backwards goto; fails #6938's test_goto_leaving_a_switch_from_inside_a_loop_stays_a_goto; master+#6952 alone reproduces
- [#6972](https://github.com/angr/angr/pull/6972) RegionIdentifier: take the function entry as the region start node -- checks not green: docs/readthedocs.org:angr is FAILURE
- [#6975](https://github.com/angr/angr/pull/6975) RDA: keep the VEX result width when a vector comparison reaches a scalar handler -- checks not green: docs/readthedocs.org:angr is PENDING
- [#6978](https://github.com/angr/angr/pull/6978) StructurerBase: stop dropping a lone statement after a loop-exit jump -- checks not green: docs/readthedocs.org:angr is FAILURE
- [#7001](https://github.com/angr/angr/pull/7001) CFGFast: cover CFG recovery on a p-code ARM architecture -- checks not green: ci / Test (5) is IN_PROGRESS, Test Results concluded FAILURE


### archinfo

Applied:
- [#364](https://github.com/angr/archinfo/pull/364) Reject word sizes struct cannot express
- [#365](https://github.com/angr/archinfo/pull/365) Resolve sleigh language ids from arch_from_id -- resolved: union merge of tests: tests/test_pcode.py
- [#371](https://github.com/angr/archinfo/pull/371) Report the nop and ret encodings a big-endian machine holds in memory

Skipped at assembly:
- [#375](https://github.com/angr/archinfo/pull/375) Add ArchMIPSN32 for 64-bit MIPS with 32-bit pointers -- conflicts with the applied set: archinfo/arch.py

Excluded by selection:
- [#376](https://github.com/angr/archinfo/pull/376) is_arm_arch: match archinfo's ARM architectures, not a name prefix -- checks not green: ci / Test (5) is IN_PROGRESS


### claripy

Applied:
- [#737](https://github.com/angr/claripy/pull/737) Select the Pyodide Z3 build on Emscripten

Excluded by selection:
- [#742](https://github.com/angr/claripy/pull/742) Answer singlevalued and multivalued when no backend can bound cardinality -- checks not green: angr Ecosystem Test / Typecheck concluded FAILURE


### cle

Applied:
- [#714](https://github.com/angr/cle/pull/714) SRec: Fix record matching and entry point parsing
- [#715](https://github.com/angr/cle/pull/715) Load partial-memory minidumps
- [#720](https://github.com/angr/cle/pull/720) Probe UEFI compatibility without assuming a file object
- [#721](https://github.com/angr/cle/pull/721) Pack and unpack words struct cannot describe
- [#723](https://github.com/angr/cle/pull/723) ELF: Do not decode the dynamic table out of zero-fill
- [#724](https://github.com/angr/cle/pull/724) Load ARM64 and ARMNT COFF objects
- [#726](https://github.com/angr/cle/pull/726) CGC: Repair only the header bytes that are loaded
- [#727](https://github.com/angr/cle/pull/727) Mach-O: Read the LC_UNIXTHREAD entry point per cputype
- [#730](https://github.com/angr/cle/pull/730) Stop container objects from claiming their children's addresses
- [#731](https://github.com/angr/cle/pull/731) ELF: Tolerate a missing dynamic string table when reading soname and RELRO
- [#732](https://github.com/angr/cle/pull/732) Stop indexing PE and ELF header tables past their declared length
- [#733](https://github.com/angr/cle/pull/733) Encode R_ARM_THM_CALL over its full 25-bit displacement
- [#734](https://github.com/angr/cle/pull/734) ELFCore: Read register notes in the namespace that names them
- [#736](https://github.com/angr/cle/pull/736) Load static archives with a /SYM64/ symbol table
- [#739](https://github.com/angr/cle/pull/739) ELF: Stop unloaded sections from claiming a relocatable object's addresses
- [#740](https://github.com/angr/cle/pull/740) ELF: Apply the header fields a p-code opinion constrains
- [#755](https://github.com/angr/cle/pull/755) PE: Build base relocations on every architecture the backend resolves
- [#756](https://github.com/angr/cle/pull/756) PE: Read the ARM64 and ARMNT exception directory -- tolerated: Test windows-2022 concluded FAILURE
- [#757](https://github.com/angr/cle/pull/757) PE: Resolve the machine type of a ReadyToRun image built for another system
- [#760](https://github.com/angr/cle/pull/760) Regions: Stop the address lookups from assuming an order the list may not have -- resolved: union merge of tests: tests/test_regions.py
- [#766](https://github.com/angr/cle/pull/766) Give a PowerPC64 jump slot's extern a function descriptor
- [#768](https://github.com/angr/cle/pull/768) Survive a CIE that declares no FDE encoding
- [#770](https://github.com/angr/cle/pull/770) ELF: Read a line program in the DWARF format it declares
- [#773](https://github.com/angr/cle/pull/773) Relocate R_*_RELATIVE against the load bias, not the mapped base
- [#774](https://github.com/angr/cle/pull/774) UEFI: Load every FFS file type that carries a module image
- [#775](https://github.com/angr/cle/pull/775) COFF: Extend the object over the whole image it maps -- resolved: union merge of tests: tests/test_coff.py
- [#776](https://github.com/angr/cle/pull/776) Place the main binary at 0x400000 only when that space is free
- [#780](https://github.com/angr/cle/pull/780) Load a Mach-O MH_EXECUTE that a container backend owns
- [#783](https://github.com/angr/cle/pull/783) Load a bare DEX
- [#785](https://github.com/angr/cle/pull/785) ELF: Size imported objects from DWARF declarations -- resolved: union merge of tests: tests/test_extern.py
- [#786](https://github.com/angr/cle/pull/786) Use SimData types for untyped externs -- resolved: union merge of tests: tests/test_extern.py
- [#787](https://github.com/angr/cle/pull/787) Load a Mach-O relocatable object
- [#790](https://github.com/angr/cle/pull/790) PE: Back the whole image the section table declares -- resolved: union merge of tests: tests/test_pe.py
- [#792](https://github.com/angr/cle/pull/792) ELF: Survive a GNU hash table that declares no buckets
- [#795](https://github.com/angr/cle/pull/795) ELF: Resolve MIPS n32 and O64 from e_flags
- [#796](https://github.com/angr/cle/pull/796) MachO: Report a symbol in an instruction-bearing section as a function

Skipped at assembly:
- [#725](https://github.com/angr/cle/pull/725) Load minidumps whose writer left out a stream -- conflicts with the applied set: cle/backends/minidump/__init__.py, tests/test_minidump.py
- [#759](https://github.com/angr/cle/pull/759) Minidump: Describe a loaded module by the sections it actually has -- conflicts with the applied set: cle/backends/minidump/__init__.py, tests/test_minidump.py
- [#761](https://github.com/angr/cle/pull/761) COFF: Expose undefined externals through self.imports -- conflicts with the applied set: cle/backends/coff.py, tests/test_coff.py
- [#764](https://github.com/angr/cle/pull/764) COFF: Give a section with no file bytes an address of its own -- conflicts with the applied set: cle/backends/coff.py, tests/test_coff.py
- [#777](https://github.com/angr/cle/pull/777) ELF: Load the .eh_frame function hints without load_debug_info -- conflicts with the applied set: cle/backends/elf/elf.py
- [#788](https://github.com/angr/cle/pull/788) Make loader memory reads side-effect free -- conflicts with the applied set: cle/memory.py, tests/test_clemory.py

Excluded by selection:
- [#717](https://github.com/angr/cle/pull/717) Cover object placement in an address space narrower than a granule -- depends on angr/angr#6793 which is excluded: checks not green: docs/readthedocs.org:angr is PENDING
- [#718](https://github.com/angr/cle/pull/718) Fix Clemory backer removal and the BackedCGC backend -- depends on angr/angr#6795 which is excluded: checks not green: Test Results concluded FAILURE
- [#722](https://github.com/angr/cle/pull/722) Relocate MIPS HI16 and LO16 from the RELA addend -- checks not green: ci / Typecheck is IN_PROGRESS, ci / Test (0) is IN_PROGRESS, ci / Test (1) is IN_PROGRESS, ci / Test (2) is IN_PROGRESS, ci / Test (3) is IN_PROGRESS, ci / Test (4) is IN_PROGRESS, ci / Test (5) is IN_PROGRESS, ci / Test (6) is IN_PROGRESS, ci / Test (7) is IN_PROGRESS, ci / Test (8) is IN_PROGRESS, ci / Test (9) is IN_PROGRESS, ci / Decompiler Snapshot Testing (0) is IN_PROGRESS
- [#728](https://github.com/angr/cle/pull/728) Load Mach-O bundles and kernel extensions -- conflicts with the upstream default branch
- [#754](https://github.com/angr/cle/pull/754) Mach-O: Register the LC_FUNCTION_STARTS entries as function hints -- depends on angr/angr#6861 which is excluded: checks not green: Test Results concluded FAILURE
- [#758](https://github.com/angr/cle/pull/758) ELFCore: Keep the permissions of the mappings it turns into blobs -- depends on angr/angr#6864 which is excluded: checks not green: Test Results concluded FAILURE
- [#765](https://github.com/angr/cle/pull/765) Keep a rebased object out of the null page -- moves a rebased object above the image instead of to 0; fails #730's test_overlap.py::test_outer_object_does_not_move_rebased_objects and #721's test_tls_resiliency.py::test_tls_24bit_arch, which assert the old placement
- [#771](https://github.com/angr/cle/pull/771) ELF: Search /usr/lib/debug for a separate debug file -- draft
- [#789](https://github.com/angr/cle/pull/789) PE: Separate GNU EH-frame hints from unwind entries -- checks not green: ci / Test (0) concluded CANCELLED, ci / Test (1) concluded CANCELLED, ci / Test (2) concluded FAILURE, ci / Test (2) concluded CANCELLED, ci / Test (3) concluded FAILURE, ci / Test (3) concluded CANCELLED, ci / Test (4) concluded CANCELLED, ci / Test (5) concluded CANCELLED, ci / Test (6) concluded CANCELLED, ci / Test (7) concluded CANCELLED, ci / Test (8) concluded CANCELLED, ci / Test (9) concluded CANCELLED
- [#791](https://github.com/angr/cle/pull/791) ELF: Take the word size from the machine, not the container -- resolves x32 (ELFCLASS32/EM_X86_64) objects to AMD64 so ELFCore.__parse_auxv misreads the x32 auxv note; fails #734's test_prstatus_abi_mismatch
- [#793](https://github.com/angr/cle/pull/793) ELF: Select the ARM BE8 architecture when EF_ARM_BE8 is set -- draft


### pypcode

Applied:
- [#283](https://github.com/angr/pypcode/pull/283) Add Pyodide WebAssembly wheel support
- [#288](https://github.com/angr/pypcode/pull/288) Fix segfault when a delay-slot instruction has no p-code
- [#289](https://github.com/angr/pypcode/pull/289) Fix heap corruption on instructions that outgrow the parse tree


### pyvex

Applied:
- [#564](https://github.com/angr/pyvex/pull/564) Lifting: Tell libVEX how much of the lift buffer it may read.
- [#566](https://github.com/angr/pyvex/pull/566) Lifting: Decode RISC-V store-conditional and float comparisons again -- resolved: merged submodule vex: 88aa12d+3ce6fb2 -> bc1a64e
- [#567](https://github.com/angr/pyvex/pull/567) Keep the decoded prefix when MIPS32 meets a MIPS64-only instruction -- resolved: merged submodule vex: bc1a64e+561795c -> eccb0b1
- [#568](https://github.com/angr/pyvex/pull/568) Lifting: Handle mixed-width Thumb IT lookback -- resolved: merged submodule vex: eccb0b1+881703e -> e3bc1db
- [#569](https://github.com/angr/pyvex/pull/569) Do not fail the import when the FFI parser cache cannot be written
- [#570](https://github.com/angr/pyvex/pull/570) Lifting: Resolve s390x BRCTH branch targets past a 16-bit displacement -- resolved: merged submodule vex: e3bc1db+4f9a019 -> 26ed984
- [#571](https://github.com/angr/pyvex/pull/571) Lifting: Keep a stale s390x execute target from suppressing later EXRL expansion -- resolved: merged submodule vex: 26ed984+f7b8fcc -> 51e0a41
- [#573](https://github.com/angr/pyvex/pull/573) Do not lose a decode error to its own handler
- [#576](https://github.com/angr/pyvex/pull/576) Support MIPSN32 in the lifter
<!-- vibr:end -->

## How a pull request gets in

Candidates are the maintainer's open pull requests from the last 60 days in
the angr organisation. One is merged when it is not a draft, targets the
default branch, is mergeable against it, and is green on its last commit.
Green tolerates four kinds of red check, because they say nothing about
whether the code works on a Linux install: Windows builds, macOS builds,
codecov, and linting. At least one other check must exist and pass; a pull
request applied with a tolerated failure carries a `tolerated:` note in the
list above. The `excluded` lists name every candidate that failed one of
those rules and why, including the few kept out deliberately because they
break another applied pull request's tests.

A selected pull request can still be skipped at assembly time when its head
was force-pushed away, when upstream already contains it, or when it conflicts
in code with the pull requests applied before it. Conflicts confined to test
files are union-merged when the result still compiles, and conflicting
submodule pointers are resolved by merging the submodule commits; both appear
as a `resolved:` note.
