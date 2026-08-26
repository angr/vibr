from __future__ import annotations

import angr
import archinfo
import claripy
import cle
import pypcode
import pyvex

print("angr", angr.__version__)
print("cle", cle.__version__, "claripy", claripy.__version__, "pyvex", pyvex.__version__)
print("archinfo", archinfo.__version__, "pypcode", pypcode.__version__)

irsb = pyvex.lift(b"\x90\xc3", 0x400000, archinfo.ArchAMD64())
assert irsb.jumpkind == "Ijk_Ret", irsb.jumpkind
assert irsb.size == 2, irsb.size

x = claripy.BVS("x", 32)
s = claripy.Solver()
s.add(x * 3 == 42)
assert s.eval(x, 1)[0] == 14

ctx = pypcode.Context("x86:LE:64:default")
tx = ctx.translate(b"\x90\xc3")
assert len(tx.ops) > 0

import angr.ailment  # noqa: E402

from angr.rustylib import SegmentList  # noqa: E402,F401

print("ok")

import angr.state_plugins.unicorn_engine as unicorn_engine  # noqa: E402

assert unicorn_engine.unicorn is not None, "python unicorn missing from environment"
assert unicorn_engine._UC_NATIVE is not None, "angr unicornlib did not load"
print("unicorn ok")
