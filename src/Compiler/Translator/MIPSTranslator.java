package Compiler.Translator;

import Compiler.AST.Decl.Declaration;
import Compiler.AST.Decl.FunctionDecl;
import Compiler.AST.Decl.VarDecl;
import Compiler.AST.Statement.Expression.BinaryOp;
import Compiler.AST.Statement.Expression.UnaryOp;
import Compiler.ControlFlowGraph.ControlFlowGraph;
import Compiler.ControlFlowGraph.Instruction.*;
import Compiler.Environment.SymbolTable;
import Compiler.GlobalRegisterAllocator.GlobalRegisterAllocator;
import Compiler.GlobalRegisterAllocator.MIPSRegister;
import Compiler.Operand.Immediate;
import Compiler.Operand.Operand;
import Compiler.Operand.Register;
import Compiler.Operand.StringImmediate;

import java.io.PrintStream;

/**
 * Created by Alri on 16/5/5.
 */
public class MIPSTranslator {
    public PrintStream output;

    public ControlFlowGraph graph;
    public GlobalRegisterAllocator allocator;

    public MIPSTranslator(PrintStream output) {
        this.output = output;
    }

    // load a virtual register to a physical register, get ready to read
    public MIPSRegister loadToRead(MIPSRegister physicalRegister, Operand virtualRegister) {
        if (allocator.allocMapping.containsKey(virtualRegister)) {
            return allocator.allocMapping.get(virtualRegister);
        }
        if (virtualRegister instanceof StringImmediate) {
            output.printf("\tla %s, string_%d\n", physicalRegister, ((StringImmediate) virtualRegister).id);
        } else if (virtualRegister instanceof Register) {
            Register register = (Register) virtualRegister;
            if (register.type == Register.registerType.TEMPERARY || register.type == Register.registerType.PARAMETER) {
                output.printf("\tlw %s, %d(%s)\n", physicalRegister.registerName, graph.frame.getOffset((Register) virtualRegister), MIPSRegister.sp.registerName);
            } else {
                if (register.type == Register.registerType.GLOBAL) {
                    output.printf("\tlw %s, global_%d\n", physicalRegister.registerName, register.id);
                }
            }
        } else if (virtualRegister instanceof Immediate)
            output.printf("\tli %s, %d\n", physicalRegister.registerName, ((Immediate) virtualRegister).immediate);
        return physicalRegister;
    }

    // load a virtual register to a physical register, get ready to write
    public MIPSRegister loadToWrite(MIPSRegister physicalRegister, Register virtualRegister) {
        if (allocator.allocMapping.containsKey(virtualRegister)) {
            return allocator.allocMapping.get(virtualRegister);
        }
        return physicalRegister;
    }

    // move from an virtual register to a physical register
    public void move(Operand from, MIPSRegister to) {
        if (allocator.allocMapping.containsKey(from)) {
            output.printf("\tmove %s, %s\n", allocator.allocMapping.get(from).registerName, to.registerName);
        } else {
            if (from instanceof Immediate) {
                output.printf("\tli %s, %s\n", to, ((Immediate) from).immediate);
            } else if (from instanceof StringImmediate) {
                output.printf("\tla %s, string_%d\n", to, ((StringImmediate) from).id);
            } else {
                Register register = (Register) from;
                if (register.type == Register.registerType.TEMPERARY || register.type == Register.registerType.PARAMETER) {
                    output.printf("\tlw %s, %d($sp)\n", to, graph.frame.getOffset(register));
                } else {
                    if (register.type == Register.registerType.GLOBAL) {
                        output.printf("\tlw %s, global_%d", to, register.id);
                    }
                }
            }
        }
    }

    // move from a physical register to a virtual register
    public void move(MIPSRegister from, Register to) {
        if (allocator.allocMapping.containsKey(to)) {
            output.printf("\tmove %s, %s\n", from.registerName, allocator.allocMapping.get(to).registerName);
        } else {
            if (to.type == Register.registerType.TEMPERARY || to.type == Register.registerType.PARAMETER) {
                output.printf("\tsw %s, %d($sp)\n", from, graph.frame.getOffset(to));
            } else {
                output.printf("\tsw %s, global_%d\n", from, to.id);
            }
        }
    }

    public void store(Register src, MIPSRegister dest) {
        if (!allocator.allocMapping.containsKey(src)) {
            output.printf("\tsw %s, %d($sp)\n", dest, graph.frame.getOffset(src));
        }
    }

