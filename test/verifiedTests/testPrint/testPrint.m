% The COBRAToolbox: testPrint.m
%
% Purpose:
%     - testPrint tests the functionality of print functions
%       in /src/print and compares it to expected data.
%
% Authors:
%     - Lemmer El Assal March 2017
%

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testPrint']);

load('ecoli_core_model', 'model');


% diary('testPrint.txt');
% minInf = -Inf;
% maxInf = +Inf;
% printConstraints(model, minInf, maxInf);
% diary off

% diary('printFluxVector_ref.txt');
% %printFluxVector(model,fluxData,nonZeroFlag,excFlag,sortCol,fileName,headerRow,formulaFlag);
% diary off

% % Test printRxnFormula
% delete('printRxnFormula.txt');
% diary('printRxnFormula.txt');
% formulas = printRxnFormula(model);
% diary off
% load printRxnFormula_ref.mat
% assert(isequal(formulas,formulas_ref));
% 
% text1 = fileread('printRxnFormula_ref.txt');
% text2 = fileread('printRxnFormula.txt');
% assert(isequal(text1,text2));


% % Test printUptakeBound
% delete('printUptakeBound.txt');
% diary('printUptakeBound.txt');
% ref_upInd = [23; 28; 31; 32; 35; 36; 37];
% upInd = printUptakeBound(model);
% diary off;
% assert(isequal(ref_upInd, upInd));
% text1 = fileread('printUptakeBound.txt');
% text2 = fileread('printUptakeBound_ref.txt');
% assert(isequal(text1,text2));


surfNet(model, metrxn, metNameFlag, flux, NonzeroFluxFlag, showMets, nCharBreak, iterOptions);





% change the directory
cd(CBTDIR)
