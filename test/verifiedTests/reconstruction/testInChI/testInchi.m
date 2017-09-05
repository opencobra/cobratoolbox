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

%Test a InChi with fixed Hydrogens -> altering the q-Value
fixed_H_InChi = 'InChI=1/C60H101N22O15S/c1-33(2)27-40(77-50(88)37(12-6-21-69-59(64)65)74-55(93)44-15-9-24-81(44)56(94)38(13-7-22-70-60(66)67)75-48(86)35(62)17-18-46(63)84)51(89)79-42(31-83)53(91)78-41(28-34-29-68-32-72-34)52(90)73-36(11-4-5-20-61)49(87)71-30-47(85)80-23-8-14-43(80)54(92)76-39(19-26-98-3)57(95)82-25-10-16-45(82)58(96)97/h29,32-33,35-45H,4-28,30-31,61-62H2,1-3H3,(H2,63,84)(H,68,72)(H,71,87)(H,73,90)(H,74,93)(H,75,86)(H,76,92)(H,77,88)(H,78,91)(H,79,89)(H,96,97)(H4,64,65,69)(H4,66,67,70)/q-1/p+4/t35-,36-,37-,38+,39-,40+,41+,42-,43+,44+,45-/m1/s1/fC60H105N22O15S/h61-62,68-79H,63-67H2/q+3';
fixed_H_InChI_Formula = 'C60H105N22O15S';
fixed_H_InChI_Charge = -1;
fixed_H_InChI_Charge_With_Protons = 3;
[formula,protons,charge] = getFormulaAndChargeFromInChI(fixed_H_InChi);
chargeWithProtons = getChargeFromInChI(fixed_H_InChi);
assert(isequal(charge,fixed_H_InChI_Charge));
assert(isequal(formula,fixed_H_InChI_Formula));
assert(isequal(chargeWithProtons,fixed_H_InChI_Charge_With_Protons));


%Returning to original directory
cd(currentDir)
