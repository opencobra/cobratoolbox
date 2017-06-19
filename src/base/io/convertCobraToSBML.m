function sbmlModel = convertCobraToSBML(model, sbmlLevel, sbmlVersion, compSymbolList, compNameList)
% Converts a cobra structure to an sbml structure - kept for backward Compatability
%
% USAGE:
%
%    sbmlModel = convertCobraToSBML(model, sbmlLevel, sbmlVersion, compSymbolList, compNameList)
%
% INPUT:
%    model:             COBRA model structure
%
% OPTIONAL INPUTS:
%    sbmlLevel:         SBML Level (ignored! level 3 is used)
%    sbmlVersion:       SBML Version (ignored! version 1 is used)
%    compSymbolList:    List of compartment symbols
%    compNameList:      List of copmartment names correspoding to `compSymbolList`
%
% OUTPUT:
%    sbmlModel:         SBML MATLAB structure
%
% .. Authors:
%    - Longfei Mao 24/09/15 FBCv2 support added
%    - Thomas Pfau 19/09/2016 reinstantiated for backward compatability
% NOTE:
%
%    sbmlLevel and sbmlVersion are ignored by this function and it is just
%    kept for backward compatability and might be deprecated in future
%    versions.

warning('This function is likely to be deprecated in future COBRA Toolbox version.')

TemporaryFileName = [tempname '.xml'];

if ~exist('compSymbolList','var') || ~exist('compNameList','var')
    sbmlModel = writeSBML(model,TemporaryFileName);
else
    sbmlModel = writeSBML(model,TemporaryFileName,compSymbolList,compNameList);
end

delete(TemporaryFileName)
