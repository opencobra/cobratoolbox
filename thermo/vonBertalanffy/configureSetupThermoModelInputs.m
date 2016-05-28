function model = configureSetupThermoModelInputs(model,T,cellCompartments,ph,is,chi,xmin,xmax,confidenceLevel)
% Configures inputs to setupThermoModel (sets defaults etc.).
% INPUTS
%
% OUTPUTS
%

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
    error(['Formulas missing for metabolites:\n' sprintf('%s\n',model.mets{cellfun('isempty',model.metFormulas)}) 'Enter R in model.metFormulas for metabolites with unknown formulas.']);
end
if any(isnan(model.metCharges))
    error(['Charges missing for metabolites:\n' sprintf('%s\n',model.mets{isnan(model.metCharges)}) 'Set model.metCharges to 0 for metabolites with unknown charges.']);
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
if size(cellCompartments,2) > size(cellCompartments,1)
    cellCompartments = cellCompartments';
end
if ischar(cellCompartments)
    cellCompartments = strtrim(cellstr(cellCompartments));
end
if isnumeric(cellCompartments)
    cellCompartments = strtrim(cellstr(num2str(cellCompartments)));
end
cellCompartments = cellCompartments(~cellfun('isempty',cellCompartments));

if size(ph,2) > size(ph,1)
    ph = ph';
end
if size(is,2) > size(is,1)
    is = is';
end
if size(chi,2) > size(chi,1)
    chi = chi';
end

nCompartments = length(cellCompartments);
if length(ph) ~= nCompartments || length(is) ~= nCompartments || length(chi) ~= nCompartments
   error('The variables cellCompartments, ph, is, and chi should have equal length.') 
end

missingCompartments = setdiff(unique(model.metCompartments),cellCompartments);
if ~isempty(missingCompartments)
    default_ph = 7; % Default pH
    default_is = 0; % Default ionic strength in mol/L
    default_chi = 0; % default electrical potential in mV
    
    fprintf(['\nph, is and chi not specified for compartments: ' regexprep(sprintf('%s, ',missingCompartments{:}),'(,\s)$','.') '\n']);
    fprintf('Setting ph = %.2f, is = %.2f M and chi = %.2f mV in these compartments.\n',default_ph,default_is,default_chi);
    
    cellCompartments = [cellCompartments; missingCompartments];
    ph = [ph; default_ph*ones(length(missingCompartments),1)];
    is = [is; default_is*ones(length(missingCompartments),1)];
    chi = [chi; default_chi*ones(length(missingCompartments),1)];
end

if any(ph < 4.7 | ph > 9.3)
   error(['pH in compartments: ' regexprep(sprintf('%s, ',cellCompartments{ph < 4.7 | ph > 9.3}),'(,\s)$','.') ' out of applicable range (4.7 - 9.3).']); 
end
if any(is < 0 | is > 0.35)
   error(['Ionic strength in compartments: ' regexprep(sprintf('%s, ',cellCompartments{is < 0 | is > 0.35}),'(,\s)$','.') ' out of applicable range (0 - 0.35 M).']); 
end

model.cellCompartments = cellCompartments;
model.ph = ph;
model.is = is;
model.chi = chi;

% Configure concentration bounds
if isempty(xmin)
    defaultMin = 1e-5;
    fprintf('\nSetting lower bound on metabolite concentrations to %.2e.\n',defaultMin)
    xmin = defaultMin*ones(size(model.mets)); % Default lower bound on metabolite concentrations in mol/L
end
xmin = reshape(xmin,length(xmin),1);
model.xmin = xmin;

if isempty(xmax)
    defaultMax = 1e-2;
    fprintf('\nSetting upper bound on metabolite concentrations to %.2e.\n',defaultMax)
    xmax = defaultMax*ones(size(model.mets)); % Default upper bound on metabolite concentrations in mol/L
end
xmax = reshape(xmax,length(xmax),1);
model.xmax = xmax;

hi = find(strcmp(model.metFormulas,'H')); % Indices of protons
for i = 1:length(hi)
   model.xmin(hi(i)) = 10^(-model.ph(strcmp(model.cellCompartments,model.metCompartments{hi(i)}))); % Set concentrations of protons according to pH
   model.xmax(hi(i)) = 10^(-model.ph(strcmp(model.cellCompartments,model.metCompartments{hi(i)})));
end

h2oi = find(strcmp(model.metFormulas,'H2O')); % Indices of water
model.xmin(h2oi) = 1; % Set concentration of water to 1 M
model.xmax(h2oi) = 1;

% Configure confidence level
if isempty(confidenceLevel)
    confidenceLevel = 0.95;
    fprintf('\nSetting confidence level to %.2f.\n',confidenceLevel);
end
model.confidenceLevel = confidenceLevel;

