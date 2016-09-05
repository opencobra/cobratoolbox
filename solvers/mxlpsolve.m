% mxlpsolve  Mex file interface to the lp_solve 5.5 toolkit. Please see
% reference guide for more information.
%
% mxlpsolve is a low-level interface to the lp_solve toolkit. It may be called
% directly, or may be used to build higher level functions for solving
% various kinds of linear and mixed-integer linear programs. It uses an
% integer handle to point to a linear program.
%
%     return = mxlpsolve('add_column', lp, [column])
%
%     return = mxlpsolve('add_columnex', lp, [column])
%
%     return = mxlpsolve('add_constraint', lp, [row], constr_type, rh)
%
%     return = mxlpsolve('add_constraintex', lp, [row], constr_type, rh)
%
%     return = mxlpsolve('add_SOS', lp, name, sostype, priority, [sosvars], [weights])
%
%     return = mxlpsolve('column_in_lp', lp, [column])
%
%     mxlpsolve('default_basis', lp)
%
%     return = mxlpsolve('del_column', lp, column)
%
%     return = mxlpsolve('del_constraint', lp, del_row)
%
%     lp_handle = mxlpsolve('copy_lp', lp)
%
%     mxlpsolve('delete_lp', lp)
%
%     mxlpsolve('dualize_lp', lp)
%
%     mxlpsolve('free_lp', lp)
%
%     return = mxlpsolve('get_anti_degen', lp)
%
%     [bascolumn] = mxlpsolve('get_basis', lp {, nonbasic})
%
%     return = mxlpsolve('get_basiscrash', lp)
%
%     return = mxlpsolve('get_bb_depthlimit', lp)
%
%     return = mxlpsolve('get_bb_floorfirst', lp)
%
%     return = mxlpsolve('get_bb_rule', lp)
%
%     return = mxlpsolve('get_bounds_tighter', lp)
%
%     return = mxlpsolve('get_break_at_value', lp)
%
%     name = mxlpsolve('get_col_name', lp, column)
%
%     [names] = mxlpsolve('get_col_name', lp)
%
%     [column, return] = mxlpsolve('get_column', lp, col_nr)
%
%     [column, return] = mxlpsolve('get_columnex', lp, col_nr)
%
%     return = mxlpsolve('get_constr_type', lp, row)
%
%     return = mxlpsolve('get_constr_value', lp, row {, primsolution})
%
%     [constr_type] = mxlpsolve('get_constr_type', lp)
%
%     [constr, return] = mxlpsolve('get_constraints', lp)
%
%     [duals, return] = mxlpsolve('get_dual_solution', lp)
%
%     return = mxlpsolve('get_epsb', lp)
%
%     return = mxlpsolve('get_epsd', lp)
%
%     return = mxlpsolve('get_epsel', lp)
%
%     return = mxlpsolve('get_epsint', lp)
%
%     return = mxlpsolve('get_epsperturb', lp)
%
%     return = mxlpsolve('get_epspivot', lp)
%
%     lp_handle = mxlpsolve('get_handle', lp_name)
%
%     return = mxlpsolve('get_improve', lp)
%
%     return = mxlpsolve('get_infinite', lp)
%
%     return = mxlpsolve('get_lowbo', lp, column)
%
%     [return] = mxlpsolve('get_lowbo', lp)
%
%     return = mxlpsolve('get_lp_index', lp, orig_index)
%
%     name = mxlpsolve('get_lp_name', lp)
%
%     value = mxlpsolve('get_mat', lp, row, col)
%
%     [matrix, return] = mxlpsolve('get_mat', lp {, sparse})
%
%     return = mxlpsolve('get_max_level', lp)
%
%     return = mxlpsolve('get_maxpivot', lp)
%
%     return = mxlpsolve('get_mip_gap', lp, absolute)
%
%     return = mxlpsolve('get_nameindex', lp, name, isrow)
%
%     return = mxlpsolve('get_Ncolumns', lp)
%
%     return = mxlpsolve('get_negrange', lp)
%
%     return = mxlpsolve('get_nonzeros', lp)
%
%     return = mxlpsolve('get_Norig_columns', lp)
%
%     return = mxlpsolve('get_Norig_rows', lp)
%
%     return = mxlpsolve('get_Nrows', lp)
%
%     return = mxlpsolve('get_obj_bound', lp)
%
%     [row_vec, return] = mxlpsolve('get_obj_fn', lp)
%
%     [row_vec, return] = mxlpsolve('get_obj_fun', lp)
%
%     return = mxlpsolve('get_objective', lp)
%
%     name = mxlpsolve('get_objective_name', lp)
%
%     return = mxlpsolve('get_orig_index', lp, lp_index)
%
%     name = mxlpsolve('get_origcol_name', lp, column)
%
%     [names] = mxlpsolve('get_origcol_name', lp)
%
%     name = mxlpsolve('get_origrow_name', lp, row)
%
%     [names] = mxlpsolve('get_origrow_name', lp)
%
%     return = mxlpsolve('get_pivoting', lp)
%
%     return = mxlpsolve('get_presolve', lp)
%
%     return = mxlpsolve('get_presolveloops', lp)
%
%     [pv, return] = mxlpsolve('get_primal_solution', lp)
%
%     return = mxlpsolve('get_print_sol', lp)
%
%     return = mxlpsolve('get_rh', lp, row)
%
%     [rh] = mxlpsolve('get_rh', lp)
%
%     return = mxlpsolve('get_rh_range', lp, row)
%
%     [rh_ranges] = mxlpsolve('get_rh_range', lp)
%
%     [row, return] = mxlpsolve('get_row', lp, row_nr)
%
%     [row, return] = mxlpsolve('get_rowex', lp, row_nr)
%
%     name = mxlpsolve('get_row_name', lp, row)
%
%     [names] = mxlpsolve('get_row_name', lp)
%
%     return = mxlpsolve('get_scalelimit', lp)
%
%     return = mxlpsolve('get_scaling', lp)
%
%     [objfrom, objtill, objfromvalue, objtillvalue, return] = mxlpsolve('get_sensitivity_obj', lp)
%
%     [objfrom, objtill, objfromvalue, objtillvalue, return] = mxlpsolve('get_sensitivity_objex', lp)
%
%     [duals, dualsfrom, dualstill, return] = mxlpsolve('get_sensitivity_rhs', lp)
%
%     [duals, dualsfrom, dualstill, return] = mxlpsolve('get_sensitivity_rhsex', lp)
%
%     return = mxlpsolve('get_simplextype', lp)
%
%     [obj, x, duals, return] = mxlpsolve('get_solution', lp)
%
%     return = mxlpsolve('get_solutioncount', lp)
%
%     return = mxlpsolve('get_solutionlimit', lp)
%
%     return = mxlpsolve('get_status', lp)
%
%     return = mxlpsolve('get_statustext', lp, statuscode)
%
%     return = mxlpsolve('get_timeout', lp)
%
%     return = mxlpsolve('get_total_iter', lp)
%
%     return = mxlpsolve('get_total_nodes', lp)
%
%     return = mxlpsolve('get_upbo', lp, column)
%
%     [upbo] = mxlpsolve('get_upbo', lp)
%
%     return = mxlpsolve('get_var_branch', lp, column)
%
%     [var_branch] = mxlpsolve('get_var_branch', lp)
%
%     return = mxlpsolve('get_var_dualresult', lp, index)
%
%     return = mxlpsolve('get_var_primalresult', lp, index)
%
%     return = mxlpsolve('get_var_priority', lp, column)
%
%     [var_priority] = mxlpsolve('get_var_priority', lp)
%
%     [var, return] = mxlpsolve('get_variables', lp)
%
%     return = mxlpsolve('get_verbose', lp)
%
%     return = mxlpsolve('get_working_objective', lp)
%
%     return = mxlpsolve('has_BFP', lp)
%
%     return = mxlpsolve('has_XLI', lp)
%
%     return = mxlpsolve('is_add_rowmode', lp)
%
%     return = mxlpsolve('is_anti_degen', lp, testmask)
%
%     return = mxlpsolve('is_binary', lp, column)
%
%     [binary] = mxlpsolve('is_binary', lp)
%
%     return = mxlpsolve('is_break_at_first', lp)
%
%     return = mxlpsolve('is_constr_type', lp, row, mask)
%
%     return = mxlpsolve('is_debug', lp)
%
%     return = mxlpsolve('is_feasible', lp, [values] {, threshold})
%
%     return = mxlpsolve('is_free', lp, column)
%
%     return = mxlpsolve('is_unbounded', lp, column)
%
%     [free] = mxlpsolve('is_free', lp)
%
%     [free] = mxlpsolve('is_unbounded', lp)
%
%     return = mxlpsolve('is_infinite', lp, value)
%
%     return = mxlpsolve('is_int', lp, column)
%
%     [int] = mxlpsolve('is_int', lp)
%
%     return = mxlpsolve('is_integerscaling', lp)
%
%     return = mxlpsolve('is_maxim', lp)
%
%     return = mxlpsolve('is_nativeBFP', lp)
%
%     return = mxlpsolve('is_nativeXLI', lp)
%
%     return = mxlpsolve('is_negative', lp, column)
%
%     [negative] = mxlpsolve('is_negative', lp)
%
%     return = mxlpsolve('is_piv_mode', lp, testmask)
%
%     return = mxlpsolve('is_piv_rule', lp, rule)
%
%     return = mxlpsolve('is_presolve', lp, testmask)
%
%     return = mxlpsolve('is_scalemode', lp, testmask)
%
%     return = mxlpsolve('is_scaletype', lp, scaletype)
%
%     return = mxlpsolve('is_semicont', lp, column)
%
%     [semicont] = mxlpsolve('is_semicont', lp)
%
%     return = mxlpsolve('is_SOS_var', lp, column)
%
%     [SOS_var] = mxlpsolve('is_SOS_var', lp)
%
%     return = mxlpsolve('is_trace', lp)
%
%     return = mxlpsolve('is_use_names', lp, isrow)
%
%     versionstring = mxlpsolve('lp_solve_version')
%
%     lp_handle = mxlpsolve('make_lp', rows, columns)
%
%     mxlpsolve('print_constraints', lp {, columns})
%
%     return = mxlpsolve('print_debugdump', lp, filename)
%
%     mxlpsolve('print_duals', lp)
%
%     mxlpsolve('print_lp', lp)
%
%     mxlpsolve('print_objective', lp)
%
%     mxlpsolve('print_scales', lp)
%
%     mxlpsolve('print_solution', lp {, columns})
%
%     mxlpsolve('print_str', lp, str)
%
%     mxlpsolve('print_tableau', lp)
%
%     [handle_vec] = mxlpsolve('print_handle')
%
%     lp_handle = mxlpsolve('read_freeMPS', filename {, verbose})
%
%     lp_handle = mxlpsolve('read_lp_file', filename {, verbose {, lp_name}})
%
%     lp_handle = mxlpsolve('read_lp', filename {, verbose {, lp_name}})
%
%     lp_handle = mxlpsolve('read_LP', filename {, verbose {, lp_name}})
%
%     lp_handle = mxlpsolve('read_mps', filename {, verbose})
%
%     lp_handle = mxlpsolve('read_MPS', filename {, verbose})
%
%     return = mxlpsolve('read_params', lp, filename {, options})
%
%     return = mxlpsolve('reset_params', lp)
%
%     lp_handle = mxlpsolve('read_XLI', xliname, modelname {, dataname {, options {, verbose}}})
%
%     return = mxlpsolve('set_add_rowmode', lp, turnon)
%
%     mxlpsolve('set_anti_degen', lp, anti_degen)
%
%     return = mxlpsolve('set_basis', lp, [bascolumn], nonbasic)
%
%     mxlpsolve('set_basiscrash', lp, mode)
%
%     mxlpsolve('set_basisvar', lp, basisPos, enteringCol)
%
%     mxlpsolve('set_bb_depthlimit', lp, bb_maxlevel)
%
%     mxlpsolve('set_bb_floorfirst', lp, bb_floorfirst)
%
%     mxlpsolve('set_bb_rule', lp, bb_rule)
%
%     return = mxlpsolve('set_BFP', lp, filename)
%
%     return = mxlpsolve('set_binary', lp, column, must_be_bin)
%
%     return = mxlpsolve('set_binary', lp, [must_be_bin])
%
%     return = mxlpsolve('set_bounds', lp, column, lower, upper)
%
%     return = mxlpsolve('set_bounds', lp, [lower], [upper])
%
%     mxlpsolve('set_bounds_tighter', lp, tighten)
%
%     mxlpsolve('set_break_at_first', lp, break_at_first)
%
%     mxlpsolve('set_break_at_value', lp, break_at_value)
%
%     return = mxlpsolve('set_col_name', lp, column, name)
%
%     return = mxlpsolve('set_col_name', lp, [names])
%
%     return = mxlpsolve('set_column', lp, col_no, [column])
%
%     return = mxlpsolve('set_columnex', lp, col_no, [column])
%
%     return = mxlpsolve('set_constr_type', lp, row, con_type)
%
%     return = mxlpsolve('set_constr_type', lp, [con_type])
%
%     mxlpsolve('set_debug', lp, debug)
%
%     mxlpsolve('set_epsb', lp, epsb)
%
%     mxlpsolve('set_epsd', lp, epsd)
%
%     mxlpsolve('set_epsel', lp, epsel)
%
%     mxlpsolve('set_epsint', lp, epsint)
%
%     mxlpsolve('set_epslevel', lp, epslevel)
%
%     mxlpsolve('set_epsperturb', lp, epsperturb)
%
%     mxlpsolve('set_epspivot', lp, epspivot)
%
%     return = mxlpsolve('set_free', lp, column)
%
%     return = mxlpsolve('set_unbounded', lp, column)
%
%     mxlpsolve('set_improve', lp, improve)
%
%     mxlpsolve('set_infinite', lp, infinite)
%
%     return = mxlpsolve('set_int', lp, column, must_be_int)
%
%     return = mxlpsolve('set_int', lp, [must_be_int])
%
%     return = mxlpsolve('set_lowbo', lp, column, value)
%
%     return = mxlpsolve('set_lowbo', lp, [values])
%
%     return = mxlpsolve('set_lp_name', lp, name)
%
%     return = mxlpsolve('set_mat', lp, [matrix])
%
%     return = mxlpsolve('set_mat', lp, row, column, value)
%
%     mxlpsolve('set_maxim', lp)
%
%     mxlpsolve('set_maxpivot', max_num_inv)
%
%     mxlpsolve('set_minim', lp)
%
%     mxlpsolve('set_mip_gap', lp, absolute, mip_gap)
%
%     mxlpsolve('set_negrange', negrange)
%
%     return = mxlpsolve('set_obj', lp, column, value)
%
%     return = mxlpsolve('set_obj', lp, [values])
%
%     mxlpsolve('set_obj_bound', lp, obj_bound)
%
%     return = mxlpsolve('set_obj_fn', lp, [row])
%
%     return = mxlpsolve('set_obj_fnex', lp, [row])
%
%     return = mxlpsolve('set_outputfile', lp, filename)
%
%     mxlpsolve('set_pivoting', lp, pivoting)
%
%     mxlpsolve('set_preferdual', lp, dodual)
%
%     mxlpsolve('set_presolve', lp, do_presolve {, maxloops})
%
%     mxlpsolve('set_print_sol', lp, print_sol)
%
%     return = mxlpsolve('set_rh', lp, row, value)
%
%     return = mxlpsolve('set_rh', lp, [values])
%
%     return = mxlpsolve('set_rh_range', lp, row, deltavalue)
%
%     return = mxlpsolve('set_rh_range', lp, [deltavalues])
%
%     mxlpsolve('set_rh_vec', lp, [rh])
%
%     return = mxlpsolve('set_row', lp, row_no, [row])
%
%     return = mxlpsolve('set_rowex', lp, row_no, [row])
%
%     return = mxlpsolve('set_row_name', lp, row, name)
%
%     return = mxlpsolve('set_row_name', lp, [names])
%
%     mxlpsolve('set_scalelimit', lp, scalelimit)
%
%     mxlpsolve('set_scaling', lp, scalemode)
%
%     return = mxlpsolve('set_semicont', lp, column, must_be_sc)
%
%     return = mxlpsolve('set_semicont', lp, [must_be_sc])
%
%     mxlpsolve('set_sense', lp, maximize)
%
%     mxlpsolve('set_simplextype', lp, simplextype)
%
%     mxlpsolve('set_solutionlimit', lp, simplextype)
%
%     mxlpsolve('set_timeout', lp, sectimeout)
%
%     mxlpsolve('set_trace', lp, trace)
%
%     return = mxlpsolve('set_upbo', lp, column, value)
%
%     return = mxlpsolve('set_upbo', lp, [values])
%
%     mxlpsolve('set_use_names', lp, isrow, use_names)
%
%     return = mxlpsolve('set_var_branch', lp, column, branch_mode)
%
%     return = mxlpsolve('set_var_branch', lp, [branch_mode])
%
%     return = mxlpsolve('set_var_weights', lp, [weights])
%
%     mxlpsolve('set_verbose', lp, verbose)
%
%     return = mxlpsolve('set_XLI', lp, filename)
%
%     result = mxlpsolve('solve', lp)
%
%     return = mxlpsolve('time_elapsed', lp)
%
%     mxlpsolve('unscale', lp)
%
%     return = mxlpsolve('write_freemps', lp, filename)
%
%     return = mxlpsolve('write_freeMPS', lp, filename)
%
%     return = mxlpsolve('write_lp', lp, filename)
%
%     return = mxlpsolve('write_LP', lp, filename)
%
%     return = mxlpsolve('write_mps', lp, filename)
%
%     return = mxlpsolve('write_MPS', lp, filename)
%
%     return = mxlpsolve('write_params', lp, filename {, options})
%
%     return = mxlpsolve('write_XLI', lp, filename {, options {, results}})
%

disp('mxlpsolve driver not found !!!');
disp('Check if mxlpsolve.dll is on your system and in a directory known to MATLAB.');
disp('Press enter to see the paths where MATLAB looks for the driver.');
pause
path
disp('A path can be added via the menu: File, Set Path');
error('mxlpsolve.dll not found');
