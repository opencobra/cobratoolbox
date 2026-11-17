% The COBRAToolbox: testGenerateMexFastFVA.m
%
% Purpose:
%     - generateMexFastFVA(rootPathCPLEX, printLevel) compiles the C source of fastFVA
%       (cplexFVA.c) into a MEX file against an IBM CPLEX installation. It takes the CPLEX root
%       from the global ILOG_CPLEX_PATH when rootPathCPLEX is not given or empty, reads the CPLEX
%       version from that path (getCobraSolverVersion), and stops with an error when the CPLEX
%       include folder or library folder is missing.
%     - Once the wrong-result defect below is fixed, the test should build CPLEX installation
%       folders by hand in a tempname folder (CPLEX 12.10 and 12.8) and check: the errors for a
%       missing include folder and a missing library folder (text derived from the folders),
%       the root taken from ILOG_CPLEX_PATH, and, with mex replaced by a stand-in function
%       that records its arguments (a mex.m written in a temporary folder put first on the
%       path; MATLAB warns that it shadows a built-in) and CBTDIR pointing to a temporary
%       folder holding a copy of compatMatrix.rst, the two calls of mex ('-setup c' and the
%       compilation command with the version flag of lines 79-86 in CFLAGS, output name,
%       dynamic linker, include folder, source file, library), the MEX folder <CBTDIR>/.tmp
%       added to the path and the current folder restored; and the call with SOLVERS empty
%       (initCobraToolbox first). Every global, the solver state and the path restored.
%       Quarantined: no behaviour of generateMexFastFVA is asserted until the wrong-result
%       defect below is fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver (CPLEX folders are hand-built; nothing is compiled or solved).
%
% Coverage exemptions:
%     every line - generateMexFastFVA is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the existence of the CPLEX library file is never checked
%       SEVERITY: cosmetic
%       TRIGGER: generateMexFastFVA(root, 0) with root/include/ilcplex and
%                root/lib/x86-64_linux/static_pic present but no libcplex.a in the latter
%       OBSERVED: MATLAB 2026-11-13 (with mex replaced by a recording stub in a scratch run):
%                 the function goes on to "mex -setup c" and to the compilation, passing the
%                 missing .../static_pic/libcplex.a to mex; line 111 tests exist(lib, 'dir')
%                 again instead of the library file, so the error of line 112 cannot occur
%       EXPECTED: the error "The required CPLEX library file ... does not exist." of line 112
%       LINES: 110-112
%     - DEFECT: printLevel 2 prints a truncated compilation command and a warning
%       SEVERITY: cosmetic
%       TRIGGER: generateMexFastFVA(root, 2) with a CPLEX installation (include and library
%                folders present)
%       OBSERVED: MATLAB 2026-11-13 (scratch run, mex stubbed): "Warning: Escaped character '\$'
%                 is not valid." and the printed command stops at CFLAGS=" because the command
%                 text is passed to fprintf as its format
%       EXPECTED: the whole compilation command printed, without a warning
%       LINES: 141-143
%     - DEFECT: the CPLEX root stays on the MATLAB path when the function stops with an error
%       SEVERITY: cosmetic
%       TRIGGER: any call that ends with the errors of lines 89 or 102 (the error sections described above)
%       OBSERVED: MATLAB 2026-11-13: rootPathCPLEX, added to the path at line 66, is still on
%                 the path after the error; the path saved at line 63 is restored only at
%                 lines 163 and 173
%       EXPECTED: the MATLAB path unchanged after the error
%       LINES: 63-66, 89, 102
%     - DEFECT: the version flag and the compiler options are never passed to mex
%       SEVERITY: wrong-result
%       TRIGGER: generateMexFastFVA(root, 0) with a complete CPLEX installation (include and
%                library folders and libcplex.a), any CPLEX version
%       OBSERVED: MATLAB R2025a 2026-11-17 (mex replaced by a stand-in that records its
%                 arguments): the compilation call receives the eight arguments -output,
%                 cplexFVA128, -largeArrayDims, -ldl, CFLAGS="\$CFLAGS", -I"<include>",
%                 "<source>", <library>; the variable CFLAGS of line 138 (with -DHIGHER_THAN_128
%                 or -DLOWER_THAN_128, -O3, -Werror, ...) is never used, because line 139
%                 writes the literal text \$CFLAGS. cplexFVA.c is therefore compiled with
%                 neither version macro, which leaves out its CPLEX log-file code (lines
%                 1140-1153 of cplexFVA.c), so the MEX file writes no CPLEX log file (inferred
%                 from the C source; nothing compiled here, CPLEX is not installed)
%       EXPECTED: mex called with the flags of line 138 (CFLAGS="$CFLAGS <flags>"), so that the
%                 version switch of lines 79-86 takes effect
%       LINES: 79-86, 138-139
%     - DEFECT: CPLEX 12.10 and later 12.1x versions are classed as older than 12.8
%       SEVERITY: limitation
%       TRIGGER: generateMexFastFVA(root, 0) with ILOG_CPLEX_PATH and root under
%                .../CPLEX_Studio1210/cplex (version string 1210)
%       OBSERVED: MATLAB R2025a 2026-11-17: lines 54-56 turn 1210 into 121, which is below 128,
%                 so versionFlag is -DLOWER_THAN_128 and versionVS is vs2013 (lines 80-86).
%                 On Linux and macOS this changes nothing (stand-in mex: the command is that of
%                 12.8 apart from the output name cplexFVA1210) because the flag never reaches
%                 mex (defect above); on Windows the library is looked for in
%                 lib\x64_windows_vs2013\stat_mda (line 97; read from the code, not run)
%       EXPECTED: 12.10 classed as 12.8 or later (-DHIGHER_THAN_128 and the library folder of
%                 that CPLEX release)
%       LINES: 54-56, 80-86, 97
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.
%     - Quarantined after the independent review (T021), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateMexFastFVA'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
