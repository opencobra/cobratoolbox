function [model,noInchiBool,compositeInchiBool] = addInchiToModel(model, molFileDir, metKEGGID, printLevel)
% Assigns Inchi to model.inchi structure given external data
%
% USAGE:
%
%    model = assignInchiToModel(model, molFileDir, metKEGGID, printLevel)
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
%                   Not required if metKEGGID are specified.
%
% OPTIONAL INPUTS:
%    metKEGGID:           `m x 1` cell array of KEGG Compound identifiers.
%                   Not required if molfiledir is specified.
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
% Written output - MetStructures.sdf - An SDF containing all structures input to the
% component contribution method for estimation of standard Gibbs energies.           

if ~exist('metKEGGID','var')
    metKEGGID = [];
end
if ~exist('printLevel','var')
    printLevel = 1;
end

if isempty(metKEGGID)
    % Get metabolite structures in molfileDir.
    if printLevel>0
        fprintf('Creating MetStructures.sdf from molfiles.\n')
    end
    sdfFileName = 'MetStructures.sdf';
    includeRs = 0; % Do not include structures with R groups in SDF
    [sdfMetList,noMolMetList] = mol2sdf(model.mets,molFileDir,sdfFileName,includeRs);
else
    % Retreive molfiles from KEGG if KEGG ID are given.
    molFileDir = 'molfilesFromKegg';
    fprintf('\nRetreiving molfiles from KEGG.\n');
    takeMajorMS = true; % Convert molfile from KEGG to major tautomer of major microspecies at pH 7
    pH = 7;
    takeMajorTaut = true;
    kegg2mol(metKEGGID,molFileDir,model.mets,takeMajorMS,pH,takeMajorTaut); % Retreive mol files
end

if printLevel>0
    fprintf('Converting SDF to InChI strings.\n')
end

model.inchi = createInChIStruct(model.mets,sdfFileName);

% Remove InChI for composite compounds as they cause problems later.
compositeInchiBool = ~cellfun('isempty',regexp(model.inchi.nonstandard,'\.'));
model.inchi.standard(compositeInchiBool) = cell(sum(compositeInchiBool),1);
model.inchi.standardWithStereo(compositeInchiBool) = cell(sum(compositeInchiBool),1);
model.inchi.standardWithStereoAndCharge(compositeInchiBool) = cell(sum(compositeInchiBool),1);
model.inchi.nonstandard(compositeInchiBool) = cell(sum(compositeInchiBool),1);

noInchiBool = cellfun('isempty',model.inchi.nonstandard);

if printLevel>0
    fprintf('%u%s\n',length(model.mets),' = number of model metabolites')
    fprintf('%u%s\n',nnz(~noInchiBool),' = number of model metabolites with nonstandard inchi')
    fprintf('%u%s\n',nnz(noInchiBool),' = number of model metabolites without nonstandard inchi')
    fprintf('%u%s\n',nnz(compositeInchiBool),' = number of model metabolites compositie inchi removed')
end