    public void translate(ControlFlowGraph cfg) {
        graph = cfg;
        allocator = graph.allocator;
        output.printf("%s:\n", cfg.function.functionName.name);
        output.printf("\tsub %s, %s, %d\n", MIPSRegister.sp.registerName, MIPSRegister.sp.registerName, graph.frame.size);
        output.printf("\tsw %s, %d(%s)\n", MIPSRegister.ra.registerName, graph.frame.getOffset(MIPSRegister.ra), MIPSRegister.sp.registerName);
        for (Instruction instruction : graph.instruction) {
            if (instruction instanceof LabelInstruction) {
                output.printf("%s%d:\n", ((LabelInstruction) instruction).label, ((LabelInstruction) instruction).labelIndex);
            }

            if (instruction instanceof ConditionBranchInstruction) {
                MIPSRegister a = loadToRead(MIPSRegister.t0, ((ConditionBranchInstruction) instruction).src);
                output.printf("\tbeqz %s, %s%d\n", a, ((ConditionBranchInstruction) instruction).tar2.label, ((ConditionBranchInstruction) instruction).tar2.labelIndex);
                output.printf("\tb %s%d\n", ((ConditionBranchInstruction) instruction).tar1.label, ((ConditionBranchInstruction) instruction).tar1.labelIndex);
            }

            if (instruction instanceof JumpInstruction) {
                output.printf("\tb %s%d\n", ((JumpInstruction) instruction).dest.label, ((JumpInstruction) instruction).dest.labelIndex);
            }

            if (instruction instanceof ReturnInstruction) {
                ReturnInstruction i = (ReturnInstruction) instruction;
                move(i.returnOperand, MIPSRegister.v0);
            }

            if (instruction instanceof CallInstruction) {
                CallInstruction i = (CallInstruction) instruction;
                if (i.function.cfg != null) {
                    for (int j = 0; j < i.actualParameters.size(); ++j) {
                        MIPSRegister a = loadToRead(MIPSRegister.t0, i.actualParameters.get(j));
                        output.printf("\tsw %s, %d($sp)\n", a, -(i.function.cfg.frame.size - i.function.cfg.frame.getOffset((Register) i.function.parameterOperand.get(j))));
                    }
                    output.printf("\tjal %s\n", i.function.functionName);
                } else {
                    if (i.actualParameters.size() == 1) {
                        move(i.actualParameters.get(0), MIPSRegister.a0);
                    }
                    if (i.actualParameters.size() == 2) {
                        move(i.actualParameters.get(0), MIPSRegister.a0);
                        move(i.actualParameters.get(1), MIPSRegister.a1);
                    }
                    if (i.actualParameters.size() == 3) {
                        move(i.actualParameters.get(0), MIPSRegister.a0);
                        move(i.actualParameters.get(1), MIPSRegister.a1);
                        move(i.actualParameters.get(2), MIPSRegister.a2);
                    }
                    if (i.actualParameters.size() == 4) {
                        move(i.actualParameters.get(0), MIPSRegister.a0);
                        move(i.actualParameters.get(1), MIPSRegister.a1);
                        move(i.actualParameters.get(2), MIPSRegister.a2);
                        move(i.actualParameters.get(3), MIPSRegister.a3);
                    }
                    output.printf("\tjal func__%s\n", i.function.functionName.name);
                }
                if (i.returnOperand != null) {
                    move(MIPSRegister.v0, (Register) i.returnOperand);
                }
            }

            if (instruction instanceof AllocInstruction) {
                AllocInstruction i = (AllocInstruction) instruction;
                move(i.allocSize, MIPSRegister.a0);
                output.printf("\tli $v0, 9\n");
                output.printf("\tsyscall\n");
                move(MIPSRegister.v0, i.address);
            }

            if (instruction instanceof MoveInstruction) {
                MoveInstruction i = (MoveInstruction) instruction;
                MIPSRegister s = loadToRead(MIPSRegister.t0, i.src);
                move(s, i.rDest);
            }

            if (instruction instanceof LoadInstruction) {
                LoadInstruction i = (LoadInstruction) instruction;
                MIPSRegister d = loadToWrite(MIPSRegister.t0, i.dest);
                MIPSRegister baseAddress = loadToRead(MIPSRegister.t1, i.src.baseAddress);
                output.printf("\t%s %s, %d(%s)\n", "lw", d, i.src.offSet.immediate, baseAddress);
                store(i.dest, d);
            }

            if (instruction instanceof StoreInstruction) {
                StoreInstruction i = (StoreInstruction) instruction;
                MIPSRegister s = loadToRead(MIPSRegister.t0, i.src);
                MIPSRegister baseAddress = loadToRead(MIPSRegister.t1, i.dest.baseAddress);
                output.printf("\t%s %s, %d(%s)\n", "sw", s, i.dest.offSet.immediate, baseAddress);
            }

            if (instruction instanceof BinaryInstruction) {
                BinaryInstruction i = (BinaryInstruction) instruction;
                MIPSRegister a = loadToRead(MIPSRegister.t0, i.lhs);
                MIPSRegister b = loadToRead(MIPSRegister.t1, i.rhs);
                MIPSRegister c = loadToWrite(MIPSRegister.t1, i.dest);
                if (i.op == BinaryOp.ADD) {
                    output.printf("\t%s %s, %s, %s\n", "add", c, a, b);
                }
                if (i.op == BinaryOp.DIV) {
                    //div Rdest, Rsrc1, Src2
                    output.printf("\t%s %s, %s, %s\n", "div", c, a, b);
                }
                if (i.op == BinaryOp.MUL) {
                    output.printf("\t%s %s, %s, %s\n", "mul", c, a, b);
                }
                if (i.op == BinaryOp.SUB) {
                    output.printf("\t%s %s, %s, %s\n", "sub", c, a, b);
                }
                if (i.op == BinaryOp.AND) {
                    output.printf("\t%s %s, %s, %s\n", "and", c, a, b);
                }
                if (i.op == BinaryOp.MOD) {
                    output.printf("\t%s %s, %s, %s\n", "rem", c, a, b);
                }
                if (i.op == BinaryOp.SHL) {
                    output.printf("\t%s %s, %s, %s\n", "sll", c, a, b);
                }
                if (i.op == BinaryOp.SHR) {
                    output.printf("\t%s %s, %s, %s\n", "sra", c, a, b);
                }
                if (i.op == BinaryOp.OR) {
                    output.printf("\t%s %s, %s, %s\n", "or", c, a, b);
                }
                if (i.op == BinaryOp.XOR) {
                    output.printf("\t%s %s, %s, %s\n", "xor", c, a, b);
                }
                if (i.op == BinaryOp.GEQ) {
                    output.printf("\t%s %s, %s, %s\n", "sge", c, a, b);
                }
                if (i.op == BinaryOp.GT) {
                    output.printf("\t%s %s, %s, %s\n", "sgt", c, a, b);
                }
                if (i.op == BinaryOp.LEQ) {
                    output.printf("\t%s %s, %s, %s\n", "sle", c, a, b);
                }
                if (i.op == BinaryOp.LT) {
                    output.printf("\t%s %s, %s, %s\n", "slt", c, a, b);
                }
                if (i.op == BinaryOp.EQ) {
                    output.printf("\t%s %s, %s, %s\n", "seq", c, a, b);
                }
                if (i.op == BinaryOp.NEQ) {
                    output.printf("\t%s %s, %s, %s\n", "sne", c, a, b);
                }
                store(i.dest, c);
            }

            if (instruction instanceof UnaryInstruction) {
                UnaryInstruction i = (UnaryInstruction) instruction;
                MIPSRegister d = loadToWrite(MIPSRegister.t1, i.dest);
                MIPSRegister s = loadToRead(MIPSRegister.t0, i.src);
                if (i.op == UnaryOp.MINUS) {
                    output.printf("\t%s %s, %s", "neg", d, s);
                }
                if (i.op == UnaryOp.NOT) {
                    output.printf("\t%s %s, %s", "not", d, s);
                }
                store(i.dest, d);
            }
        }
        output.printf("\tlw %s, %d(%s)\n", MIPSRegister.ra.registerName, graph.frame.getOffset(MIPSRegister.ra), MIPSRegister.sp.registerName);
        output.printf("\tadd %s, %s, %d\n", MIPSRegister.sp.registerName, MIPSRegister.sp.registerName, graph.frame.size);
        output.printf("\tjr $ra\n");
    }

