function [ newmodel ] = addMetabolite(model,metID,varargin)
% Adds a Metabolite to the Current Reconstruction
%
% USAGE:
%
%    newModel = addMetabolite(model, metID, metName, formula, ChEBIID, KEGGId, PubChemID, InChi, Charge, b)
%
% INPUTS:
%    model:         Cobra model structure
%    metID:         The ID(s) of the metabolite(s) (will be the identifier in model.mets)
%
% OPTIONAL INPUTS:
%    varargin:      Optional Inputs provided as 'ParameterName', Value
%                   pairs. the following parameternames are available:
%                   * metName:       Human readable name(s) (default metID, String)
%                   * metFormula:    The chemical formula(s) (default '', String)
%                   * ChEBIID:       The CHEBI Id(s) (default '', String)
%                   * KEGGId:        The KEGG Compound ID(s) (default '', String)
%                   * PubChemID:     The PubChemID(s) (default '', String)
%                   * InChi:         The InChi description(s) (default '', String)
%                   * Charge:        The Charge(s) (default NaN, int)
%                   * b:             The accumulation(s) or release(s) (default 0, double)
%                   * csense:        The sense of this metabolite (default 'E', char)
%                   * printLevel - 1  : normal output
%                                - 0  : Warnings Only
%                                - -1 : Nothing
% OUTPUT:
%    newModel:      COBRA model with added metabolite(s)
%
% EXAMPLES:
%    1) add a Metabolite which should be accumulated
%    model = addMetabolite(model,'MetToAcc','b',5);
%    2) Add a Metabolite with a given Formula and a given Charge
%    model = addMetabolite(model,'MetWithForm','metFormula','H3O','metCharge',1);
% .. Author: - Thomas Pfau 15/12/2014
%
% `metID` and all optional arguments either have to be a single value or cell
% arrays. `Charge` and `b` have to be double arrays.

optionalParameters = {'metName','metFormula','ChEBIID','KEGGId','PubChemID', 'InChi','Charge', 'b', 'csense','printLevel'};
oldOptionalOrder = {'metName','metformula','ChEBIID','KEGGId','PubChemID', 'InChi','Charge', 'b' };
if (numel(varargin) > 0 && ischar(varargin{1}) && ~any(ismember(varargin{1},optionalParameters)))
    %We have an old style thing....
    %Now, we need to check, whether this is a formula, or a complex setup
    %convert the input into the new format.
    tempargin = cell(0);
    for i = 1:numel(varargin)
        if~isempty(oldOptionalOrder(i))
            if ~isempty(varargin{i})
                tempargin{end+1} = optionalParameters{i};
                tempargin{end+1} = varargin{i};
            end
        end
    end
    varargin = tempargin;
end

% Figure out if reaction already exists
if ~iscell(metID)
    metID = {metID};
end
defaultMetName = metID;
defaultFormula = {''};
defaultCHEBI = {''};
defaultKEGG = {''};
defaultPubChem = {''};
defaultInChi = {''};
defaultCharge = NaN;
defaultb = 0;
defaultCsense = 'E';
defaultPrintLevel = 1;
if(iscell(metID))
    defaultFormula = repmat(defaultFormula,numel(metID),1);
    defaultCHEBI = repmat(defaultCHEBI,numel(metID),1);
    defaultKEGG = repmat(defaultKEGG,numel(metID),1);
    defaultPubChem = repmat(defaultPubChem,numel(metID),1);
    defaultInChi = repmat(defaultInChi,numel(metID),1);
    defaultCharge = repmat(defaultCharge,numel(metID),1);
    defaultb = repmat(defaultb,numel(metID),1);
    defaultCsense = repmat(defaultCsense,numel(metID),1);
end

parser = inputParser();
parser.addRequired('model',@isstruct) % we only check, whether its a struct, no details for speed
parser.addRequired('metID',@(x) iscell(x) || ischar(x))
parser.addParameter('metName',defaultMetName,@(x) ischar(x) || iscell(x) )
parser.addParameter('metFormula',defaultFormula, @(x) ischar(x) || iscell(x));
parser.addParameter('ChEBIID',defaultCHEBI, @(x) ischar(x) || iscell(x));
parser.addParameter('KEGGId',defaultKEGG, @(x) ischar(x) || iscell(x));
parser.addParameter('PubChemID',defaultPubChem, @(x) ischar(x) || iscell(x));
parser.addParameter('InChi',defaultInChi, @(x)  ischar(x) || iscell(x));
parser.addParameter('Charge',defaultCharge, @(x) isnumeric(x));
parser.addParameter('b',defaultb,@(x) isnumeric(x));
parser.addParameter('csense',defaultCsense, @(x) ischar(x));
parser.addParameter('printLevel',defaultPrintLevel, @(x) isnumeric(x));

parser.parse(model,metID,varargin{:});

