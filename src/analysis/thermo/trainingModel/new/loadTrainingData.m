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
    if strcmp('TECRDB_4403',strtrim(['TECRDB_' int2str(res{15}(inds(i)))]))
        pause(0.1);
    end
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
    %production of h20 in certain redox reactions
    if any(strcmp(rxns{i},{'REDOX_dimethyl_sulfoxide';'REDOX_Trimethylamine'}))
        S(cids==1,i)=1;
    end
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
    trainingModel.ub=ones(size(trainingModel.S,2),1)*inf;
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

%remove some problematic entries
boolRemove=false(size(trainingModel.rxns,1),1);

%http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=66DED_421	C00089 + C06215 = C00031 + C06215	sucrose(aq) + (2,6--D-fructosyl)n(aq) = D-glucose(aq) + (2,6--D-fructosyl)n+1(aq)
%C06215 present on both sides of the reaction
%Need proper ID's for (2,6--D-fructosyl)n(aq) and (2,6--D-fructosyl)n+1(aq)
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_695');

% http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=93AND/BUL_1509	93AND/BUL	radioactivity	B	2.3.1.129	UDP-N-acetylglucosamine acyltransferase	C04688 + C00043 = C03688 + C04738	(R)-3-hydroxytetradecanoyl-[acyl-carrier-protein](aq) + UDP-N-acetyl-D-glucosamine(aq) = acyl-carrier-protein(aq) + UDP-3-O-(3-hydroxytetradecanoyl)-N-acetyl-D-glucosamine(aq)		0.007	296.15		7.4		2905
% http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=93AND/BUL_1509	93AND/BUL	radioactivity	B	2.3.1.129	UDP-N-acetylglucosamine acyltransferase	C04688 + C00043 = C03688 + C04738	(R)-3-hydroxytetradecanoyl-[acyl-carrier-protein](aq) + UDP-N-acetyl-D-glucosamine(aq) = acyl-carrier-protein(aq) + UDP-3-O-(3-hydroxytetradecanoyl)-N-acetyl-D-glucosamine(aq)		0.004	296.15		8.5		2906
% http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=93AND/BUL_1509	93AND/BUL	radioactivity	B	2.3.1.129	UDP-N-acetylglucosamine acyltransferase	C04688 + C00043 = C03688 + C04738	(R)-3-hydroxytetradecanoyl-[acyl-carrier-protein](aq) + UDP-N-acetyl-D-glucosamine(aq) = acyl-carrier-protein(aq) + UDP-3-O-(3-hydroxytetradecanoyl)-N-acetyl-D-glucosamine(aq)		0.002	296.15		9		2907
% http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=93AND/BUL_1509	93AND/BUL	radioactivity	B	2.3.1.129	UDP-N-acetylglucosamine acyltransferase	C04688 + C00043 = C03688 + C04738	(R)-3-hydroxytetradecanoyl-[acyl-carrier-protein](aq) + UDP-N-acetyl-D-glucosamine(aq) = acyl-carrier-protein(aq) + UDP-3-O-(3-hydroxytetradecanoyl)-N-acetyl-D-glucosamine(aq)		0.0095	296.15		8		2908
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_2905');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_2906');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_2907');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_2908');

%These were missing water on the rhs, fixed in TECRDB.tsv
%TECRDB_4540 85LIE		A	4.3.-.-	formaldehyde condensation with THF	C00101 + C00067 = C00143 + C00001	THF(aq) + formaldehyde(aq) = 5,10-CH2-THF(aq) + H2O(l)		30000	311.15	0.25	7		4540
%TECRDB_4541 +66KAL/JEN		E	4.3.-.-	formaldehyde condensation with THF	C00101 + C00067 = C00143 + C00001	THF(aq) + formaldehyde(aq) = 5,10-CH2-THF(aq) + H2O(l)		32000	298.15	1	7		4541
%TECRDB_4544 +59BLA		E	4.3.-.-	formaldehyde condensation with THF	C00101 + C00067 = C00143 + C00001	THF(aq) + formaldehyde(aq) = 5,10-CH2-THF(aq)		7700	293.15		7.2		4544

