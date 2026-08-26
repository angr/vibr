#!/usr/bin/env python3
# pylint: disable=missing-class-docstring,no-self-use,no-member,protected-access
from __future__ import annotations

__package__ = __package__ or "tests.analyses.decompiler"  # pylint:disable=redefined-builtin

import unittest
from typing import Any, cast

import angr
from angr.ailment import Expr, Manager, Stmt
from angr.ailment.expression import VirtualVariableCategory
from angr.analyses.decompiler import CStructuredCodeGenerator
from angr.analyses.decompiler.variable_map import VariableMap
from angr.sim_type import SimTypeChar, SimTypePointer
from angr.sim_variable import SimRegisterVariable, SimStackVariable


def _make_codegen() -> CStructuredCodeGenerator:
    proj = angr.load_shellcode(b"\x31\xc0\xc3", arch="AMD64")
    cfg = proj.analyses.CFGFast(normalize=True)
    codegen = proj.analyses.Decompiler(cfg.functions[0], cfg=cfg).codegen
    assert isinstance(codegen, CStructuredCodeGenerator)
    return codegen
from angr.ailment import Block, Expr, Stmt
from angr.analyses.decompiler.jump_target_collector import JumpTargetCollector
from angr.analyses.decompiler.redundant_label_remover import RedundantLabelRemover
from angr.analyses.decompiler.structured_codegen.c import CGoto, CStructuredCodeGenerator
from angr.analyses.decompiler.structured_codegen.rust import RustGoto, RustStructuredCodeGenerator
from angr.analyses.decompiler.structurer_nodes import SequenceNode


class _ConditionalJumpCodegenHarness:
    cstyle_ifs = True

    @staticmethod
    def next_ident(name):
        return name

    @staticmethod
    def next_node_idx():
        return 0

    @staticmethod
    def _handle(node, **_kwargs):
        return node
from angr.ailment import Expr
from angr.analyses.decompiler import CStructuredCodeGenerator
from angr.analyses.decompiler.structured_codegen.c import (
    CBinaryOp,
    CConstant,
    CIndexedVariable,
    CStructField,
    CTypeCast,
    CUnaryOp,
    CVariable,
    CVariableField,
)
from angr.sim_type import SimStruct, SimTypeInt, SimTypePointer
from angr.sim_variable import SimRegisterVariable


class TestConvertRendering(unittest.TestCase):
    """How CStructuredCodeGenerator renders Convert expressions of assorted widths."""

    @classmethod
    def setUpClass(cls):
        # any decompilation will do; all we need is a codegen instance to render expressions with
        cls.codegen = _make_codegen()

    def _render(self, from_bits: int, to_bits: int, value: int = 0x1234) -> str:
        conv = Expr.Convert(0, from_bits, to_bits, False, Expr.Const(0, value, from_bits))
        return self.codegen._handle(conv).c_repr()

    def test_truncation_to_unrepresentable_width_is_masked(self):
        # No C type is 5, 3 or 1 bits wide. A cast would round up to the next real type and keep
        # bits the conversion discards, so these have to be spelled as a mask instead.
        assert self._render(32, 5) == "4660 & 31"
        assert self._render(32, 3) == "4660 & 7"
        assert self._render(32, 1) == "4660 & 1"

    def test_truncation_to_representable_width_is_a_cast(self):
        assert self._render(32, 8) == "(char)4660"
        assert self._render(32, 16) == "(unsigned short)4660"

    def test_widening_is_always_a_cast(self):
        # Rounding up only loses information when truncating, so widening keeps casting even to a
        # width no C type has.
        assert self._render(1, 5, value=1) == "(char)1"
        assert self._render(8, 12, value=3) == "(unsigned short)3"
        assert self._render(32, 64, value=3) == "(unsigned long long)3"