printLevel = parser.Results.printLevel;
metName = parser.Results.metName;

if ~iscell(metName)
    metName = {metName};
end

formula = parser.Results.metFormula;
if ~iscell(formula)
    formula = {formula};
end

ChEBIID = parser.Results.ChEBIID;
if ~iscell(ChEBIID)
    ChEBIID = {ChEBIID};
end
KEGGId = parser.Results.KEGGId;
if ~iscell(KEGGId)
    KEGGId = {KEGGId};
end
PubChemID = parser.Results.PubChemID;
if ~iscell(PubChemID)
    PubChemID = {PubChemID};
end
InChi= parser.Results.InChi;
if ~iscell(InChi)
    InChi = {InChi};
end
Charge= parser.Results.Charge;
b= parser.Results.b;
csense= parser.Results.csense;


for i = 1:numel(metID)
    cmetID = metID{i};
    if ~any(ismember(model.mets,cmetID))
        %this needs an explicit 1:end as otherwise a zero size gets set to
        %1...
        model.S(end+1,1:end) = 0;
        model.mets{end+1,1} = cmetID;
        if ~isfield(model,'csense')
            model.csense = repmat('E',size(model.mets));
        else
            model.csense(end+1,1) = 'E';
        end


        if (isfield(model,'metNames'))      %Prompts to add missing info if desired
            cmetName = metName{i};
            if strcmp(cmetName,'')
                model.metNames{end+1,1} = regexprep(cmetID,'(\[.+\]) | (\(.+\))','') ;
                if printLevel >= 0
                    warning(['Metabolite name for ' metID{i} ' set to ' model.metNames{end}]);
                end
            else
                model.metNames{end+1,1} = metName{i} ;
            end
        else
            if ~isempty(metName{i}) && ~any(ismember(parser.UsingDefaults,'metName')) && ~all(cellfun(@isempty, metName))
                model.metNames = cell(numel(model.mets),1);
                model.metNames(:) = {''};
                model.metNames{end} = metName{i};
            end
        end
        if (isfield(model,'b'))      %Prompts to add missing info if desired
            model.b(end+1,1) = b(i,1);
        end
        if (isfield(model,'metFormulas'))
            model.metFormulas{end+1,1} = formula{i};
        else
            if ~isempty(formula{i}) && ~any(ismember(parser.UsingDefaults,'metFormula')) && ~all(cellfun(@isempty, formula))
                model.metFormulas = cell(numel(model.mets),1);
                model.metFormulas(:) = {''};
                model.metFormulas{end} = formula{i};
            end
        end
        if isfield(model,'metChEBIID')
            model.metChEBIID{end+1,1} = ChEBIID{i};
        else
            if ~isempty(ChEBIID{i}) && ~any(ismember(parser.UsingDefaults,'ChEBIID')) && ~all(cellfun(@isempty, ChEBIID))
                model.metChEBIID = cell(numel(model.mets),1);
                model.metChEBIID(:) = {''};
                model.metChEBIID{end} = ChEBIID{i};
            end
        end
        if isfield(model,'metKEGGID')
            model.metKEGGID{end+1,1} = KEGGId{i};
        else
            if ~isempty(KEGGId{i})  && ~any(ismember(parser.UsingDefaults,'KEGGId')) && ~all(cellfun(@isempty, KEGGId))
                model.metKEGGID = cell(numel(model.mets),1);
                model.metKEGGID(:) = {''};
                model.metKEGGID{end} = KEGGId{i};
            end
        end
        if isfield(model,'metPubChemID')
            model.metPubChemID{end+1,1} = PubChemID{i};
        else
            if ~isempty(PubChemID{i}) && ~any(ismember(parser.UsingDefaults,'PubChemID')) && ~all(cellfun(@isempty, PubChemID))
                model.metPubChemID = cell(numel(model.mets),1);
                model.metPubChemID(:) = {''};
                model.metPubChemID{end} = PubChemID{i};
            end
        end
        if isfield(model,'metInChIString')
            model.metInChIString{end+1,1} = InChi{i};
        else
            if ~isempty(InChi{i}) && ~any(ismember(parser.UsingDefaults,'InChi')) && ~all(cellfun(@isempty, InChi))
                model.metInChIString = cell(numel(model.mets),1);
                model.metInChIString(:) = {''};
                model.metInChIString{end} = InChi{i};
            end
        end
        if isfield(model,'metCharges')
            model.metCharges(end+1,1) = Charge(i);
        else
            %We only add the field, if the new metabolites contain actual
            %values for the charges.
            if ~isempty(Charge(i)) && ~any(ismember(parser.UsingDefaults,'Charge')) && ~all(isnan(Charge))
                model.metCharges = NaN(numel(model.mets),1);
                model.metCharges(end) = Charge(i);
            end
        end
    end
end

newmodel = extendModelFieldsForType(model,'mets');

end
