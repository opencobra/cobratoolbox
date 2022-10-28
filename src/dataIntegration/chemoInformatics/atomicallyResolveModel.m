function [modelOut,arm, diary] = atomicallyResolveModel(model,param)
% 1. Takes a standard COBRA model as input, annotates the metabolites with information on metabolite identifers (e.g. InChIKey) and then metabolite
% compares the identifiers and saves the most consistent identifiers in MDL MOL format, representing the structure of each metabolite, as well as 
% the InChI, SMILES and images of each metabolite structure also (if ChemAxon cxcalc and openBabel are installed). 
%
% 2. The MDL MOL files serve as the basis for creating the MDL RXN files that represent each metabolic reaction, if there is a MDL MOL file for each 
% metabolite in a metabolic reaction. If JAVA is installed, it also atom maps each metabolic reactions with ReactionDecoder Tool and returns an 
% MDL RXN file representing the atom mapping of each reaction. 
%
% 3. If atom mappings have been generated, it builds a matlab digraph object representing an atom transition multigraph corresponding to the 
% metabolic network (metabolic reaction hypergraph) from reaction stoichiometry and atom mappings.
%
% The multigraph nature is due to possible duplicate atom transitions, where the same pair of atoms are involved in the same atom transition in
% different reactions.
%
% The directed nature is due to possible duplicate atom transitions, where the same pair of atoms are involved in atom transitions of opposite
% orientation, corresponding to reactions in different directions.
%
% Note that A = incidence(dATM) returns a  `a` x `t` atom transition directed multigraph incidence matrix where `a` is the number of atoms and 
% `t` is the number of directed atom transitions. Each atom transition inherits the orientation of its corresponding reaction.
%
% A stoichimetric matrix may be decomposed into a set of atom transitions with the following atomic decomposition: 
%
%  N=\left(VV^{T}\right)^{-1}VAE
%
% VV^{T} is a diagonal matrix, where each diagonal entry is the number of atoms in each metabolite, so V*V^{T}*N = V*A*E
% 
% With respect to the input, N is the subset of model.S corresponding to atom mapped reactions
%
% With respect to the output V := M2Ai 
%                            E := Ti2R
%                            A := incidence(dATM);
% so we have the atomic decomposition M2Ai*M2Ai'*N = M2Ai*A*Ti2R
%
% INPUTS:
%    model:	COBRA model with following fields:
%           * .S - The m x n stoichiometric matrix for the metabolic network.
%           * .rxns - An n x 1 array of reaction identifiers.
%           * .mets - An m x 1 array of metabolite identifiers.
%
% OPTIONAL INPUTS:
%    model:	COBRA model with following fields:
%           * .metFormulas - An m x 1 array of metabolite chemical formulas.
%           * .metinchi - An m x 1 array of metabolite identifiers.
%           * .metsmiles - An m x 1 array of metabolite identifiers.
%           * .metKEGG - An m x 1 array of metabolite identifiers.
%           * .metHMDB - An m x 1 array of metabolite identifiers.
%           * .metPubChem - An m x 1 array of metabolite identifiers.
%           * .metCHEBI - An m x 1 array of metabolite identifiers.
%
%    param:  A structure containing all the arguments for the function:
% 
%           * .printlevel: Verbose level
%           * .metaboliteMappingFileName:
%           * .resultsDir: directory where the results should be saved (default: current directory)
%                          resultsDir/atomMapping containing the RXN files with atom mappings   
% replace:       If the new ID should replace an existing ID, this
%                   logical value indicates so (default: false).