class TestStoreRendering(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.codegen = _make_codegen()

    def test_mismatched_store_cast_distinguishes_pointer_from_storage(self):
        manager = Manager(arch=self.codegen.project.arch)
        addr = Expr.VirtualVariable(
            manager.next_atom(), 1, self.codegen.project.arch.bits, VirtualVariableCategory.REGISTER
        )
        data = Expr.Const(manager.next_atom(), 0x11223344, 32)
        pointer_store = Stmt.Store(
            manager.next_atom(), addr, data, 4, self.codegen.project.arch.memory_endness, ins_addr=0x401000
        )
        direct_store = Stmt.Store(
            manager.next_atom(), addr, data, 4, self.codegen.project.arch.memory_endness, ins_addr=0x401004
        )
        addr_variable = SimRegisterVariable(0x28, self.codegen.project.arch.bytes, ident="ir_test", name="iter")
        storage_variable = SimStackVariable(-0x10, 4, ident="is_test", name="storage")
        variable_map = VariableMap()
        variable_map.set_variable(addr, addr_variable)
        variable_map.set_variable(direct_store, storage_variable)

        variable_manager = self.codegen.kb.dec_variables[self.codegen._func.addr]
        variable_manager.set_unified_variable(addr_variable, addr_variable)
        variable_manager.set_unified_variable(storage_variable, storage_variable)
        variable_manager.set_variable_type(
            addr_variable, SimTypePointer(SimTypeChar()).with_arch(self.codegen.project.arch)
        )
        variable_manager.set_variable_type(storage_variable, SimTypeChar().with_arch(self.codegen.project.arch))
        old_variable_map = self.codegen._variable_map
        self.codegen._variable_map = variable_map
        try:
            pointer_rendered = self.codegen._handle(pointer_store, is_expr=False).c_repr()
            direct_rendered = self.codegen._handle(direct_store, is_expr=False).c_repr()
        finally:
            self.codegen._variable_map = old_variable_map

        assert direct_rendered == "*((unsigned int *)&storage) = 287454020;\n"
        assert pointer_rendered == "*((unsigned int *)iter) = 287454020;\n"
class TestConditionalJumpTargetIdentity(unittest.TestCase):
    def setUp(self):
        self.stmt = Stmt.ConditionalJump(
            0,
            Expr.Const(1, 1, 1),
            Expr.Const(2, 0x2000, 64),
            Expr.Const(3, 0x2000, 64),
            true_target_idx=4,
            false_target_idx=5,
        )

    def test_jump_target_collector_preserves_branch_indices(self):
        block = Block(0x1000, 4, statements=[self.stmt], idx=3)

        self.assertEqual(JumpTargetCollector(block).jump_targets, {(0x2000, 4), (0x2000, 5)})

    def test_redundant_labels_retarget_conditional_address_and_idx(self):
        head = Block(
            0x2000,
            4,
            statements=[Stmt.Label(10, "LABEL_2000__1", ins_addr=0x2000, block_idx=1)],
            idx=1,
        )
        indexed = Block(
            0x3000,
            4,
            statements=[Stmt.Label(11, "LABEL_3000__2", ins_addr=0x3000, block_idx=2)],
            idx=2,
        )
        unindexed = Block(
            0x3000,
            4,
            statements=[Stmt.Label(12, "LABEL_3000", ins_addr=0x3000, block_idx=None)],
            idx=None,
        )
        source = Block(
            0x1000,
            4,
            statements=[
                Stmt.ConditionalJump(
                    13,
                    Expr.Const(4, 1, 1),
                    Expr.Const(5, 0x3000, 64),
                    Expr.Const(6, 0x3000, 64),
                    true_target_idx=2,
                    false_target_idx=None,
                )
            ],
            idx=0,
        )
        sequence = SequenceNode(0x2000, [head, indexed, unindexed, source])

        RedundantLabelRemover(sequence, {(0x3000, 2), (0x3000, None)})

        updated = cast(Any, source.statements[0])
        self.assertEqual((updated.true_target.value, updated.true_target_idx), (0x2000, 1))
        self.assertEqual((updated.false_target.value, updated.false_target_idx), (0x2000, 1))
        self.assertEqual(JumpTargetCollector(source).jump_targets, {(0x2000, 1)})

        c_handler = cast(Any, CStructuredCodeGenerator._handle_Stmt_ConditionalJump)
        rendered = c_handler(_ConditionalJumpCodegenHarness(), updated)
        self.assertEqual(rendered.condition_and_nodes[0][1].target_idx, 1)
        self.assertEqual(rendered.else_node.target_idx, 1)

    def test_c_codegen_preserves_branch_indices(self):
        handler = cast(Any, CStructuredCodeGenerator._handle_Stmt_ConditionalJump)
        result = handler(_ConditionalJumpCodegenHarness(), self.stmt)

        true_goto = result.condition_and_nodes[0][1]
        self.assertIsInstance(true_goto, CGoto)
        self.assertIsInstance(result.else_node, CGoto)
        self.assertEqual(true_goto.target_idx, 4)
        self.assertEqual(result.else_node.target_idx, 5)

    def test_rust_codegen_preserves_branch_indices(self):
        handler = cast(Any, RustStructuredCodeGenerator._handle_Stmt_ConditionalJump)
        result = handler(_ConditionalJumpCodegenHarness(), self.stmt)

        true_goto = result.condition_and_nodes[0][1]
        self.assertIsInstance(true_goto, RustGoto)
        self.assertIsInstance(result.else_node, RustGoto)
        self.assertEqual(true_goto.target_idx, 4)
        self.assertEqual(result.else_node.target_idx, 5)
class TestPostfixExpressionRendering(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        proj = angr.load_shellcode(b"\x31\xc0\xc3", arch="AMD64")  # xor eax, eax; ret
        cfg = proj.analyses.CFGFast(normalize=True)
        codegen = proj.analyses.Decompiler(cfg.functions[0], cfg=cfg).codegen
        assert isinstance(codegen, CStructuredCodeGenerator)
        cls.codegen = codegen
        struct_type = SimStruct({"field_0": SimTypeInt()}, name="struct_0").with_arch(proj.arch)
        assert isinstance(struct_type, SimStruct)
        cls.struct_type = struct_type
        cls.field = CStructField(cls.struct_type, 0, "field_0", codegen=cls.codegen)

    def _variable(self, name: str, ty):
        return CVariable(
            SimRegisterVariable(0, 8, name=name),
            variable_type=ty,
            codegen=self.codegen,
        )

    def test_member_access_parenthesizes_unary_base(self):
        struct_ptr = SimTypePointer(self.struct_type).with_arch(self.codegen.project.arch)
        struct_ptr_ptr = SimTypePointer(struct_ptr).with_arch(self.codegen.project.arch)
        ptr = self._variable("ptr", struct_ptr)
        ptr_ptr = self._variable("ptr_ptr", struct_ptr_ptr)

        dereferenced_ptr_ptr = CUnaryOp("Dereference", ptr_ptr, codegen=self.codegen)
        assert CVariableField(dereferenced_ptr_ptr, self.field, True, codegen=self.codegen).c_repr() == (
            "(*(ptr_ptr))->field_0"
        )

        dereferenced_ptr = CUnaryOp("Dereference", ptr, codegen=self.codegen)
        assert CVariableField(dereferenced_ptr, self.field, False, codegen=self.codegen).c_repr() == (
            "(*(ptr)).field_0"
        )

        value = self._variable("value", self.struct_type)
        referenced_value = CUnaryOp("Reference", value, codegen=self.codegen)
        assert CVariableField(referenced_value, self.field, True, codegen=self.codegen).c_repr() == (
            "(&value)->field_0"
        )

    def test_member_access_parenthesizes_cast_and_binary_bases(self):
        struct_ptr = SimTypePointer(self.struct_type).with_arch(self.codegen.project.arch)
        ptr = self._variable("ptr", struct_ptr)

        cast_ptr = CTypeCast(struct_ptr, struct_ptr, ptr, codegen=self.codegen)
        assert CVariableField(cast_ptr, self.field, True, codegen=self.codegen).c_repr() == (
            "((struct struct_0 *)ptr)->field_0"
        )

        next_ptr = CBinaryOp("Add", ptr, CConstant(1, SimTypeInt(), codegen=self.codegen), codegen=self.codegen)
        assert CVariableField(next_ptr, self.field, True, codegen=self.codegen).c_repr() == "(ptr + 1)->field_0"

    def test_member_and_index_access_keep_postfix_bases_folded(self):
        struct_ptr = SimTypePointer(self.struct_type).with_arch(self.codegen.project.arch)
        struct_ptr_ptr = SimTypePointer(struct_ptr).with_arch(self.codegen.project.arch)
        ptr_ptr = self._variable("ptr_ptr", struct_ptr_ptr)
        zero = CConstant(0, SimTypeInt(), codegen=self.codegen)

        indexed_ptr = CIndexedVariable(ptr_ptr, zero, codegen=self.codegen)
        assert CVariableField(indexed_ptr, self.field, True, codegen=self.codegen).c_repr() == "ptr_ptr[0]->field_0"

        dereferenced_ptr_ptr = CUnaryOp("Dereference", ptr_ptr, codegen=self.codegen)
        indexed_struct = CIndexedVariable(dereferenced_ptr_ptr, zero, codegen=self.codegen)
        assert indexed_struct.c_repr() == "(*(ptr_ptr))[0]"
        assert CVariableField(indexed_struct, self.field, False, codegen=self.codegen).c_repr() == (
            "(*(ptr_ptr))[0].field_0"
        )


if __name__ == "__main__":
    unittest.main()