%The record of 85LIE is problematic i.e. TECRDB_870 - TECRDB_884
%e.g. http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=85LIE_292	85LIE	spectrophotometry and enzymatic assay	A	1.4.4.2	glycine dehydrogenase (decarboxylating)	C00037 + C00725 = C80069 + C00288	glycine(aq) + lipoate(aq) = S-aminomethyldihydro--lipoate(aq) + carbon dioxide(aq)		0.031	311.15		6.39		870
%is C00725 really C00248 ???
%C80069 is InChI=1S/C9H19NO2S2/c10-7-14-6-5-8(13)3-1-2-4-9(11)12/h8,13H,1-7,10H2,(H,11,12)
%C80069	but is it  InChI=1S/C9H20N2OS2/c10-7-14-6-5-8(13)3-1-2-4-9(11)12/h8,13H,1-7,10H2,(H2,11,12)/p+1  ???
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_870');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_871');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_872');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_873');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_874');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_875');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_876');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_877');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_878');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_879');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_880');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_881');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_882');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_883');
boolRemove = boolRemove | ismember(trainingModel.rxns,'TECRDB_884');
% The overall reaction reported in the abstract of the dissertation (https://digitalcommons.library.tmc.edu/dissertations/AAI8516325/) is as follows:
%85LIE		A	1.1.-.-	glycine cleavage system (a series of enzymes)	C00037 + C00003 + C00101 = C00143 + C00004 + C00014 + C00011 	glycine(aq) + NAD+(aq) + THF(aq) = 5,10-CH2-THF(aq) + NADH(aq) + NH3(aq) + CO2(aq)		0.00156	311.15	0.25	7		4539

%http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=65STR_520	65STR	spectrophotometry	C	2.6.1.13	ornithine-oxo-acid transaminase	C00077 + C00026 = C03912 + C00025	L-ornithine(aq) + 2-oxoglutarate(aq) = DL-D-1-pyrroline-5-carboxylate(aq) + L-glutamate(aq)		71	310.15		7.1		2719
%is http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=65STR_520	65STR	spectrophotometry	C	2.6.1.13	ornithine-oxo-acid transaminase	C00077 + C00026 = C01165 + C00025 + C00001	L-ornithine(aq) + 2-oxoglutarate(aq) = DL-D-1-pyrroline-5-carboxylate(aq) + L-glutamate(aq)		71	310.15		7.1		2719
%i.e. C00001 added to rhs, it is balanced, but is this correct?

%85LIE		A	1.1.-.-	glycine cleavage system	C00037 + C00003 + C00101 = C00143 + C00004 + C00014 + C00288 	glycine(aq) + NAD+(aq) + THF(aq) = 5,10-CH2-THF(aq) + NADH(aq) + NH3(aq) + CO2(aq)		0.00156	311.15	0.25	7		4539
%is 85LIE		A	1.1.-.-	glycine cleavage system	C00037 + C00003 + C00101 = C00143 + C00004 + C00014 + C00011 	glycine(aq) + NAD+(aq) + THF(aq) = 5,10-CH2-THF(aq) + NADH(aq) + NH3(aq) + CO2(aq)		0.00156	311.15	0.25	7		4539
%i.e. C00288 replaced by C00011

%http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=07LIN/ALG_1584	07LIN/ALG	spectrophotometry	A	1.1.1.87	homoisocitrate dehydrogenase	 C05662 + C00003 = C00322 + C00288 + C00004	(1R,2S)-1-hydroxybutane-1,2,4-tricarboxylate(aq) + NAD(ox) = 2-oxoadipate(aq) + carbon dioxide(aq) + NAD(red)		0.45	298.15		7.5		1
%is http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=07LIN/ALG_1584	07LIN/ALG	spectrophotometry	A	1.1.1.87	homoisocitrate dehydrogenase	C00001 + C05662 + C00003 = C00322 + C00288 + C00004	H2O(l) + (1R,2S)-1-hydroxybutane-1,2,4-tricarboxylate(aq) + NAD(ox) = 2-oxoadipate(aq) + carbon dioxide(aq) + NAD(red)		0.45	298.15		7.5		1
%i.e. lhs missing h20

%http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=95PEL/MAC_1595	95PEL/MAC	spectrophotometry and enzymatic assay	B	1.5.1.5	methylenetetrahydrofolate dehydrogenase (NADP+)	C00143 + C00006 = C00234 + C00005	5,10-methylenetetrahydrofolate(aq) + NADP(ox)(aq) = 10-formyltetrahydrofolate(aq) + NADP(red)(aq)		16	303.15		7.3		267
%is http://xpdb.nist.gov/enzyme_thermodynamics/enzyme_data1.pl?col=1.&T1=95PEL/MAC_1595	95PEL/MAC	spectrophotometry and enzymatic assay	B	1.5.1.5	methylenetetrahydrofolate dehydrogenase (NADP+)	C00001 + C00143 + C00006 = C00234 + C00005	H2O(l) + 5,10-methylenetetrahydrofolate(aq) + NADP(ox)(aq) = 10-formyltetrahydrofolate(aq) + NADP(red)(aq)		16	303.15		7.3		267
%i.e. lhs missing h20

%remove some of the training reactions that are problematic, e.g. those involving ACP
trainingModel.S = trainingModel.S(:,~boolRemove);
trainingModel.lb = trainingModel.lb(~boolRemove);
trainingModel.ub = trainingModel.ub(~boolRemove);
trainingModel.rxns = trainingModel.rxns(~boolRemove);
trainingModel.dG0_prime = trainingModel.dG0_prime(~boolRemove);
trainingModel.T = trainingModel.T(~boolRemove);
trainingModel.I = trainingModel.I(~boolRemove);
trainingModel.pH = trainingModel.pH(~boolRemove);
trainingModel.pMg = trainingModel.pMg(~boolRemove);
trainingModel.weights = trainingModel.weights(~boolRemove);
trainingModel.balance = trainingModel.balance(~boolRemove);