    public void translate() {
        output.printf("\t.text\n");
        output.printf("# _buffer_init:\n" +
                "# \tli $a0, 256\n" +
                "# \tli $v0, 9\n" +
                "# \tsyscall\n" +
                "# \tsw $v0, _buffer\n" +
                "# \tjr $ra\n" +
                "\n" +
                "# copy the string in $a0 to buffer in $a1, with putting '\\0' in the end of the buffer\n" +
                "###### Checked ######\n" +
                "# used $v0, $a0, $a1\n" +
                "_string_copy:\n" +
                "\t_begin_string_copy:\n" +
                "\tlb $v0, 0($a0)\n" +
                "\tbeqz $v0, _exit_string_copy\n" +
                "\tsb $v0, 0($a1)\n" +
                "\tadd $a0, $a0, 1\n" +
                "\tadd $a1, $a1, 1\n" +
                "\tj _begin_string_copy\n" +
                "\t_exit_string_copy:\n" +
                "\tsb $zero, 0($a1)\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string arg in $a0\n" +
                "###### Checked ######\n" +
                "# Change(5/4): you don't need to preserve reg before calling it\n" +
                "func__print:\n" +
                "\tli $v0, 4\n" +
                "\tsyscall\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string arg in $a0\n" +
                "###### Checked ######\n" +
                "# Change(5/4): you don't need to preserve reg before calling it\n" +
                "func__println:\n" +
                "\tli $v0, 4\n" +
                "\tsyscall\n" +
                "\tla $a0, _end\n" +
                "\tsyscall\n" +
                "\tjr $ra\n" +
                "\n" +
                "# count the length of given string in $a0\n" +
                "###### Checked ######\n" +
                "# used $v0, $v1, $a0\n" +
                "_count_string_length:\n" +
                "\tmove $v0, $a0\n" +
                "\n" +
                "\t_begin_count_string_length:\n" +
                "\tlb $v1, 0($a0)\n" +
                "\tbeqz $v1, _exit_count_string_length\n" +
                "\tadd $a0, $a0, 1\n" +
                "\tj _begin_count_string_length\n" +
                "\n" +
                "\t_exit_count_string_length:\n" +
                "\tsub $v0, $a0, $v0\n" +
                "\tjr $ra\n" +
                "\n" +
                "# non arg, string in $v0\n" +
                "###### Checked ######\n" +
                "# used $a0, $a1, $t0, $v0, (used in _count_string_length) $v1\n" +
                "func__getString:\n" +
                "\tsubu $sp, $sp, 4\n" +
                "\tsw $ra, 0($sp)\n" +
                "\n" +
                "\tla $a0, _buffer\n" +
                "\tli $a1, 255\n" +
                "\tli $v0, 8\n" +
                "\tsyscall\n" +
                "\n" +
                "\tjal _count_string_length\n" +
                "\n" +
                "\tmove $a1, $v0\t\t\t# now $a1 contains the length of the string\n" +
                "\tadd $a0, $v0, 5\t\t\t# total required space = length + 1('\\0') + 1 word(record the length of the string)\n" +
                "\tli $v0, 9\n" +
                "\tsyscall\n" +
                "\tsw $a1, 0($v0)\n" +
                "\tadd $v0, $v0, 4\n" +
                "\tla $a0, _buffer\n" +
                "\tmove $a1, $v0\n" +
                "\tmove $t0, $v0\n" +
                "\tjal _string_copy\n" +
                "\tmove $v0, $t0\n" +
                "\n" +
                "\tlw $ra, 0($sp)\n" +
                "\taddu $sp, $sp, 4\n" +
                "\tjr $ra\n" +
                "\n" +
                "# non arg, int in $v0\n" +
                "###### Checked ######\n" +
                "# Change(5/4): you don't need to preserve reg before calling it\n" +
                "func__getInt:\n" +
                "\tli $v0, 5\n" +
                "\tsyscall\n" +
                "\tjr $ra\n" +
                "\n" +
                "# int arg in $a0\n" +
                "###### Checked ######\n" +
                "# Bug fixed(5/2): when the arg is a neg number\n" +
                "# Change(5/4): use less regs, you don't need to preserve reg before calling it\n" +
                "# used $v0, $v1\n" +
                "func__toString:\n" +
                "\tsubu $sp, $sp, 24\n" +
                "\tsw $a0, 0($sp)\n" +
                "\tsw $t0, 4($sp)\n" +
                "\tsw $t1, 8($sp)\n" +
                "\tsw $t2, 12($sp)\n" +
                "\tsw $t3, 16($sp)\n" +
                "\tsw $t5, 20($sp)\n" +
                "\n" +
                "\t# first count the #digits\n" +
                "\tli $t0, 0\t\t\t# $t0 = 0 if the number is a negnum\n" +
                "\tbgez $a0, _skip_set_less_than_zero\n" +
                "\tli $t0, 1\t\t\t# now $t0 must be 1\n" +
                "\tneg $a0, $a0\n" +
                "\t_skip_set_less_than_zero:\n" +
                "\tbeqz $a0, _set_zero\n" +
                "\n" +
                "\tli $t1, 0\t\t\t# the #digits is in $t1\n" +
                "\tmove $t2, $a0\n" +
                "\tmove $t3, $a0\n" +
                "\tli $t5, 10\n" +
                "\n" +
                "\t_begin_count_digit:\n" +
                "\tdiv $t2, $t5\n" +
                "\tmflo $v0\t\t\t# get the quotient\n" +
                "\tmfhi $v1\t\t\t# get the remainder\n" +
                "\tbgtz $v0 _not_yet\n" +
                "\tbgtz $v1 _not_yet\n" +
                "\tj _yet\n" +
                "\t_not_yet:\n" +
                "\tadd $t1, $t1, 1\n" +
                "\tmove $t2, $v0\n" +
                "\tj _begin_count_digit\n" +
                "\n" +
                "\t_yet:\n" +
                "\tbeqz $t0, _skip_reserve_neg\n" +
                "\tadd $t1, $t1, 1\n" +
                "\t_skip_reserve_neg:\n" +
                "\tadd $a0, $t1, 5\n" +
                "\tli $v0, 9\n" +
                "\tsyscall\n" +
                "\tsw $t1, 0($v0)\n" +
                "\tadd $v0, $v0, 4\n" +
                "\tadd $t1, $t1, $v0\n" +
                "\tsb $zero, 0($t1)\n" +
                "\tsub $t1, $t1, 1\n" +
                "\n" +
                "\t_continue_toString:\n" +
                "\tdiv $t3, $t5\n" +
                "\tmfhi $v1\n" +
                "\tadd $v1, $v1, 48\t# in ascii 48 = '0'\n" +
                "\tsb $v1, 0($t1)\n" +
                "\tsub $t1, $t1, 1\n" +
                "\tmflo $t3\n" +
                "\t# bge $t1, $v0, _continue_toString\n" +
                "\tbnez $t3, _continue_toString\n" +
                "\n" +
                "\tbeqz $t0, _skip_place_neg\n" +
                "\tli $v1, 45\n" +
                "\tsb $v1, 0($t1)\n" +
                "\t_skip_place_neg:\n" +
                "\t# lw $ra, 0($sp)\n" +
                "\t# addu $sp, $sp, 4\n" +
                "\n" +
                "\tlw $a0, 0($sp)\n" +
                "\tlw $t0, 4($sp)\n" +
                "\tlw $t1, 8($sp)\n" +
                "\tlw $t2, 12($sp)\n" +
                "\tlw $t3, 16($sp)\n" +
                "\tlw $t5, 20($sp)\n" +
                "\n" +
                "\taddu $sp, $sp, 24\n" +
                "\tjr $ra\n" +
                "\n" +
                "\t_set_zero:\n" +
                "\tli $a0, 6\n" +
                "\tli $v0, 9\n" +
                "\tsyscall\n" +
                "\tli $a0, 1\n" +
                "\tsw $a0, 0($v0)\n" +
                "\tadd $v0, $v0, 4\n" +
                "\tli $a0, 48\n" +
                "\tsb $a0, 0($v0)\n" +
                "\n" +
                "\tlw $a0, 0($sp)\n" +
                "\tlw $t0, 4($sp)\n" +
                "\tlw $t1, 8($sp)\n" +
                "\tlw $t2, 12($sp)\n" +
                "\tlw $t3, 16($sp)\n" +
                "\tlw $t5, 20($sp)\n" +
                "\n" +
                "\taddu $sp, $sp, 24\n" +
                "\tjr $ra\n" +
                "\n" +
                "\n" +
                "# string arg in $a0\n" +
                "# the zero in the end of the string will not be counted\n" +
                "###### Checked ######\n" +
                "# you don't need to preserve reg before calling it\n" +
                "func__string.length:\n" +
                "\tlw $v0, -4($a0)\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string arg in $a0, left in $a1, right in $a2\n" +
                "###### Checked ######\n" +
                "# used $a0, $a1, $t0, $t1, $t2, $v1, $v0\n" +
                "func__string.substring:\n" +
                "\tsubu $sp, $sp, 4\n" +
                "\tsw $ra, 0($sp)\n" +
                "\n" +
                "\tmove $t0, $a0\n" +
                "\n" +
                "\tsub $t1, $a2, $a1\n" +
                "\tadd $t1, $t1, 1\t\t# $t1 is the length of the substring\n" +
                "\tadd $a0, $t1, 5\n" +
                "\tli $v0, 9\n" +
                "\tsyscall\n" +
                "\tsw $t1, 0($v0)\n" +
                "\tadd $v1, $v0, 4\n" +
                "\n" +
                "\tadd $a0, $t0, $a1\n" +
                "\tadd $t2, $t0, $a2\n" +
                "\tlb $t1, 1($t2)\t\t# store the ori_begin + right + 1 char in $t1\n" +
                "\tsb $zero, 1($t2)\t# change it to 0 for the convenience of copying\n" +
                "\tmove $a1, $v1\n" +
                "\tjal _string_copy\n" +
                "\tmove $v0, $v1\n" +
                "\tsb $t1, 1($t2)\n" +
                "\n" +
                "\tlw $ra, 0($sp)\n" +
                "\taddu $sp, $sp, 4\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string arg in\n" +
                "###### Checked ######\n" +
                "# 16/5/4 Fixed a serious bug: can not parse negtive number\n" +
                "# used $v0, $v1\n" +
                "func__string.parseInt:\n" +
                "\tsubu $sp, $sp, 16\n" +
                "\tsw $a0, 0($sp)\n" +
                "\tsw $t0, 4($sp)\n" +
                "\tsw $t1, 8($sp)\n" +
                "\tsw $t2, 12($sp)\n" +
                "\n" +
                "\tli $v0, 0\n" +
                "\n" +
                "\tlb $t1, 0($a0)\n" +
                "\tli $t2, 45\n" +
                "\tbne $t1, $t2, _skip_parse_neg\n" +
                "\tli $t1, 1\t\t\t#if there is a '-' sign, $t1 = 1\n" +
                "\tadd $a0, $a0, 1\n" +
                "\tj _skip_set_t1_zero\n" +
                "\n" +
                "\t_skip_parse_neg:\n" +
                "\tli $t1, 0\n" +
                "\t_skip_set_t1_zero:\n" +
                "\tmove $t0, $a0\n" +
                "\tli $t2, 1\n" +
                "\n" +
                "\t_count_number_pos:\n" +
                "\tlb $v1, 0($t0)\n" +
                "\tbgt $v1, 57, _begin_parse_int\n" +
                "\tblt $v1, 48, _begin_parse_int\n" +
                "\tadd $t0, $t0, 1\n" +
                "\tj _count_number_pos\n" +
                "\n" +
                "\t_begin_parse_int:\n" +
                "\tsub $t0, $t0, 1\n" +
                "\n" +
                "\t_parsing_int:\n" +
                "\tblt $t0, $a0, _finish_parse_int\n" +
                "\tlb $v1, 0($t0)\n" +
                "\tsub $v1, $v1, 48\n" +
                "\tmul $v1, $v1, $t2\n" +
                "\tadd $v0, $v0, $v1\n" +
                "\tmul $t2, $t2, 10\n" +
                "\tsub $t0, $t0, 1\n" +
                "\tj _parsing_int\n" +
                "\n" +
                "\t_finish_parse_int:\n" +
                "\tbeqz $t1, _skip_neg\n" +
                "\tneg $v0, $v0\n" +
                "\t_skip_neg:\n" +
                "\n" +
                "\tlw $a0, 0($sp)\n" +
                "\tlw $t0, 4($sp)\n" +
                "\tlw $t1, 8($sp)\n" +
                "\tlw $t2, 12($sp)\n" +
                "\taddu $sp, $sp, 16\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string arg in $a0, pos in $a1\n" +
                "###### Checked ######\n" +
                "# used $v0, $v1\n" +
                "func__string.ord:\n" +
                "\tadd $v1, $a0, $a1\n" +
                "\tlb $v0, 0($v1)\n" +
                "\tjr $ra\n" +
                "\n" +
                "# array arg in $a0\n" +
                "# used $v0\n" +
                "func__array.size:\n" +
                "\tlw $v0, -4($a0)\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string1 in $a0, string2 in $a1\n" +
                "###### Checked ######\n" +
                "# change(16/5/4): use less regs, you don't need to preserve reg before calling it\n" +
                "# used $v0, $v1\n" +
                "func__stringConcatenate:\n" +
                "\n" +
                "\tsubu $sp, $sp, 24\n" +
                "\tsw $ra, 0($sp)\n" +
                "\tsw $a0, 4($sp)\n" +
                "\tsw $a1, 8($sp)\n" +
                "\tsw $t0, 12($sp)\n" +
                "\tsw $t1, 16($sp)\n" +
                "\tsw $t2, 20($sp)\n" +
                "\n" +
                "\tlw $t0, -4($a0)\t\t# $t0 is the length of lhs\n" +
                "\tlw $t1, -4($a1)\t\t# $t1 is the length of rhs\n" +
                "\tadd $t2, $t0, $t1\n" +
                "\n" +
                "\tmove $t1, $a0\n" +
                "\n" +
                "\tadd $a0, $t2, 5\n" +
                "\tli $v0, 9\n" +
                "\tsyscall\n" +
                "\n" +
                "\tsw $t2, 0($v0)\n" +
                "\tmove $t2, $a1\n" +
                "\n" +
                "\tadd $v0, $v0, 4\n" +
                "\tmove $v1, $v0\n" +
                "\n" +
                "\tmove $a0, $t1\n" +
                "\tmove $a1, $v1\n" +
                "\tjal _string_copy\n" +
                "\n" +
                "\tmove $a0, $t2\n" +
                "\tadd $a1, $v1, $t0\n" +
                "\t# add $a1, $a1, 1\n" +
                "\tjal _string_copy\n" +
                "\n" +
                "\tmove $v0, $v1\n" +
                "\tlw $ra, 0($sp)\n" +
                "\tlw $a0, 4($sp)\n" +
                "\tlw $a1, 8($sp)\n" +
                "\tlw $t0, 12($sp)\n" +
                "\tlw $t1, 16($sp)\n" +
                "\tlw $t2, 20($sp)\n" +
                "\taddu $sp, $sp, 24\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string1 in $a0, string2 in $a1\n" +
                "###### Checked ######\n" +
                "# change(16/5/4): use less regs, you don't need to preserve reg before calling it\n" +
                "# used $a0, $a1, $v0, $v1\n" +
                "func__stringIsEqual:\n" +
                "\t# subu $sp, $sp, 8\n" +
                "\t# sw $a0, 0($sp)\n" +
                "\t# sw $a1, 4($sp)\n" +
                "\n" +
                "\tlw $v0, -4($a0)\n" +
                "\tlw $v1, -4($a1)\n" +
                "\tbne $v0, $v1, _not_equal\n" +
                "\n" +
                "\t_continue_compare_equal:\n" +
                "\tlb $v0, 0($a0)\n" +
                "\tlb $v1, 0($a1)\n" +
                "\tbeqz $v0, _equal\n" +
                "\tbne $v0, $v1, _not_equal\n" +
                "\tadd $a0, $a0, 1\n" +
                "\tadd $a1, $a1, 1\n" +
                "\tj _continue_compare_equal\n" +
                "\n" +
                "\t_not_equal:\n" +
                "\tli $v0, 0\n" +
                "\tj _compare_final\n" +
                "\n" +
                "\t_equal:\n" +
                "\tli $v0, 1\n" +
                "\n" +
                "\t_compare_final:\n" +
                "\t# lw $a0, 0($sp)\n" +
                "\t# lw $a1, 4($sp)\n" +
                "\t# addu $sp, $sp, 8\n" +
                "\tjr $ra\n" +
                "\n" +
                "\n" +
                "# string1 in $a0, string2 in $a1\n" +
                "###### Checked ######\n" +
                "# change(16/5/4): use less regs, you don't need to preserve reg before calling it\n" +
                "# used $a0, $a1, $v0, $v1\n" +
                "func__stringLess:\n" +
                "\t# subu $sp, $sp, 8\n" +
                "\t# sw $a0, 0($sp)\n" +
                "\t# sw $a1, 4($sp)\n" +
                "\n" +
                "\t_begin_compare_less:\n" +
                "\tlb $v0, 0($a0)\n" +
                "\tlb $v1, 0($a1)\n" +
                "\tblt $v0, $v1, _less_correct\n" +
                "\tbgt $v0, $v1, _less_false\n" +
                "\tbeqz $v0, _less_false\n" +
                "\tadd $a0, $a0, 1\n" +
                "\tadd $a1, $a1, 1\n" +
                "\tj _begin_compare_less\n" +
                "\n" +
                "\t_less_correct:\n" +
                "\tli $v0, 1\n" +
                "\tj _less_compare_final\n" +
                "\n" +
                "\t_less_false:\n" +
                "\tli $v0, 0\n" +
                "\n" +
                "\t_less_compare_final:\n" +
                "\n" +
                "\t# lw $a0, 0($sp)\n" +
                "\t# lw $a1, 4($sp)\n" +
                "\t# addu $sp, $sp, 8\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string1 in $a0, string2 in $a1\n" +
                "# used $a0, $a1, $v0, $v1\n" +
                "func__stringLarge:\n" +
                "\tsubu $sp, $sp, 4\n" +
                "\tsw $ra, 0($sp)\n" +
                "\n" +
                "\tjal func__stringLess\n" +
                "\n" +
                "\txor $v0, $v0, 1\n" +
                "\n" +
                "\tlw $ra, 0($sp)\n" +
                "\taddu $sp, $sp, 4\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string1 in $a0, string2 in $a1\n" +
                "# used $a0, $a1, $v0, $v1\n" +
                "func__stringLeq:\n" +
                "\tsubu $sp, $sp, 12\n" +
                "\tsw $ra, 0($sp)\n" +
                "\tsw $a0, 4($sp)\n" +
                "\tsw $a1, 8($sp)\n" +
                "\n" +
                "\tjal func__stringLess\n" +
                "\n" +
                "\tbnez $v0, _skip_compare_equal_in_Leq\n" +
                "\n" +
                "\tlw $a0, 4($sp)\n" +
                "\tlw $a1, 8($sp)\n" +
                "\tjal func__stringIsEqual\n" +
                "\n" +
                "\t_skip_compare_equal_in_Leq:\n" +
                "\tlw $ra, 0($sp)\n" +
                "\taddu $sp, $sp, 12\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string1 in $a0, string2 in $a1\n" +
                "# used $a0, $a1, $v0, $v1\n" +
                "func__stringGeq:\n" +
                "\tsubu $sp, $sp, 12\n" +
                "\tsw $ra, 0($sp)\n" +
                "\tsw $a0, 4($sp)\n" +
                "\tsw $a1, 8($sp)\n" +
                "\n" +
                "\tjal func__stringLess\n" +
                "\n" +
                "\tbeqz $v0, _skip_compare_equal_in_Geq\n" +
                "\n" +
                "\tlw $a0, 4($sp)\n" +
                "\tlw $a1, 8($sp)\n" +
                "\tjal func__stringIsEqual\n" +
                "\txor $v0, $v0, 1\n" +
                "\n" +
                "\t_skip_compare_equal_in_Geq:\n" +
                "\txor $v0, $v0, 1\n" +
                "\tlw $ra, 0($sp)\n" +
                "\taddu $sp, $sp, 12\n" +
                "\tjr $ra\n" +
                "\n" +
                "# string1 in $a0, string2 in $a1\n" +
                "# used $a0, $a1, $v0, $v1\n" +
                "func__stringNeq:\n" +
                "\tsubu $sp, $sp, 4\n" +
                "\tsw $ra, 0($sp)\n" +
                "\n" +
                "\tjal func__stringIsEqual\n" +
                "\n" +
                "\txor $v0, $v0, 1\n" +
                "\n" +
                "\tlw $ra, 0($sp)\n" +
                "\taddu $sp, $sp, 4\n" +
                "\tjr $ra\n");

        for (Declaration declaration : SymbolTable.program.declarations) {
            if (declaration instanceof FunctionDecl) {
                ((FunctionDecl) declaration).cfg.buildBasicBlock();
                translate(((FunctionDecl) declaration).cfg);
            }
        }
        output.printf(".data\n" +
                "_end: .asciiz \"\\n\"\n" +
                "\t.align 2\n" +
                "_buffer: .space 256\n" +
                "\t.align 2\n");
        for (Declaration declaration : SymbolTable.program.declarations) {
            if (declaration instanceof VarDecl) {
                output.printf("global_%d:\n", ((VarDecl) declaration).entry.register.id);
                output.printf(".space 4\n.align 2\n");
            }
        }
        for (StringImmediate stringImmediate : SymbolTable.stringImmediateArrayList) {
            output.printf(".word %d\n", stringImmediate.literal.length());
            output.printf("string_%s:\n", stringImmediate.id);
            output.printf(".asciiz %s\n.align 2\n", stringImmediate.literal);
        }
    }
}
