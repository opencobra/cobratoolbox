function model = configureSetupThermoModelInputs(model, T, compartments, ph, is, chi, concMinDefault, concMaxDefault, confidenceLevel)
% Configure inputs to `setupThermoModel` (set defaults etc.)
%
% All optional inputs are empty by default. Metabolite, reaction and
% compartment identifiers are normalised, missing compartment assignments are
% derived, temperature, compartment-specific pH/ionic-strength/electrical
% potential and metabolite concentration bounds are set, and a confidence
% level is assigned.
%
% USAGE:
%
%    model = configureSetupThermoModelInputs(model, T, compartments, ph, is, chi, concMinDefault, concMaxDefault, confidenceLevel)
%
% INPUT:
%    model:              COBRA model structure. Fields used or configured:
%
%                          * .S - `m x n` stoichiometric matrix
%                          * .mets - `m x 1` metabolite identifiers
%                          * .rxns - `n x 1` reaction identifiers
%                          * .metFormulas - `m x 1` metabolite formulas
%                          * .metCharges - `m x 1` metabolite charges
%                          * .metCompartments - `m x 1` compartment assignments
%                          * .compartments - `c x 1` compartment identifiers
%                          * .T - temperature in Kelvin
%                          * .ph - `c x 1` compartment specific pH values
%                          * .is - `c x 1` compartment specific ionic strengths
%                          * .chi - `c x 1` compartment specific electrical potentials
%                          * .concMin - `m x 1` lower bounds on metabolite concentrations
%                          * .concMax - `m x 1` upper bounds on metabolite concentrations
%                          * .confidenceLevel - confidence level for directionality assignment
%
% OPTIONAL INPUTS:
%    T:                  temperature in Kelvin (default: 298.15)
%    compartments:       `c x 1` array of compartment identifiers
%    ph:                 `c x 1` array of compartment specific pH values
%    is:                 `c x 1` array of compartment specific ionic strengths in mol/L
%    chi:                `c x 1` array of compartment specific electrical potentials in mV
%    concMinDefault:     default lower bound on metabolite concentrations in mol/L
%    concMaxDefault:     default upper bound on metabolite concentrations in mol/L
%    confidenceLevel:    confidence level for reaction directionality (default: 0.95)
%
% OUTPUT:
%    model:              the model structure with the fields above configured

if ~isfield(model,'metCompartments')
    model.metCompartments = [];
end
if ~exist('T','var')
    T = [];
end
if ~exist('compartments','var')
    compartments = [];
end
if ~exist('ph','var')
    ph = [];
end
if ~exist('is','var')
    is = [];
end
if ~exist('chi','var')
    chi = [];
end
if ~exist('concMin','var')
    concMin = [];
end
if ~exist('concMax','var')
    concMax = [];
end
if ~exist('confidenceLevel','var')
    confidenceLevel = [];
end

% Configure metabolite identifiers
model.mets = reshape(model.mets,length(model.mets),1);
if ischar(model.mets)
    model.mets = strtrim(cellstr(model.mets));
end
if isnumeric(model.mets)
    model.mets = strtrim(cellstr(num2str(model.mets)));
end

% Configure reaction identifiers
model.rxns = reshape(model.rxns,length(model.rxns),1);
if ischar(model.rxns)
    model.rxns = strtrim(cellstr(model.rxns));
end
if isnumeric(model.rxns)
    model.rxns = strtrim(cellstr(num2str(model.rxns)));
end

% Check required fields in model
if any(cellfun('isempty',model.metFormulas))
    error(['Formulas missing for metabolites:' sprintf('%s\n',model.mets{cellfun('isempty',model.metFormulas)}) 'Enter R in model.metFormulas for metabolites with unknown formulas. \n']);
end
if any(isnan(model.metCharges))
    error(['Charges missing for metabolites:' sprintf('%s\n',model.mets{isnan(model.metCharges)}) 'Set model.metCharges to 0 for metabolites with unknown charges. \n']);
end

% Check for model.metCompartments
if isempty(model.metCompartments)
    fprintf('\nField metCompartments is missing from model structure. Attempting to create it.\n')
    if ~any(cellfun('isempty',regexp(model.mets,'\[\w\]$')))
        model.metCompartments = getCompartment(model.mets);
        fprintf('Attempt to create field metCompartments successful.\n')
    else
        error('Could not create field metCompartments. Please do so manually.\n')
    end
end

model.metCompartments = reshape(model.metCompartments,length(model.metCompartments),1);
if ischar(model.metCompartments)
    model.metCompartments = strtrim(cellstr(model.metCompartments));
end
if isnumeric(model.metCompartments)
    model.metCompartments = strtrim(cellstr(num2str(model.metCompartments)));
end
if any(cellfun('isempty',model.metCompartments))
    error(['Compartment assignments missing for metabolites:\n' sprintf('%s\n',model.mets{cellfun('isempty',model.metCompartments)}) 'All metabolites must be assigned to a cell compartment.']);
end

% Configure temperature
if isempty(T)
    T = 298.15; % Default temperature in Kelvin
    fprintf('\nSetting temperature to %.2f K.\n',T);
end
if abs(T-298) > 0.15
    fprintf('\nWarning: Setting temperature to a value other than 298.15 K may introduce error, since enthalpies and heat capacities are not specified.\n');
end
model.T = T;

