function model = addInchiToModel(model, molFileDir,  method, printLevel)
% Assign InChI to the `model.inchi` structure given a set of mol files for each metabolite
%
% USAGE:
%
%    model = addInchiToModel(model, molFileDir, method, printLevel)
%
% INPUTS:
%    model:         COBRA model structure with the field:
%
%                     * .mets - `m x 1` cell array of metabolite identifiers
%    molFileDir:    path to a directory containing molfiles for the major tautomer
%                   of the major microspecies of each metabolite at pH 7, named with
%                   the metabolite identifiers in `model.mets` (without compartment
%                   assignments)
%
% OPTIONAL INPUTS:
%    method:        'sdf' (default) to build InChI via an intermediate SDF, or 'mol'
%                   to read the molfiles directly
%    printLevel:    verbosity level (default 1)
%
% OUTPUT:
%    model:         the input model with the additional fields:
%
%                     * .inchi - structure of `m x 1` cell arrays of IUPAC InChI strings at varying levels of detail, with subfields `.standard`, `.standardWithStereo`, `.standardWithStereoAndCharge` and `.nonstandard`
%                     * .inchiBool - `m x 1` logical, true where an InChI exists
%                     * .molBool - `m x 1` logical, true where a mol file exists
%                     * .compositeInchiBool - `m x 1` logical, true where the InChI is composite
%
% NOTE:
%
%    When method is 'sdf', writes `MetStructures.sdf` containing all structures
%    passed to the component contribution method for standard Gibbs energy estimation.

if ~exist('printLevel','var')
    printLevel = 1;
end
if ~exist('method','var')
    method = 'sdf';
end


switch method
    case 'sdf'
        % Get metabolite structures in molfileDir.
        if printLevel>0
            fprintf('Creating MetStructures.sdf from molfiles.\n')
        end
        sdfFileName = 'MetStructures.sdf';
        includeRs = 0; % Do not include structures with R groups in SDF
        [sdfMetList,noMolMetList] = mol2sdf(model.mets,molFileDir,sdfFileName,includeRs);
        
        sdfBool = ismember(model.mets,sdfMetList);
        
        model.molBool = ~ismember(model.mets,noMolMetList);
        
        if printLevel>0
            fprintf('Converting SDF to InChI strings.\n')
        end
        model.inchi = createInChIStruct(model.mets,[molFileDir filesep sdfFileName]);
    case 'mol'
        %assumes that model.mets without compartment info provides the name of
        %the mol files in molFileDir
        [model.inchi,model.molBool] = createInChIStruct(model.mets,[],molFileDir);
    otherwise
        error('unrecognised method')
end

%identify the metabolites without inchi
model.inchiBool = ~cellfun('isempty',model.inchi.nonstandard);

% Remove InChI for composite compounds as they cause problems later.
model.compositeInchiBool = ~cellfun('isempty',regexp(model.inchi.nonstandard,'\.'));
model.inchi.standard(model.compositeInchiBool) = cell(sum(model.compositeInchiBool),1);
model.inchi.standardWithStereo(model.compositeInchiBool) = cell(sum(model.compositeInchiBool),1);
model.inchi.standardWithStereoAndCharge(model.compositeInchiBool) = cell(sum(model.compositeInchiBool),1);
model.inchi.nonstandard(model.compositeInchiBool) = cell(sum(model.compositeInchiBool),1);


if printLevel>0
    fprintf('%u%s\n',length(model.mets),' = number of model metabolites')
    fprintf('%u%s\n',nnz(model.molBool),' ... with mol files')
    fprintf('%u%s\n',nnz(~model.molBool),' ... without mol files')
    fprintf('%u%s\n',nnz(model.inchiBool),' ... with nonstandard inchi')
    fprintf('%u%s\n',nnz(~model.inchiBool),' ... without nonstandard inchi')
    fprintf('%u%s\n',nnz(model.compositeInchiBool),' ... compositie inchi removed')
end
