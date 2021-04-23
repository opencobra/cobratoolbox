function trainingModel = loadTrainingData(param)
% Generates the structure that contains all the training data needed for
% Component Contribution.
%
% USAGE:
%
%    trainingModel = loadTrainingData(formation_weight)
%
% INPUT:
%    formation_weight:    the relative weight to give the formation energies (Alberty's data)
%                         compared to the reaction measurements (TECRDB)
%
% OUTPUT:
%    trainingModel:       structure with data for Component Contribution
%                         *.S   `m x n` stoichiometric matrix of training data
%                         *.cids: `m x 1` compound ids
%                         *.dG0_prime: `n x 1`
%                         *.T:  `n x 1`
%                         *.I:  `n x 1`
%                         *.pH:  `n x 1`
%                         *.pMg:  `n x 1`
%                         *.weights:  `n x 1`
%                         *.balance:  `n x 1`
%                         *.cids_that_dont_decompose: k x 1 ids of compounds that do not decompose

if ~exist('param','var')
    formation_weight = 1;
    use_cached_kegg_inchis=true;
    use_model_pKas_by_default=true;
else
    if ~isfield(param,'formation_weight')
        formation_weight = 1;
    end
    if ~isfield(params,'use_cached_kegg_inchis')
        use_cached_kegg_inchis = true;
        % use_cached_kegg_inchis = false;
    else
        use_cached_kegg_inchis=params.use_cached_kegg_inchis;
    end
    if ~isfield(params,'use_model_pKas_by_default')
        use_model_pKas_by_default = true;
    else
        use_model_pKas_by_default=params.use_model_pKas_by_default;
    end
end

TECRDB_TSV_FNAME = 'data/TECRDB.tsv';
FORMATION_TSV_FNAME = 'data/formation_energies_transformed.tsv';
REDOX_TSV_FNAME = 'data/redox.tsv';

WEIGHT_TECRDB = 1;
WEIGHT_FORMATION = formation_weight;
WEIGHT_REDOX = formation_weight;

R=8.31451;
%Energies are expressed in kJ mol^-1.*)
R=R/1000; % kJ/mol/K
%Faraday Constant (kJ/mol)
F=96.48; %kJ/mol

if ~exist(TECRDB_TSV_FNAME, 'file')
    error(['file not found: ', TECRDB_TSV_FNAME]);
end

if ~exist(FORMATION_TSV_FNAME, 'file')
    error(['file not found: ', FORMATION_TSV_FNAME]);
end

if ~exist(REDOX_TSV_FNAME, 'file')
    error(['file not found: ', REDOX_TSV_FNAME]);
end

% Read the raw data of TECRDB (NIST)
reactions = {};
rxns={};
cids = [];
cids_that_dont_decompose = [];
thermo_params = []; % columns are: dG'0, T, I, pH, pMg, weight, balance?


fid = fopen(TECRDB_TSV_FNAME, 'r');
% fields are: 
% 1. URL
% 2. REF_ID
% 3. METHOD
% 4. EVAL
% 5. EC
% 6. ENZYME NAME
% 7. REACTION IN KEGG IDS
% 8. REACTION IN COMPOUND NAMES
% 9. K
% 10. K'
% 11. T
% 12. I
% 13. pH
% 14. pMg
% 15. ID

res = textscan(fid, '%s%s%s%s%s%s%s%s%f%f%f%f%f%f%f', 'delimiter','\t');
fclose(fid);

inds = find(~isnan(res{10}) .* ~isnan(res{11}) .* ~isnan(res{13}));

dG0_prime = -R * res{11}(inds) .* log(res{10}(inds)); % calculate dG'0
thermo_params = [dG0_prime, res{11}(inds), res{12}(inds), res{13}(inds), ...
                 res{14}(inds), WEIGHT_TECRDB * ones(size(inds)), ...
                 true(size(inds))];

% parse the reactions in each row
for i = 1:length(inds)
    sprs = reaction2sparse(res{7}{inds(i)});
    cids = unique([cids, find(sprs)]);
    reactions = [reactions, {sprs}];
    rxns = [rxns;strtrim(['TECRDB_' int2str(res{15}(inds(i)))])];