%           * .standardisationApproach: String containing the type of standardisation
%                   for the molecules (default: 'explicitH' if openBabel is 
%                   installed, otherwise default: 'basic'):
%                    'explicitH' Normal chemical graphs;
%                    'implicitH' Hydrogen suppressed chemical graph;
%                    'basic' Update the header.
%           * .keepMolComparison: Logic value for comparing MDL MOL files from various sources (default: FALSE)
%           * .onlyUnmapped: Logic value to select create only unmapped MDL RXN files (default: FALSE).
%           * .adjustToModelpH: Logic value used to determine whether a molecule's pH must be adjusted in accordance with the COBRA model. If TRUE, requires MarvinSuite).
%           * .dirsToCompare: Cell(s) with the path to directory to an  existing database (default: empty).
%           * .dirNames: Cell(s) with the name of the directory(ies) (default: empty).
%           * .debug: Logical value used to determine whether or not the results  of different points in the function will be saved for debugging (default: empty).
%
% OUTPUTS:
% arm:      An atomically resolved model as a matlab structure with the following fields:
%
% arm.MRH:        Standard COBRA model (Directed Metabolic Hypergraph), with additional fields:
% arm.MRH.metAtomMappedBool:  `m x 1` boolean vector indicating atom mapped metabolites
% arm.MRH.rxnAtomMappedBool:  `n x 1` boolean vector indicating atom mapped reactions
% 
% arm.dATM:      Directed atom transition multigraph (dATM) obtained from buildAtomTransitionMultigraph.m
%
%    dATM:       Directed atom transition multigraph as a MATLAB digraph structure with the following tables:
%
%                   * .Nodes — Table of node information, with `p` rows, one for each atom.
%                   * .Nodes.Atom - unique alphanumeric id for each atom by concatenation of the metabolite, atom and element
%                   * .Nodes.AtomIndex - unique numeric id for each atom in atom transition multigraph
%                   * .Nodes.Met - metabolite containing each atom
%                   * .Nodes.AtomNumber - unique numeric id for each atom in an atom mapping
%                   * .Nodes.Element - atomic element of each atom
%                       
%                   * .EdgeTable — Table of edge information, with `q` rows, one for each atom transition instance.
%                   * .EdgeTable.EndNodes - two-column cell array of character vectors that defines the graph edges     
%                   * .EdgeTable.Trans - unique alphanumeric id for each atom transition instance by concatenation of the reaction, head and tail atoms
%                   * .EdgeTable.TansIndex - unique numeric id for each atom transition instance
%                   * .EdgeTable.Rxn - reaction corresponding to each atom transition
%                   * .EdgeTable.HeadAtomIndex - head Nodes.AtomIndex
%                   * .EdgeTable.TailAtomIndex - tail Nodes.AtomIndex
%
% arm.M2Ai:              `m` x `a` matrix mapping each mapped metabolite to one or more atoms in the directed atom transition multigraph
% arm.Ti2R:              `t` x `n` matrix mapping one or more directed atom transition instances to each mapped reaction
%
% The internal stoichiometric matrix may be decomposition into
%
% N = (M2Ai*M2Ai)^(-1)*M2Ai*Ti*Ti2R;
%
% where Ti = incidence(dATM), is incidence matrix of directed atom transition multigraph.
%
% newModel: A new model with the comparison and if onlyUnmapped = false, the informaton about the bonds broken and formed as well as the
%           bond enthalpies for each metabolic reaction. 
%
% diary:    A diary of the atomic resolution process
%

% .. Authors: - German Preciat, Ronan M. T. Fleming, 2022.

if ~exist('param','var')
    param = struct();
end

if ~isfield(param,'metaboliteMappingFileName')
    % Add external information in the model
    if contains(char(java.lang.System.getProperty('user.name')),'rfleming')
        param.metaboliteMappingFileName = ['~/work/sbgCloud/code/fork-cobratoolbox/test/verifiedTests/dataIntegration/testChemoInformatics/metaboliteIds.txt'];
    else
        param.metaboliteMappingFileName = ['~/work/code/fork-cobratoolbox/test/verifiedTests/dataIntegration/testChemoInformatics/metaboliteIds.xlsx'];
    end
end
if ~isfield(param,'resultsDir')
    param.resultsDir = pwd;
end
if ~isfolder(param.resultsDir)
    mkdir(param.resultsDir)
end
if ~isfield(param,'printlevel')
    param.printlevel = 0;
end
if ~isfield(param,'debug')
    param.debug = 0;
end
if ~isfield(param,'standardisationApproach')
    param.standardisationApproach = 'implicitH';
    %param.standardisationApproach = 'explicitH';
end
if ~isfield(param,'adjustToModelpH')
    param.adjustToModelpH = 0;
end
if ~isfield(param,'keepMolComparison')
    param.keepMolComparison = 0;
end
if ~isfield(param,'keepMolComparison')
    param.keepMolComparison = 0;
end
if ~isfield(param,'onlyUnmapped')
    param.onlyUnmapped = 0; %TODO change this
end
if ~isfield(param,'ctfDir')
    param.ctfDir = '~/work/sbgCloud/code/fork-ctf';
end
param.ctfRxnAtomMappedDir = [param.ctfDir '/rxns/atomMapped'];
param.ctfMetMolFileDir = [param.ctfDir '/mets/molFiles'];

% Add an additional directory to compare
param.dirsToCompare = param.ctfMetMolFileDir;
param.dirNames = {'VMH'};

% Directory to output atom mapping
param.outputDir = [param.resultsDir filesep 'atomMapping'];
if ~isfolder(param.outputDir)
    mkdir(param.outputDir)
end
cd(param.outputDir)

%If the new ID should replace an existing ID, this logical value indicates so (default: false).
if ~isfield(param,'replaceMetID')
    param.replaceMetID = 0;
end


%prepare the model
if isfield(model,'inchiBool')
    model = rmfield(model,'compositeInchiBool');
end
if isfield(model,'compositeInchiBool')
    model = rmfield(model, 'compositeInchiBool');
end

%%
% Integrates metabolite data from an external file and incorporates it into the COBRA model.
[model, hasEffect] = addMetInfoInCBmodel(model, param.metaboliteMappingFileName, param.replaceMetID);


%%
% This function uses the metabolite identifiers in the model to compare
% them and save the identifiers with the best score in MDL MOL format
% and/or inchi and simles and jpeg if it's installed cxcalc and openBabel.
% The obtained MDL MOL files will serve as the basis for creating the MDL
% RXN files that represent a metabolic reaction and can only be written if
% there is a MDL MOL file for each metabolite in a metabolic reaction.
% If JAVA is installed, it also atom maps the metabolic reactions
% with an MDL RXN file.
[diary, modelOut, arm] = generateChemicalDatabase(model, param);



end

