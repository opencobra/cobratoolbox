% The COBRAToolbox: testInChi.m
%
% Purpose:
%     - tests the InChi Formula Extraction and Charge Extraction        
%
%
% Authors:
%     - Thomas Pfau
%Switching to test directory
currentDir = pwd;
cd(fileparts(which('testInchi.m')));

%Use ADP glucose as initial test
adp_alpha_d_glc = 'InChI=1S/C16H25N5O15P2/c17-13-7-14(19-3-18-13)21(4-20-7)15-11(26)9(24)6(33-15)2-32-37(28,29)36-38(30,31)35-16-12(27)10(25)8(23)5(1-22)34-16/h3-6,8-12,15-16,22-27H,1-2H2,(H,28,29)(H,30,31)(H2,17,18,19)/p-2/t5-,6-,8-,9-,10+,11-,12-,15-,16-/m1/s1 ';
adp_alpha_d_glc_formula = 'C16H23N5O15P2'; %This is fully protonated
inchicharge = getChargeFromInChI(adp_alpha_d_glc);
inchiForm = getFormulaFromInChI(adp_alpha_d_glc);


assert(isequal(adp_alpha_d_glc_formula,inchiForm));
assert(isequal(inchicharge,-2));

%Also test whether getFormulaAndChargeFromInChI works, this relies on the
%other functions.
[formula,protons,charge] = getFormulaAndChargeFromInChI(adp_alpha_d_glc);
assert(isequal(adp_alpha_d_glc_formula,formula));
assert(isequal(charge,0));
assert(isequal(protons,23));

pyruvate = 'InChI=1S/C3H4O3/c1-2(4)3(5)6/h1H3,(H,5,6)/p-1';
pyrForm = 'C3H3O3';
pyrCharge = -1;

inchicharge = getChargeFromInChI(pyruvate);
inchiForm = getFormulaFromInChI(pyruvate);

assert(isequal(inchicharge,pyrCharge));
assert(isequal(inchiForm,pyrForm));

%Test an inchi string with multiple parts. 
MultiPartInChI = 'InChI=1S/2C5H2.Fe/c2*1-2-4-5-3-1;/h2*1H2;/q2*-1;+2';

inchicharge = getChargeFromInChI(MultiPartInChI);
inchiForm = getFormulaFromInChI(MultiPartInChI);

assert(isequal(inchicharge,0));
assert(isequal(inchiForm,'C10H4Fe'));

%Returning to original directory
cd(currentDir)
