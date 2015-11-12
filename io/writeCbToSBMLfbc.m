function writeCbToSBMLfbc(model,fileName,fbc)
%
% Write a COBRA model to a SBML with FBC file
%
%INPUTS
% model         COBRA model structure fileName      
%
%OPTIONAL INPUT
%
% fileName      Name of xml file output
% fbc           'true' - strictly export the COBRA model strcuture into a
%               FBCv2 compliant format (Note: the COBRA model structure
%               should be produced from a FBCv2 file)
%               
%
% Longfei Mao 25/09/2015
%
if nargin<2;
    fileName='sbmlModel' % If no file name is provided, a default name 'sbmlModel' is used.
end
if nargin<3;
    fbc=''; % By default the format conversion is not run in the strict mode. 
end
modelSBML=convertCobraToSBML(model,3,1,[],[],[],'true');
if isfield(model,'fbc2str')||strcmp(fbc,'true');
    convertCobra2Fbc2(modelSBML,fileName); % Correct any discrepancies and ensure all FBC-related information are to be written to the SBML file.  
else
    OutputSBML(modelSBML, fileName);
end