% Configure compartment specific parameters
if size(compartments,2) > size(compartments,1)
    compartments = compartments';
end
if ischar(compartments)
    compartments = strtrim(cellstr(compartments));
end
if isnumeric(compartments)
    compartments = strtrim(cellstr(num2str(compartments)));
end
compartments = compartments(~cellfun('isempty',compartments));

if size(ph,2) > size(ph,1)
    ph = ph';
end
if size(is,2) > size(is,1)
    is = is';
end
if size(chi,2) > size(chi,1)
    chi = chi';
end

nCompartments = length(compartments);
if length(ph) ~= nCompartments || length(is) ~= nCompartments || length(chi) ~= nCompartments
   error('The variables compartments, ph, is, and chi should have equal length.')
end

missingCompartments = setdiff(unique(model.metCompartments),compartments);
if ~isempty(missingCompartments)
    default_ph = 7; % Default pH
    default_is = 0; % Default ionic strength in mol/L
    default_chi = 0; % default electrical potential in mV

    fprintf(['\nph, is and chi not specified for compartments: ' regexprep(sprintf('%s, ',missingCompartments{:}),'(,\s)$','.') '\n']);
    fprintf('Setting ph = %.2f, is = %.2f M and chi = %.2f mV in these compartments.\n',default_ph,default_is,default_chi);

    compartments = [compartments; missingCompartments];
    ph = [ph; default_ph*ones(length(missingCompartments),1)];
    is = [is; default_is*ones(length(missingCompartments),1)];
    chi = [chi; default_chi*ones(length(missingCompartments),1)];
end

if any(ph < 4.7 | ph > 9.3)
   error(['pH in compartments: ' regexprep(sprintf('%s, ',compartments{ph < 4.7 | ph > 9.3}),'(,\s)$','.') ' out of applicable range (4.7 - 9.3).']);
end
if any(is < 0 | is > 0.35)
   error(['Ionic strength in compartments: ' regexprep(sprintf('%s, ',compartments{is < 0 | is > 0.35}),'(,\s)$','.') ' out of applicable range (0 - 0.35 M).']);
end

model.compartments = compartments;
model.ph = ph;
model.is = is;
model.chi = chi;

% Configure concentration bounds
if isfield(model,'concMin')
    model.concMin = reshape(model.concMin,size(model.S,1),1);
    if isempty(concMinDefault)
        error('concMinDefault must not be set if concentrations are provided')
    end
else
    concMinDefault = 1e-5;
    if isfield(model,'concMin')
        error('concMinDefault must not be set if model.concMin is already provided')
    else
        fprintf('Setting lower bound on metabolite concentrations to %.2e.\n',concMinDefault)
        model.concMin = concMinDefault*ones(size(model.mets)); % Default lower bound on metabolite concentrations in mol/L
    end
end

if isfield(model,'concMax')
    model.concMax = reshape(model.concMax,size(model.S,1),1);
    if isempty(concMaxDefault)
        error('concMaxDefault must not be set if concentrations are provided')
    end
else
    concMaxDefault = 1e-2;
    if isfield(model,'concMax')
        error('concMaxDefault must not be set if model.concMax is already provided')
    else
        fprintf('Setting upper bound on metabolite concentrations to %.2e.\n',concMaxDefault)
        model.concMax = concMaxDefault*ones(size(model.mets)); % Default lower bound on metabolite concentrations in mol/L
    end
end

hi = find(strcmp(model.metFormulas,'H')); % Indices of protons
for i = 1:length(hi)
   model.concMin(hi(i)) = 10^(-model.ph(strcmp(model.compartments,model.metCompartments{hi(i)}))); % Set concentrations of protons according to pH
   model.concMax(hi(i)) = 10^(-model.ph(strcmp(model.compartments,model.metCompartments{hi(i)})));
end

h2oi = find(strcmp(model.metFormulas,'H2O')); % Indices of water
model.concMin(h2oi) = 1; % Set concentration of water to 1 M
model.concMax(h2oi) = 1;

if any(~isfinite(log(model.concMin)))
        error('log(model.concMin) must be finite')
end
if any(~isfinite(log(model.concMax)))
        error('log(model.concMax) must be finite')
end

% Configure confidence level
if isempty(confidenceLevel)
    confidenceLevel = 0.95;
    fprintf('\nSetting confidence level to %.2f.\n',confidenceLevel);
end
model.confidenceLevel = confidenceLevel;

% %all possible compartments
% p=1;
% compartments{p,1}='c';
% compartments{p,2}='cytoplasm';
% p=p+1;
% compartments{p,1}='p';
% compartments{p,2}='periplasm';
% p=p+1;
% compartments{p,1}='e';
% compartments{p,2}='extracellular';
% p=p+1;
% compartments{p,1}='m';
% compartments{p,2}='mitochondria';
% p=p+1;
% compartments{p,1}='n';
% compartments{p,2}='nucleus';
% p=p+1;
% compartments{p,1}='r';
% compartments{p,2}='endoplasmic reticulum';
% p=p+1;
% compartments{p,1}='l';
% compartments{p,2}='lysosome';
% p=p+1;
% compartments{p,1}='x';
% compartments{p,2}='peroxisome';
% p=p+1;
% compartments{p,1}='i';
% compartments{p,2}='intermembrane space in mitochondria';
