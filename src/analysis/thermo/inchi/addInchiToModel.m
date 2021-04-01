function model = addInchiToModel(model, molFileDir,  method, printLevel)
% Assigns Inchi to model.inchi structure given set of mol files for each
% metabolite
%
% USAGE:
%
%    model = assignInchiToModel(model, molFileDir, printLevel)
%
% INPUT:
%    model          Model structure with following fields:
%
%                     * .S - `m x n` stoichiometric matrix.
%                     * .mets - `m x 1` array of metabolite identifiers.
%                     * .rxns - `n x 1` array of reaction identifiers.
%                     * .metFormulas - `m x 1` cell array of metabolite formulas. Formulas for
%                       protons should be H, and formulas for water should be H2O.
%                     * .metCharges - `m x 1` numerical array of metabolite charges.
%                     * .metCompartments - optional `m x 1` array of metabolite compartment
%                       assignments. Not required if metabolite
%                       identifiers are strings of the format `ID[*]`
%                       where * is the appropriate compartment identifier.
%
%    molFileDir:    Path to a directory containing molfiles for the
%                   major tautomer of the major microspecies of
%                   each metabolite at pH 7. Molfiles should be
%                   named with the metabolite identifiers in
%                   model.mets (without compartment assignments).
%
% OPTIONAL INPUTS:
%    printLevel:    Verbose level
%
% OUTPUTS:
%    model:          Model structure with following additional fields:
%
%                   * .inchi - Structure containing four `m x 1` cell array's of
%                     IUPAC InChI strings for metabolites, with varying
%                     levels of structural detail.
%
%                   * .inchi.standard: m x 1 cell array of standard inchi
%                   * .inchi.standardWithStereo: m x 1 cell array of standard inchi with stereo
%                   * .inchi.standardWithStereoAndCharge: m x 1 cell array of standard inchi with stereo and charge
%                   * .inchi.nonstandard: m x 1 cell array of non-standard inchi
%
%   inchiBool           m x 1 true if inchi exists
%   molBool             m x 1 true if mol file exists
%   compositeInchiBool  m x 1 true if inchi is composite


% Written output - MetStructures.sdf - An SDF containing all structures input to the
% component contribution method for estimation of standard Gibbs energies.           

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
