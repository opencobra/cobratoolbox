function inchies = getInchies(target_cids, use_cache)
if nargin < 2
    use_cache = true;
end

fullpath = which('getInchies.m');
fullpath = regexprep(fullpath,'getInchies.m','');

KEGG_ADDITIONS_TSV_FNAME = [fullpath 'data' filesep 'kegg_additions.tsv'];
CACHED_KEGG_INCHI_MAT_FNAME = [fullpath 'cache' filesep 'kegg_inchies.mat'];

if ~exist(KEGG_ADDITIONS_TSV_FNAME, 'file')
    error(['file not found: ', KEGG_ADDITIONS_TSV_FNAME]);
end

if ismac
    babel_cmd = '/usr/local/bin/babel';
else
    babel_cmd = 'babel';
end

[success, ~] = system(babel_cmd);
if success ~= 0
    error('Please make sure the command line program "babel" is installed and in the path');
end

% Load relevant InChIs (for all compounds in the training data)
if exist(CACHED_KEGG_INCHI_MAT_FNAME, 'file') && use_cache
    fprintf('Loading the InChIs for the training data from: %s\n', CACHED_KEGG_INCHI_MAT_FNAME);
    load(CACHED_KEGG_INCHI_MAT_FNAME);
else
    inchies.cids = [];
end

if ~isempty(setdiff(target_cids, inchies.cids))
    % load the InChIs for all KEGG compounds in the 'kegg_additions.tsv' file.
    % this contains a few corrections needed in KEGG and added compounds (all starting with C80000)
    
    fprintf('Obtaining MOL files for the training data from KEGG and converting to InChI using OpenBabel\n');
    
    fid = fopen(KEGG_ADDITIONS_TSV_FNAME, 'r');
    fgetl(fid); % fields are: name, cid, inchi
    filecols = textscan(fid, '%s%d%s', 'delimiter','\t');
    fclose(fid);
    added_cids = filecols{2};
    added_inchis = filecols{3};

    inchies.cids = target_cids;
    inchies.std_inchi = cell(size(target_cids));
    inchies.std_inchi_stereo = cell(size(target_cids));
    inchies.std_inchi_stereo_charge = cell(size(target_cids));
    inchies.nstd_inchi = cell(size(target_cids));

    for i = 1:length(target_cids)
        cid = target_cids(i);
        
        if ismember(cid, added_cids)
            inchi = added_inchis{find(added_cids == cid)};
            if ispc
                cmd = ['echo ' inchi ' | ' babel_cmd ' -iinchi -oinchi ---errorlevel 0'];
            else
                cmd = ['echo "' inchi '" | ' babel_cmd ' -iinchi -oinchi ---errorlevel 0'];
            end
        else
            % Get the MOL for this compounds from KEGG
            [mol,status] = urlread(sprintf('http://rest.kegg.jp/get/cpd:C%05d/mol', cid));
            if isempty(mol)
                continue
            end
            
            if ispc
                cmd = ['echo ' mol ' | ' babel_cmd ' -imol -oinchi ---errorlevel 0'];
            else
                cmd = ['echo "' mol '" | ' babel_cmd ' -imol -oinchi ---errorlevel 0'];
            end
        end
        
        [success, std_inchi] = system([cmd ' -xT/noiso/nochg/nostereo']);
        if success == 0 && ~isempty(std_inchi) && strcmp('InChI=',std_inchi(1:6))
            std_inchi = strtok(std_inchi);
            inchies.std_inchi{i} = std_inchi;
        end
        [success, std_inchi_stereo] = system([cmd ' -xT/noiso/nochg']);
        if success == 0 && ~isempty(std_inchi_stereo) && strcmp('InChI=',std_inchi_stereo(1:6))
            std_inchi_stereo = strtok(std_inchi_stereo);
            inchies.std_inchi_stereo{i} = std_inchi_stereo;
        end
        [success, std_inchi_stereo_charge] = system([cmd ' -xT/noiso']);
        if success == 0 && ~isempty(std_inchi_stereo_charge) && strcmp('InChI=',std_inchi_stereo_charge(1:6))
            std_inchi_stereo_charge = strtok(std_inchi_stereo_charge);
            inchies.std_inchi_stereo_charge{i} = std_inchi_stereo_charge;
        end
        [success, nstd_inchi] = system([cmd ' -xFT/noiso']);
        if success == 0 && ~isempty(nstd_inchi) && strcmp('InChI=',nstd_inchi(1:6))
            nstd_inchi = strtok(nstd_inchi);
            inchies.nstd_inchi{i} = nstd_inchi;
        end
    end
    save(CACHED_KEGG_INCHI_MAT_FNAME, 'inchies', '-v7');
end
