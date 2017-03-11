function sbmlModel = convertCobraToSBML(model,sbmlLevel,sbmlVersion,compSymbolList,compNameList)
%convertCobraToSBML converts a cobra structure to an sbml
%structure using the structures provided in the SBML toolbox 3.1.0
%
% sbmlModel = convertCobraToSBML(model,sbmlLevel,sbmlVersion,compSymbolList,compNameList)
%
%INPUTS
% model             COBRA model structure
%
%OPTIONAL INPUTS
% sbmlLevel         SBML Level (default = 2)
% sbmlVersion       SBML Version (default = 1)
% compSymbolList    List of compartment symbols
% compNameList      List of copmartment names correspoding to compSymbolList
% fbc               'true' - convert a COBRA model structure into a Matlab
%                   SBML FBCv2 format. The default parameter is 'false',
%                   which means FBCv2-supported format is not applied.
%
%OUTPUT
% sbmlModel         SBML MATLAB structure
%
%

%NOTE: The name mangling of reaction and metabolite ids is necessary
%for compliance with the SBML sID standard.
%
%NOTE: Sometimes the Model_create function doesn't listen to the
%sbmlVersion parameter, so it is essential that the items that
%are added to the sbmlModel are defined with the sbmlModel's level
%and version:  sbmlModel.SBML_level,sbmlModel.SBML_version
%
%NOTE:  Some of the structures are recycled to reduce to overhead for
%their creation.  There's a chance this can cause bugs in the future.
%
%NOTE: Currently, I don't add in the boundary metabolites.
%
%NOTE: Speed could probably be improved by directly adding structures to
%lists in a struct instead of using the SBML _addItem function, but this
%could break in future versions of the SBML toolbox.
%
%POTENTIAL FUTURE BUG: To speed things up, sbml structs have been
%recycled and are directly appended into lists instead of using _addItem


% modified by Longfei Mao 24/09/15   FBCv2 support added
% Reinstantiated for backward compatability by Thomas Pfau 19/09/2016

if ~exist('compSymbolList','var') 
	compSymbolList = [];
	compNameList = [];
end

if (~exist('sbmlLevel','var') || isempty(sbmlLevel))
    sbmlLevel = 2;
end
if (~exist('sbmlVersion','var') || isempty(sbmlVersion))
    sbmlVersion = 1;
end

TemporaryFileName = [tempname '.xml']
sbmlModel = writeCbModel(model,'sbml',TemporaryFileName,[],[],sbmlLevel,sbmlVersion);
delete(TemporaryFileName)
