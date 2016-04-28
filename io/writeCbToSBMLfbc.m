function writeCbToSBMLfbc(model,fileName)
%
% Write a COBRA model to a SBML with FBC file
%
%INPUTS
% model         COBRA model structure fileName      
%
% Longfei Mao 25/09/2015
%
if nargin<2;
    fileName='sbmlModel' % If no file name is provided, a default name 'sbmlModel' is used.
end

modelSBML=convertCobraToSBML(model,3,1,[],[],[],'true');
try
    convertCobra2Fbc2(modelSBML,fileName); % Correct any discrepancies and ensure all FBC-related information are to be written to the SBML file.  
catch
    disp('conversion to SBML3+fbc2 failed, falling back to SBML2');
    writeCbToSBML(model,fileName);
end