end
fprintf('Successfully added %d values from TECRDB\n', length(inds));

% Read the Formation Energy data.
fid = fopen(FORMATION_TSV_FNAME, 'r');
fgetl(fid); % skip the first header line
% fields are: 
% 1. cid
% 2. name
% 3. dG'0
% 4. pH
% 5. I
% 6. pMg
% 7. T
% 8. decompose?
% 9. compound_ref
% 10. remark

res = textscan(fid, '%f%s%f%f%f%f%f%f%s%s', 'delimiter','\t');
fclose(fid);

inds = find(~isnan(res{3}));
thermo_params = [thermo_params; [res{3}(inds), res{7}(inds), res{5}(inds), ...
                                 res{4}(inds), res{6}(inds), ...
                                 WEIGHT_FORMATION * ones(size(inds)), ...
                                 false(size(inds))]];
                             
eval(['cid = {' regexprep(sprintf('''C%05d''; ',res{1}),'(;\s)$','') '};']);
for i = 1:length(inds)
    sprs = sparse([]);
    sprs(res{1}(inds(i))) = 1;
    reactions = [reactions, {sprs}];
    rxns = [rxns;['FORM_' cid{i}]];
end

cids = union(cids, res{1}');
cids_that_dont_decompose = res{1}(find(res{8} == 0));

fprintf('Successfully added %d formation energies\n', length(res{1}));


% Read the Reduction potential data.
fid = fopen(REDOX_TSV_FNAME, 'r');
fgetl(fid); % skip the first header line
% fields are: 
% 1. name
% 2. CID_ox
% 3. nH_ox
% 4. charge_ox
% 5. CID_red
% 6. nH_red,
% 7. charge_red
% 8. E'0
% 9. pH
% 10. I
% 11. pMg
% 12. T
% 13. ref
res = textscan(fid, '%s%f%f%f%f%f%f%f%f%f%f%f%s', 'delimiter', '\t');
fclose(fid);

delta_e = (res{6} - res{3}) - (res{7} - res{4}); % delta_nH - delta_charge
dG0_prime = -F * res{8} .* delta_e;
thermo_params = [thermo_params; [dG0_prime, res{12}, res{10}, res{9}, ...
                                 res{11}, ...
                                 WEIGHT_REDOX * ones(size(dG0_prime)), ...
                                 false(size(dG0_prime))]];

for i = 1:length(res{1})
    sprs = sparse([]);
    sprs(res{2}(i)) = -1;
    sprs(res{5}(i)) = 1;
    cids = unique([cids, res{2}(i), res{5}(i)]);
    reactions = [reactions, {sprs}];
    rxns = [rxns;['REDOX_' strrep(res{1}{i},' ','_')]];
end

fprintf('Successfully added %d redox potentials\n', length(res{1}));

% convert the list of reactions in sparse notation into a full
% stoichiometric matrix, where the rows (compounds) are according to the
% CID list 'cids'.
S = zeros(length(cids), length(reactions));
for i = 1:length(reactions)
    r = reactions{i};
    S(ismember(cids, find(r)), i) = r(r ~= 0);
end

trainingModel.S = sparse(S);

if ~isfield(trainingModel,'rxns')
    for i=1:size(trainingModel.S,2)
        trainingModel.rxns{i,1}=['rxn' int2str(i)];
    end
end
if ~isfield(trainingModel,'lb')
    trainingModel.lb=ones(size(trainingModel.S,2),1)*-inf;
end
if ~isfield(trainingModel,'ub')
    trainingModel.lb=ones(size(trainingModel.S,2),1)*inf;
end

trainingModel.rxns = rxns;
trainingModel.cids = cids';
trainingModel.dG0_prime = thermo_params(:, 1);
trainingModel.T = thermo_params(:, 2);
trainingModel.I = thermo_params(:, 3);
trainingModel.pH = thermo_params(:, 4);
trainingModel.pMg = thermo_params(:, 5);
trainingModel.weights = thermo_params(:, 6);
trainingModel.balance = thermo_params(:, 7);
trainingModel.cids_that_dont_decompose = cids_that_dont_decompose;



