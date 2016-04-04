// Generated from /Users/Alri/IdeaProjects/Compiler2016/src/Compiler/AST/Parser/Mag.g4 by ANTLR 4.5.1
package Compiler.AST.Parser;

import org.antlr.v4.runtime.tree.ParseTreeListener;

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link MagParser}.
 */
public interface MagListener extends ParseTreeListener {
    /**
     * Enter a parse tree produced by {@link MagParser#program}.
     *
     * @param ctx the parse tree
     */
    void enterProgram(MagParser.ProgramContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#program}.
     *
     * @param ctx the parse tree
     */
    void exitProgram(MagParser.ProgramContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#classDeclaration}.
     *
     * @param ctx the parse tree
     */
    void enterClassDeclaration(MagParser.ClassDeclarationContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#classDeclaration}.
     *
     * @param ctx the parse tree
     */
    void exitClassDeclaration(MagParser.ClassDeclarationContext ctx);

    /**
     * Enter a parse tree produced by the {@code classMemDeclList_}
     * labeled alternative in {@link MagParser#classMemberDeclarationList}.
     *
     * @param ctx the parse tree
     */
    void enterClassMemDeclList_(MagParser.ClassMemDeclList_Context ctx);

    /**
     * Exit a parse tree produced by the {@code classMemDeclList_}
     * labeled alternative in {@link MagParser#classMemberDeclarationList}.
     *
     * @param ctx the parse tree
     */
    void exitClassMemDeclList_(MagParser.ClassMemDeclList_Context ctx);

    /**
     * Enter a parse tree produced by the {@code classMemDeclList_list}
     * labeled alternative in {@link MagParser#classMemberDeclarationList}.
     *
     * @param ctx the parse tree
     */
    void enterClassMemDeclList_list(MagParser.ClassMemDeclList_listContext ctx);

    /**
     * Exit a parse tree produced by the {@code classMemDeclList_list}
     * labeled alternative in {@link MagParser#classMemberDeclarationList}.
     *
     * @param ctx the parse tree
     */
    void exitClassMemDeclList_list(MagParser.ClassMemDeclList_listContext ctx);

    /**
     * Enter a parse tree produced by the {@code typeArray_type}
     * labeled alternative in {@link MagParser#typeArray}.
     *
     * @param ctx the parse tree
     */
    void enterTypeArray_type(MagParser.TypeArray_typeContext ctx);

    /**
     * Exit a parse tree produced by the {@code typeArray_type}
     * labeled alternative in {@link MagParser#typeArray}.
     *
     * @param ctx the parse tree
     */
    void exitTypeArray_type(MagParser.TypeArray_typeContext ctx);

    /**
     * Enter a parse tree produced by the {@code typeArray_dim}
     * labeled alternative in {@link MagParser#typeArray}.
     *
     * @param ctx the parse tree
     */
    void enterTypeArray_dim(MagParser.TypeArray_dimContext ctx);

    /**
     * Exit a parse tree produced by the {@code typeArray_dim}
     * labeled alternative in {@link MagParser#typeArray}.
     *
     * @param ctx the parse tree
     */
    void exitTypeArray_dim(MagParser.TypeArray_dimContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#type}.
     *
     * @param ctx the parse tree
     */
    void enterType(MagParser.TypeContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#type}.
     *
     * @param ctx the parse tree
     */
    void exitType(MagParser.TypeContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#statement}.
     *
     * @param ctx the parse tree
     */
    void enterStatement(MagParser.StatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#statement}.
     *
     * @param ctx the parse tree
     */
    void exitStatement(MagParser.StatementContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#blockStatement}.
     *
     * @param ctx the parse tree
     */
    void enterBlockStatement(MagParser.BlockStatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#blockStatement}.
     *
     * @param ctx the parse tree
     */
    void exitBlockStatement(MagParser.BlockStatementContext ctx);

    /**
     * Enter a parse tree produced by the {@code statementList_stmt}
     * labeled alternative in {@link MagParser#statementList}.
     *
     * @param ctx the parse tree
     */
    void enterStatementList_stmt(MagParser.StatementList_stmtContext ctx);

    /**
     * Exit a parse tree produced by the {@code statementList_stmt}
     * labeled alternative in {@link MagParser#statementList}.
     *
     * @param ctx the parse tree
     */
    void exitStatementList_stmt(MagParser.StatementList_stmtContext ctx);

    /**
     * Enter a parse tree produced by the {@code statementList_list}
     * labeled alternative in {@link MagParser#statementList}.
     *
     * @param ctx the parse tree
     */
    void enterStatementList_list(MagParser.StatementList_listContext ctx);

    /**
     * Exit a parse tree produced by the {@code statementList_list}
     * labeled alternative in {@link MagParser#statementList}.
     *
     * @param ctx the parse tree
     */
    void exitStatementList_list(MagParser.StatementList_listContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#expressionStatement}.
     *
     * @param ctx the parse tree
     */
    void enterExpressionStatement(MagParser.ExpressionStatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#expressionStatement}.
     *
     * @param ctx the parse tree
     */
    void exitExpressionStatement(MagParser.ExpressionStatementContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#expression}.
     *
     * @param ctx the parse tree
     */
    void enterExpression(MagParser.ExpressionContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#expression}.
     *
     * @param ctx the parse tree
     */
    void exitExpression(MagParser.ExpressionContext ctx);

    /**
     * Enter a parse tree produced by the {@code assignment_logicalOr}
     * labeled alternative in {@link MagParser#assignmentExpression}.
     *
     * @param ctx the parse tree
     */
    void enterAssignment_logicalOr(MagParser.Assignment_logicalOrContext ctx);

    /**
     * Exit a parse tree produced by the {@code assignment_logicalOr}
     * labeled alternative in {@link MagParser#assignmentExpression}.
     *
     * @param ctx the parse tree
     */
    void exitAssignment_logicalOr(MagParser.Assignment_logicalOrContext ctx);

    /**
     * Enter a parse tree produced by the {@code assignment_assign}
     * labeled alternative in {@link MagParser#assignmentExpression}.
     *
     * @param ctx the parse tree
     */
    void enterAssignment_assign(MagParser.Assignment_assignContext ctx);

    /**
     * Exit a parse tree produced by the {@code assignment_assign}
     * labeled alternative in {@link MagParser#assignmentExpression}.
     *
     * @param ctx the parse tree
     */
    void exitAssignment_assign(MagParser.Assignment_assignContext ctx);

    /**
     * Enter a parse tree produced by the {@code logicalOr_or}
     * labeled alternative in {@link MagParser#logicalOrExpression}.
     *
     * @param ctx the parse tree
     */
    void enterLogicalOr_or(MagParser.LogicalOr_orContext ctx);

    /**
     * Exit a parse tree produced by the {@code logicalOr_or}
     * labeled alternative in {@link MagParser#logicalOrExpression}.
     *
     * @param ctx the parse tree
     */
    void exitLogicalOr_or(MagParser.LogicalOr_orContext ctx);

    /**
     * Enter a parse tree produced by the {@code logicalOr_logicalAnd}
     * labeled alternative in {@link MagParser#logicalOrExpression}.
     *
     * @param ctx the parse tree
     */
    void enterLogicalOr_logicalAnd(MagParser.LogicalOr_logicalAndContext ctx);

    /**
     * Exit a parse tree produced by the {@code logicalOr_logicalAnd}
     * labeled alternative in {@link MagParser#logicalOrExpression}.
     *
     * @param ctx the parse tree
     */
    void exitLogicalOr_logicalAnd(MagParser.LogicalOr_logicalAndContext ctx);

    /**
     * Enter a parse tree produced by the {@code logicalAnd_bitwiseOr}
     * labeled alternative in {@link MagParser#logicalAndExpression}.
     *
     * @param ctx the parse tree
     */
    void enterLogicalAnd_bitwiseOr(MagParser.LogicalAnd_bitwiseOrContext ctx);

    /**
     * Exit a parse tree produced by the {@code logicalAnd_bitwiseOr}
     * labeled alternative in {@link MagParser#logicalAndExpression}.
     *
     * @param ctx the parse tree
     */
    void exitLogicalAnd_bitwiseOr(MagParser.LogicalAnd_bitwiseOrContext ctx);

    /**
     * Enter a parse tree produced by the {@code logicalAnd_and}
     * labeled alternative in {@link MagParser#logicalAndExpression}.
     *
     * @param ctx the parse tree
     */
    void enterLogicalAnd_and(MagParser.LogicalAnd_andContext ctx);

    /**
     * Exit a parse tree produced by the {@code logicalAnd_and}
     * labeled alternative in {@link MagParser#logicalAndExpression}.
     *
     * @param ctx the parse tree
     */
    void exitLogicalAnd_and(MagParser.LogicalAnd_andContext ctx);

    /**
     * Enter a parse tree produced by the {@code bitwiseOr_bitwiseXor}
     * labeled alternative in {@link MagParser#bitwiseOrExpression}.
     *
     * @param ctx the parse tree
     */
    void enterBitwiseOr_bitwiseXor(MagParser.BitwiseOr_bitwiseXorContext ctx);

    /**
     * Exit a parse tree produced by the {@code bitwiseOr_bitwiseXor}
     * labeled alternative in {@link MagParser#bitwiseOrExpression}.
     *
     * @param ctx the parse tree
     */
    void exitBitwiseOr_bitwiseXor(MagParser.BitwiseOr_bitwiseXorContext ctx);

    /**
     * Enter a parse tree produced by the {@code bitwiseOr_or}
     * labeled alternative in {@link MagParser#bitwiseOrExpression}.
     *
     * @param ctx the parse tree
     */
    void enterBitwiseOr_or(MagParser.BitwiseOr_orContext ctx);

    /**
     * Exit a parse tree produced by the {@code bitwiseOr_or}
     * labeled alternative in {@link MagParser#bitwiseOrExpression}.
     *
     * @param ctx the parse tree
     */
    void exitBitwiseOr_or(MagParser.BitwiseOr_orContext ctx);

    /**
     * Enter a parse tree produced by the {@code bitwiseXor_bitwiseAnd}
     * labeled alternative in {@link MagParser#bitwiseXorExpression}.
     *
     * @param ctx the parse tree
     */
    void enterBitwiseXor_bitwiseAnd(MagParser.BitwiseXor_bitwiseAndContext ctx);

    /**
     * Exit a parse tree produced by the {@code bitwiseXor_bitwiseAnd}
     * labeled alternative in {@link MagParser#bitwiseXorExpression}.
     *
     * @param ctx the parse tree
     */
    void exitBitwiseXor_bitwiseAnd(MagParser.BitwiseXor_bitwiseAndContext ctx);

    /**
     * Enter a parse tree produced by the {@code bitwiseXor_xor}
     * labeled alternative in {@link MagParser#bitwiseXorExpression}.
     *
     * @param ctx the parse tree
     */
    void enterBitwiseXor_xor(MagParser.BitwiseXor_xorContext ctx);

    /**
     * Exit a parse tree produced by the {@code bitwiseXor_xor}
     * labeled alternative in {@link MagParser#bitwiseXorExpression}.
     *
     * @param ctx the parse tree
     */
    void exitBitwiseXor_xor(MagParser.BitwiseXor_xorContext ctx);

    /**
     * Enter a parse tree produced by the {@code bitwiseAnd_and}
     * labeled alternative in {@link MagParser#bitwiseAndExpression}.
     *
     * @param ctx the parse tree
     */
    void enterBitwiseAnd_and(MagParser.BitwiseAnd_andContext ctx);

    /**
     * Exit a parse tree produced by the {@code bitwiseAnd_and}
     * labeled alternative in {@link MagParser#bitwiseAndExpression}.
     *
     * @param ctx the parse tree
     */
    void exitBitwiseAnd_and(MagParser.BitwiseAnd_andContext ctx);

    /**
     * Enter a parse tree produced by the {@code bitwiseAnd_equal}
     * labeled alternative in {@link MagParser#bitwiseAndExpression}.
     *
     * @param ctx the parse tree
     */
    void enterBitwiseAnd_equal(MagParser.BitwiseAnd_equalContext ctx);

    /**
     * Exit a parse tree produced by the {@code bitwiseAnd_equal}
     * labeled alternative in {@link MagParser#bitwiseAndExpression}.
     *
     * @param ctx the parse tree
     */
    void exitBitwiseAnd_equal(MagParser.BitwiseAnd_equalContext ctx);

    /**
     * Enter a parse tree produced by the {@code equality_relational}
     * labeled alternative in {@link MagParser#equalityExpression}.
     *
     * @param ctx the parse tree
     */
    void enterEquality_relational(MagParser.Equality_relationalContext ctx);

    /**
     * Exit a parse tree produced by the {@code equality_relational}
     * labeled alternative in {@link MagParser#equalityExpression}.
     *
     * @param ctx the parse tree
     */
    void exitEquality_relational(MagParser.Equality_relationalContext ctx);

    /**
     * Enter a parse tree produced by the {@code equality_notEqual}
     * labeled alternative in {@link MagParser#equalityExpression}.
     *
     * @param ctx the parse tree
     */
    void enterEquality_notEqual(MagParser.Equality_notEqualContext ctx);

    /**
     * Exit a parse tree produced by the {@code equality_notEqual}
     * labeled alternative in {@link MagParser#equalityExpression}.
     *
     * @param ctx the parse tree
     */
    void exitEquality_notEqual(MagParser.Equality_notEqualContext ctx);

    /**
     * Enter a parse tree produced by the {@code equality_equal}
     * labeled alternative in {@link MagParser#equalityExpression}.
     *
     * @param ctx the parse tree
     */
    void enterEquality_equal(MagParser.Equality_equalContext ctx);

    /**
     * Exit a parse tree produced by the {@code equality_equal}
     * labeled alternative in {@link MagParser#equalityExpression}.
     *
     * @param ctx the parse tree
     */
    void exitEquality_equal(MagParser.Equality_equalContext ctx);

    /**
     * Enter a parse tree produced by the {@code relational_shift}
     * labeled alternative in {@link MagParser#relationalExpression}.
     *
     * @param ctx the parse tree
     */
    void enterRelational_shift(MagParser.Relational_shiftContext ctx);

    /**
     * Exit a parse tree produced by the {@code relational_shift}
     * labeled alternative in {@link MagParser#relationalExpression}.
     *
     * @param ctx the parse tree
     */
    void exitRelational_shift(MagParser.Relational_shiftContext ctx);

    /**
     * Enter a parse tree produced by the {@code relational_geq}
     * labeled alternative in {@link MagParser#relationalExpression}.
     *
     * @param ctx the parse tree
     */
    void enterRelational_geq(MagParser.Relational_geqContext ctx);

    /**
     * Exit a parse tree produced by the {@code relational_geq}
     * labeled alternative in {@link MagParser#relationalExpression}.
     *
     * @param ctx the parse tree
     */
    void exitRelational_geq(MagParser.Relational_geqContext ctx);

    /**
     * Enter a parse tree produced by the {@code relational_greater}
     * labeled alternative in {@link MagParser#relationalExpression}.
     *
     * @param ctx the parse tree
     */
    void enterRelational_greater(MagParser.Relational_greaterContext ctx);

    /**
     * Exit a parse tree produced by the {@code relational_greater}
     * labeled alternative in {@link MagParser#relationalExpression}.
     *
     * @param ctx the parse tree
     */
    void exitRelational_greater(MagParser.Relational_greaterContext ctx);

    /**
     * Enter a parse tree produced by the {@code relational_leq}
     * labeled alternative in {@link MagParser#relationalExpression}.
     *
     * @param ctx the parse tree
     */
    void enterRelational_leq(MagParser.Relational_leqContext ctx);

    /**
     * Exit a parse tree produced by the {@code relational_leq}
     * labeled alternative in {@link MagParser#relationalExpression}.
     *
     * @param ctx the parse tree
     */
    void exitRelational_leq(MagParser.Relational_leqContext ctx);

    /**
     * Enter a parse tree produced by the {@code relational_less}
     * labeled alternative in {@link MagParser#relationalExpression}.
     *
     * @param ctx the parse tree
     */
    void enterRelational_less(MagParser.Relational_lessContext ctx);

    /**
     * Exit a parse tree produced by the {@code relational_less}
     * labeled alternative in {@link MagParser#relationalExpression}.
     *
     * @param ctx the parse tree
     */
    void exitRelational_less(MagParser.Relational_lessContext ctx);

    /**
     * Enter a parse tree produced by the {@code shift_leftShift}
     * labeled alternative in {@link MagParser#shiftExpression}.
     *
     * @param ctx the parse tree
     */
    void enterShift_leftShift(MagParser.Shift_leftShiftContext ctx);

    /**
     * Exit a parse tree produced by the {@code shift_leftShift}
     * labeled alternative in {@link MagParser#shiftExpression}.
     *
     * @param ctx the parse tree
     */
    void exitShift_leftShift(MagParser.Shift_leftShiftContext ctx);

    /**
     * Enter a parse tree produced by the {@code shift_addSub}
     * labeled alternative in {@link MagParser#shiftExpression}.
     *
     * @param ctx the parse tree
     */
    void enterShift_addSub(MagParser.Shift_addSubContext ctx);

    /**
     * Exit a parse tree produced by the {@code shift_addSub}
     * labeled alternative in {@link MagParser#shiftExpression}.
     *
     * @param ctx the parse tree
     */
    void exitShift_addSub(MagParser.Shift_addSubContext ctx);

    /**
     * Enter a parse tree produced by the {@code shift_rightShift}
     * labeled alternative in {@link MagParser#shiftExpression}.
     *
     * @param ctx the parse tree
     */
    void enterShift_rightShift(MagParser.Shift_rightShiftContext ctx);

    /**
     * Exit a parse tree produced by the {@code shift_rightShift}
     * labeled alternative in {@link MagParser#shiftExpression}.
     *
     * @param ctx the parse tree
     */
    void exitShift_rightShift(MagParser.Shift_rightShiftContext ctx);

    /**
     * Enter a parse tree produced by the {@code addSub_mulDivRem}
     * labeled alternative in {@link MagParser#addSubExpression}.
     *
     * @param ctx the parse tree
     */
    void enterAddSub_mulDivRem(MagParser.AddSub_mulDivRemContext ctx);

    /**
     * Exit a parse tree produced by the {@code addSub_mulDivRem}
     * labeled alternative in {@link MagParser#addSubExpression}.
     *
     * @param ctx the parse tree
     */
    void exitAddSub_mulDivRem(MagParser.AddSub_mulDivRemContext ctx);

    /**
     * Enter a parse tree produced by the {@code addSub_sub}
     * labeled alternative in {@link MagParser#addSubExpression}.
     *
     * @param ctx the parse tree
     */
    void enterAddSub_sub(MagParser.AddSub_subContext ctx);

    /**
     * Exit a parse tree produced by the {@code addSub_sub}
     * labeled alternative in {@link MagParser#addSubExpression}.
     *
     * @param ctx the parse tree
     */
    void exitAddSub_sub(MagParser.AddSub_subContext ctx);

    /**
     * Enter a parse tree produced by the {@code addSub_add}
     * labeled alternative in {@link MagParser#addSubExpression}.
     *
     * @param ctx the parse tree
     */
    void enterAddSub_add(MagParser.AddSub_addContext ctx);

    /**
     * Exit a parse tree produced by the {@code addSub_add}
     * labeled alternative in {@link MagParser#addSubExpression}.
     *
     * @param ctx the parse tree
     */
    void exitAddSub_add(MagParser.AddSub_addContext ctx);

    /**
     * Enter a parse tree produced by the {@code mulDivRem_rem}
     * labeled alternative in {@link MagParser#mulDivRemExpression}.
     *
     * @param ctx the parse tree
     */
    void enterMulDivRem_rem(MagParser.MulDivRem_remContext ctx);

    /**
     * Exit a parse tree produced by the {@code mulDivRem_rem}
     * labeled alternative in {@link MagParser#mulDivRemExpression}.
     *
     * @param ctx the parse tree
     */
    void exitMulDivRem_rem(MagParser.MulDivRem_remContext ctx);

    /**
     * Enter a parse tree produced by the {@code mulDivRem_div}
     * labeled alternative in {@link MagParser#mulDivRemExpression}.
     *
     * @param ctx the parse tree
     */
    void enterMulDivRem_div(MagParser.MulDivRem_divContext ctx);

    /**
     * Exit a parse tree produced by the {@code mulDivRem_div}
     * labeled alternative in {@link MagParser#mulDivRemExpression}.
     *
     * @param ctx the parse tree
     */
    void exitMulDivRem_div(MagParser.MulDivRem_divContext ctx);

    /**
     * Enter a parse tree produced by the {@code mulDivRem_creation}
     * labeled alternative in {@link MagParser#mulDivRemExpression}.
     *
     * @param ctx the parse tree
     */
    void enterMulDivRem_creation(MagParser.MulDivRem_creationContext ctx);

    /**
     * Exit a parse tree produced by the {@code mulDivRem_creation}
     * labeled alternative in {@link MagParser#mulDivRemExpression}.
     *
     * @param ctx the parse tree
     */
    void exitMulDivRem_creation(MagParser.MulDivRem_creationContext ctx);

    /**
     * Enter a parse tree produced by the {@code mulDivRem_mul}
     * labeled alternative in {@link MagParser#mulDivRemExpression}.
     *
     * @param ctx the parse tree
     */
    void enterMulDivRem_mul(MagParser.MulDivRem_mulContext ctx);

    /**
     * Exit a parse tree produced by the {@code mulDivRem_mul}
     * labeled alternative in {@link MagParser#mulDivRemExpression}.
     *
     * @param ctx the parse tree
     */
    void exitMulDivRem_mul(MagParser.MulDivRem_mulContext ctx);

    /**
     * Enter a parse tree produced by the {@code creation_dim}
     * labeled alternative in {@link MagParser#creationExpression}.
     *
     * @param ctx the parse tree
     */
    void enterCreation_dim(MagParser.Creation_dimContext ctx);

    /**
     * Exit a parse tree produced by the {@code creation_dim}
     * labeled alternative in {@link MagParser#creationExpression}.
     *
     * @param ctx the parse tree
     */
    void exitCreation_dim(MagParser.Creation_dimContext ctx);

    /**
     * Enter a parse tree produced by the {@code creation_para}
     * labeled alternative in {@link MagParser#creationExpression}.
     *
     * @param ctx the parse tree
     */
    void enterCreation_para(MagParser.Creation_paraContext ctx);

    /**
     * Exit a parse tree produced by the {@code creation_para}
     * labeled alternative in {@link MagParser#creationExpression}.
     *
     * @param ctx the parse tree
     */
    void exitCreation_para(MagParser.Creation_paraContext ctx);

    /**
     * Enter a parse tree produced by the {@code creation_prefix}
     * labeled alternative in {@link MagParser#creationExpression}.
     *
     * @param ctx the parse tree
     */
    void enterCreation_prefix(MagParser.Creation_prefixContext ctx);

    /**
     * Exit a parse tree produced by the {@code creation_prefix}
     * labeled alternative in {@link MagParser#creationExpression}.
     *
     * @param ctx the parse tree
     */
    void exitCreation_prefix(MagParser.Creation_prefixContext ctx);

    /**
     * Enter a parse tree produced by the {@code dimension_}
     * labeled alternative in {@link MagParser#dimensionExpression}.
     *
     * @param ctx the parse tree
     */
    void enterDimension_(MagParser.Dimension_Context ctx);

    /**
     * Exit a parse tree produced by the {@code dimension_}
     * labeled alternative in {@link MagParser#dimensionExpression}.
     *
     * @param ctx the parse tree
     */
    void exitDimension_(MagParser.Dimension_Context ctx);

    /**
     * Enter a parse tree produced by the {@code dimension_dim}
     * labeled alternative in {@link MagParser#dimensionExpression}.
     *
     * @param ctx the parse tree
     */
    void enterDimension_dim(MagParser.Dimension_dimContext ctx);

    /**
     * Exit a parse tree produced by the {@code dimension_dim}
     * labeled alternative in {@link MagParser#dimensionExpression}.
     *
     * @param ctx the parse tree
     */
    void exitDimension_dim(MagParser.Dimension_dimContext ctx);

    /**
     * Enter a parse tree produced by the {@code prefix_postfix}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPrefix_postfix(MagParser.Prefix_postfixContext ctx);

    /**
     * Exit a parse tree produced by the {@code prefix_postfix}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPrefix_postfix(MagParser.Prefix_postfixContext ctx);

    /**
     * Enter a parse tree produced by the {@code prefix_positive}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPrefix_positive(MagParser.Prefix_positiveContext ctx);

    /**
     * Exit a parse tree produced by the {@code prefix_positive}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPrefix_positive(MagParser.Prefix_positiveContext ctx);

    /**
     * Enter a parse tree produced by the {@code prefix_negative}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPrefix_negative(MagParser.Prefix_negativeContext ctx);

    /**
     * Exit a parse tree produced by the {@code prefix_negative}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPrefix_negative(MagParser.Prefix_negativeContext ctx);

    /**
     * Enter a parse tree produced by the {@code prefix_not}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPrefix_not(MagParser.Prefix_notContext ctx);

    /**
     * Exit a parse tree produced by the {@code prefix_not}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPrefix_not(MagParser.Prefix_notContext ctx);

    /**
     * Enter a parse tree produced by the {@code prefix_tilde}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPrefix_tilde(MagParser.Prefix_tildeContext ctx);

    /**
     * Exit a parse tree produced by the {@code prefix_tilde}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPrefix_tilde(MagParser.Prefix_tildeContext ctx);

    /**
     * Enter a parse tree produced by the {@code prefix_plusPlus}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPrefix_plusPlus(MagParser.Prefix_plusPlusContext ctx);

    /**
     * Exit a parse tree produced by the {@code prefix_plusPlus}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPrefix_plusPlus(MagParser.Prefix_plusPlusContext ctx);

    /**
     * Enter a parse tree produced by the {@code prefix_minusMinus}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPrefix_minusMinus(MagParser.Prefix_minusMinusContext ctx);

    /**
     * Exit a parse tree produced by the {@code prefix_minusMinus}
     * labeled alternative in {@link MagParser#prefixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPrefix_minusMinus(MagParser.Prefix_minusMinusContext ctx);

    /**
     * Enter a parse tree produced by the {@code postfix_id}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPostfix_id(MagParser.Postfix_idContext ctx);

    /**
     * Exit a parse tree produced by the {@code postfix_id}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPostfix_id(MagParser.Postfix_idContext ctx);

    /**
     * Enter a parse tree produced by the {@code postfix_incre}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPostfix_incre(MagParser.Postfix_increContext ctx);

    /**
     * Exit a parse tree produced by the {@code postfix_incre}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPostfix_incre(MagParser.Postfix_increContext ctx);

    /**
     * Enter a parse tree produced by the {@code postfix_expression}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPostfix_expression(MagParser.Postfix_expressionContext ctx);

    /**
     * Exit a parse tree produced by the {@code postfix_expression}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPostfix_expression(MagParser.Postfix_expressionContext ctx);

    /**
     * Enter a parse tree produced by the {@code postfix_primary}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPostfix_primary(MagParser.Postfix_primaryContext ctx);

    /**
     * Exit a parse tree produced by the {@code postfix_primary}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPostfix_primary(MagParser.Postfix_primaryContext ctx);

    /**
     * Enter a parse tree produced by the {@code postfix_argument}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPostfix_argument(MagParser.Postfix_argumentContext ctx);

    /**
     * Exit a parse tree produced by the {@code postfix_argument}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPostfix_argument(MagParser.Postfix_argumentContext ctx);

    /**
     * Enter a parse tree produced by the {@code postfix_decre}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPostfix_decre(MagParser.Postfix_decreContext ctx);

    /**
     * Exit a parse tree produced by the {@code postfix_decre}
     * labeled alternative in {@link MagParser#postfixExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPostfix_decre(MagParser.Postfix_decreContext ctx);

    /**
     * Enter a parse tree produced by the {@code primary_id}
     * labeled alternative in {@link MagParser#primaryExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPrimary_id(MagParser.Primary_idContext ctx);

    /**
     * Exit a parse tree produced by the {@code primary_id}
     * labeled alternative in {@link MagParser#primaryExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPrimary_id(MagParser.Primary_idContext ctx);

    /**
     * Enter a parse tree produced by the {@code primary_constant}
     * labeled alternative in {@link MagParser#primaryExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPrimary_constant(MagParser.Primary_constantContext ctx);

    /**
     * Exit a parse tree produced by the {@code primary_constant}
     * labeled alternative in {@link MagParser#primaryExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPrimary_constant(MagParser.Primary_constantContext ctx);

    /**
     * Enter a parse tree produced by the {@code primary_expression}
     * labeled alternative in {@link MagParser#primaryExpression}.
     *
     * @param ctx the parse tree
     */
    void enterPrimary_expression(MagParser.Primary_expressionContext ctx);

    /**
     * Exit a parse tree produced by the {@code primary_expression}
     * labeled alternative in {@link MagParser#primaryExpression}.
     *
     * @param ctx the parse tree
     */
    void exitPrimary_expression(MagParser.Primary_expressionContext ctx);

    /**
     * Enter a parse tree produced by the {@code constant_null}
     * labeled alternative in {@link MagParser#constant}.
     *
     * @param ctx the parse tree
     */
    void enterConstant_null(MagParser.Constant_nullContext ctx);

    /**
     * Exit a parse tree produced by the {@code constant_null}
     * labeled alternative in {@link MagParser#constant}.
     *
     * @param ctx the parse tree
     */
    void exitConstant_null(MagParser.Constant_nullContext ctx);

    /**
     * Enter a parse tree produced by the {@code constant_int}
     * labeled alternative in {@link MagParser#constant}.
     *
     * @param ctx the parse tree
     */
    void enterConstant_int(MagParser.Constant_intContext ctx);

    /**
     * Exit a parse tree produced by the {@code constant_int}
     * labeled alternative in {@link MagParser#constant}.
     *
     * @param ctx the parse tree
     */
    void exitConstant_int(MagParser.Constant_intContext ctx);

    /**
     * Enter a parse tree produced by the {@code constant_string}
     * labeled alternative in {@link MagParser#constant}.
     *
     * @param ctx the parse tree
     */
    void enterConstant_string(MagParser.Constant_stringContext ctx);

    /**
     * Exit a parse tree produced by the {@code constant_string}
     * labeled alternative in {@link MagParser#constant}.
     *
     * @param ctx the parse tree
     */
    void exitConstant_string(MagParser.Constant_stringContext ctx);

    /**
     * Enter a parse tree produced by the {@code constant_logic}
     * labeled alternative in {@link MagParser#constant}.
     *
     * @param ctx the parse tree
     */
    void enterConstant_logic(MagParser.Constant_logicContext ctx);

    /**
     * Exit a parse tree produced by the {@code constant_logic}
     * labeled alternative in {@link MagParser#constant}.
     *
     * @param ctx the parse tree
     */
    void exitConstant_logic(MagParser.Constant_logicContext ctx);

    /**
     * Enter a parse tree produced by the {@code logic_true}
     * labeled alternative in {@link MagParser#logicConstant}.
     *
     * @param ctx the parse tree
     */
    void enterLogic_true(MagParser.Logic_trueContext ctx);

    /**
     * Exit a parse tree produced by the {@code logic_true}
     * labeled alternative in {@link MagParser#logicConstant}.
     *
     * @param ctx the parse tree
     */
    void exitLogic_true(MagParser.Logic_trueContext ctx);

    /**
     * Enter a parse tree produced by the {@code logic_false}
     * labeled alternative in {@link MagParser#logicConstant}.
     *
     * @param ctx the parse tree
     */
    void enterLogic_false(MagParser.Logic_falseContext ctx);

    /**
     * Exit a parse tree produced by the {@code logic_false}
     * labeled alternative in {@link MagParser#logicConstant}.
     *
     * @param ctx the parse tree
     */
    void exitLogic_false(MagParser.Logic_falseContext ctx);

    /**
     * Enter a parse tree produced by the {@code argument_expression}
     * labeled alternative in {@link MagParser#argumentExpressionList}.
     *
     * @param ctx the parse tree
     */
    void enterArgument_expression(MagParser.Argument_expressionContext ctx);

    /**
     * Exit a parse tree produced by the {@code argument_expression}
     * labeled alternative in {@link MagParser#argumentExpressionList}.
     *
     * @param ctx the parse tree
     */
    void exitArgument_expression(MagParser.Argument_expressionContext ctx);

    /**
     * Enter a parse tree produced by the {@code argument_expressionList}
     * labeled alternative in {@link MagParser#argumentExpressionList}.
     *
     * @param ctx the parse tree
     */
    void enterArgument_expressionList(MagParser.Argument_expressionListContext ctx);

    /**
     * Exit a parse tree produced by the {@code argument_expressionList}
     * labeled alternative in {@link MagParser#argumentExpressionList}.
     *
     * @param ctx the parse tree
     */
    void exitArgument_expressionList(MagParser.Argument_expressionListContext ctx);

    /**
     * Enter a parse tree produced by the {@code selection_if}
     * labeled alternative in {@link MagParser#selectionStatement}.
     *
     * @param ctx the parse tree
     */
    void enterSelection_if(MagParser.Selection_ifContext ctx);

    /**
     * Exit a parse tree produced by the {@code selection_if}
     * labeled alternative in {@link MagParser#selectionStatement}.
     *
     * @param ctx the parse tree
     */
    void exitSelection_if(MagParser.Selection_ifContext ctx);

    /**
     * Enter a parse tree produced by the {@code selection_ifElse}
     * labeled alternative in {@link MagParser#selectionStatement}.
     *
     * @param ctx the parse tree
     */
    void enterSelection_ifElse(MagParser.Selection_ifElseContext ctx);

    /**
     * Exit a parse tree produced by the {@code selection_ifElse}
     * labeled alternative in {@link MagParser#selectionStatement}.
     *
     * @param ctx the parse tree
     */
    void exitSelection_ifElse(MagParser.Selection_ifElseContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#iterationStatement}.
     *
     * @param ctx the parse tree
     */
    void enterIterationStatement(MagParser.IterationStatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#iterationStatement}.
     *
     * @param ctx the parse tree
     */
    void exitIterationStatement(MagParser.IterationStatementContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#whileStatement}.
     *
     * @param ctx the parse tree
     */
    void enterWhileStatement(MagParser.WhileStatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#whileStatement}.
     *
     * @param ctx the parse tree
     */
    void exitWhileStatement(MagParser.WhileStatementContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#forStatement}.
     *
     * @param ctx the parse tree
     */
    void enterForStatement(MagParser.ForStatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#forStatement}.
     *
     * @param ctx the parse tree
     */
    void exitForStatement(MagParser.ForStatementContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#jumpStatement}.
     *
     * @param ctx the parse tree
     */
    void enterJumpStatement(MagParser.JumpStatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#jumpStatement}.
     *
     * @param ctx the parse tree
     */
    void exitJumpStatement(MagParser.JumpStatementContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#returnStatement}.
     *
     * @param ctx the parse tree
     */
    void enterReturnStatement(MagParser.ReturnStatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#returnStatement}.
     *
     * @param ctx the parse tree
     */
    void exitReturnStatement(MagParser.ReturnStatementContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#breakStatement}.
     *
     * @param ctx the parse tree
     */
    void enterBreakStatement(MagParser.BreakStatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#breakStatement}.
     *
     * @param ctx the parse tree
     */
    void exitBreakStatement(MagParser.BreakStatementContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#continueStatement}.
     *
     * @param ctx the parse tree
     */
    void enterContinueStatement(MagParser.ContinueStatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#continueStatement}.
     *
     * @param ctx the parse tree
     */
    void exitContinueStatement(MagParser.ContinueStatementContext ctx);

    /**
     * Enter a parse tree produced by {@link MagParser#variableDeclarationStatement}.
     *
     * @param ctx the parse tree
     */
    void enterVariableDeclarationStatement(MagParser.VariableDeclarationStatementContext ctx);

    /**
     * Exit a parse tree produced by {@link MagParser#variableDeclarationStatement}.
     *
     * @param ctx the parse tree
     */
    void exitVariableDeclarationStatement(MagParser.VariableDeclarationStatementContext ctx);

    /**
     * Enter a parse tree produced by the {@code varDecl_}
     * labeled alternative in {@link MagParser#variableDeclaration}.
     *
     * @param ctx the parse tree
     */
    void enterVarDecl_(MagParser.VarDecl_Context ctx);

    /**
     * Exit a parse tree produced by the {@code varDecl_}
     * labeled alternative in {@link MagParser#variableDeclaration}.
     *
     * @param ctx the parse tree
     */
    void exitVarDecl_(MagParser.VarDecl_Context ctx);

    /**
     * Enter a parse tree produced by the {@code varDecl_init}
     * labeled alternative in {@link MagParser#variableDeclaration}.
     *
     * @param ctx the parse tree
     */
    void enterVarDecl_init(MagParser.VarDecl_initContext ctx);

    /**
     * Exit a parse tree produced by the {@code varDecl_init}
     * labeled alternative in {@link MagParser#variableDeclaration}.
     *
     * @param ctx the parse tree
     */
    void exitVarDecl_init(MagParser.VarDecl_initContext ctx);

    /**
     * Enter a parse tree produced by the {@code functionDecl_returnType}
     * labeled alternative in {@link MagParser#functionDeclaration}.
     *
     * @param ctx the parse tree
     */
    void enterFunctionDecl_returnType(MagParser.FunctionDecl_returnTypeContext ctx);

    /**
     * Exit a parse tree produced by the {@code functionDecl_returnType}
     * labeled alternative in {@link MagParser#functionDeclaration}.
     *
     * @param ctx the parse tree
     */
    void exitFunctionDecl_returnType(MagParser.FunctionDecl_returnTypeContext ctx);

    /**
     * Enter a parse tree produced by the {@code functionDecl_void}
     * labeled alternative in {@link MagParser#functionDeclaration}.
     *
     * @param ctx the parse tree
     */
    void enterFunctionDecl_void(MagParser.FunctionDecl_voidContext ctx);

    /**
     * Exit a parse tree produced by the {@code functionDecl_void}
     * labeled alternative in {@link MagParser#functionDeclaration}.
     *
     * @param ctx the parse tree
     */
    void exitFunctionDecl_void(MagParser.FunctionDecl_voidContext ctx);

    /**
     * Enter a parse tree produced by the {@code parameter_}
     * labeled alternative in {@link MagParser#parameterList}.
     *
     * @param ctx the parse tree
     */
    void enterParameter_(MagParser.Parameter_Context ctx);

    /**
     * Exit a parse tree produced by the {@code parameter_}
     * labeled alternative in {@link MagParser#parameterList}.
     *
     * @param ctx the parse tree
     */
    void exitParameter_(MagParser.Parameter_Context ctx);

    /**
     * Enter a parse tree produced by the {@code parameter_list}
     * labeled alternative in {@link MagParser#parameterList}.
     *
     * @param ctx the parse tree
     */
    void enterParameter_list(MagParser.Parameter_listContext ctx);

    /**
     * Exit a parse tree produced by the {@code parameter_list}
     * labeled alternative in {@link MagParser#parameterList}.
     *
     * @param ctx the parse tree
     */
    void exitParameter_list(MagParser.Parameter_listContext ctx);
}