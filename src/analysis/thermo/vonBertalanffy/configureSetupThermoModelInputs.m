function model = configureSetupThermoModelInputs(model, T, compartments, ph, is, chi, concMinDefault, concMaxDefault, confidenceLevel)
% Configures inputs to `setupThermoModel` (sets defaults etc.). All optional inputs are empty by default.
%
% USAGE:
%
%    model = configureSetupThermoModelInputs(model, T, compartments, ph, is, chi, concMinDefault, concMaxDefault, confidenceLevel)
%
% INPUT:
%    model:
%
% OPTIONAL INPUTS:
%    T:
%    compartments:
%    ph:
%    is:
%    chi:
%    concMinDefault:
%    concMaxDefault:
%    confidenceLevel:
%
% OUTPUT:
%    model:

if ~isfield(model,'metCompartments')
    model.metComps = [];
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

% Check for model.metComps
if isempty(model.metComps)
    fprintf('\nField metCompartments is missing from model structure. Attempting to create it.\n')
    if ~any(cellfun('isempty',regexp(model.mets,'\[\w\]$')))
        model.metComps = getCompartment(model.mets);
        fprintf('Attempt to create field metCompartments successful.\n')
    else
        error('Could not create field metCompartments. Please do so manually.\n')
    end
end

model.metComps = reshape(model.metComps,length(model.metComps),1);
if ischar(model.metComps)
    model.metComps = strtrim(cellstr(model.metComps));
end
if isnumeric(model.metComps)
    model.metComps = strtrim(cellstr(num2str(model.metComps)));
end
if any(cellfun('isempty',model.metComps))
    error(['Compartment assignments missing for metabolites:\n' sprintf('%s\n',model.mets{cellfun('isempty',model.metComps)}) 'All metabolites must be assigned to a cell compartment.']);
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

missingCompartments = setdiff(unique(model.metComps),compartments);
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
   model.concMin(hi(i)) = 10^(-model.ph(strcmp(model.compartments,model.metComps{hi(i)}))); % Set concentrations of protons according to pH
   model.concMax(hi(i)) = 10^(-model.ph(strcmp(model.compartments,model.metComps{hi(i)})));
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
