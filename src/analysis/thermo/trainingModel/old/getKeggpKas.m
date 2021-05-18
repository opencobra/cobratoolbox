function KeggSpeciespKa = getKeggpKas(target_cids, target_inchi, n_pkas)
if nargin < 3
    n_pkas = 20;
end

if ismac
    cxcalc_cmd = '/Applications/ChemAxon/JChem/bin/cxcalc';
    babel_cmd = '/usr/local/bin/babel';
else
    cxcalc_cmd = 'cxcalc';
    babel_cmd = 'babel';
end

[success, ~] = system(cxcalc_cmd);
if success ~= 0
    error('Please make sure the command line program "babel" is installed and in the path');
end

KeggSpeciespKa = [];

for i = 1:length(target_cids)
    cid = target_cids(i);    
    inchi = target_inchi{i};
    if isempty(inchi)
        continue
    end
    
    if ispc
        [success, smiles] = system(['echo ' inchi ' | ' babel_cmd ' -iinchi -osmi']);
    else
        [success, smiles] = system(['echo "' inchi '" | ' babel_cmd ' -iinchi -osmi']);
    end
    
    if success == 0
       smiles = strtok(smiles);
       structure = smiles;
    else
        structure = inchi;
    end
        
    fprintf('Using cxcalc on C%05d: %s\n', cid, structure);

    if ispc
        cmd = [cxcalc_cmd ' "' structure '" pka -a ' num2str(n_pkas) ' -b ' num2str(n_pkas) ' majorms -M true --pH 7'];
    else
        cmd = ['echo "' structure '" | ' cxcalc_cmd ' pka -a ' num2str(n_pkas) ' -b ' num2str(n_pkas) ' majorms -M true --pH 7'];
    end
    [success, cxcalc_stdout] = system(cmd);
    
    if ~isempty(strfind(cxcalc_stdout,'Inconsistent molecular structure'))
       success = -1; 
    end
    
    if success == 0
        %fprintf(cxcalc_stdout);
        pkalist = regexp(cxcalc_stdout,'\n','split');
        titles = regexp(pkalist{1,1}, '\t', 'split');
        vals = regexp(pkalist{1,2}, '\t', 'split');
        if all(cellfun(@isempty,vals(2:end)))
           vals = cell(1,2*n_pkas + 3);
        end

        inds = zeros(2*n_pkas, 1);
        for i = 1:n_pkas
            inds(2*i-1, 1) = find(strcmp(titles, ['apKa' num2str(i)]));
            inds(2*i, 1) = find(strcmp(titles, ['bpKa' num2str(i)]));
        end

        pkalist = vals(1, inds);
        pkalist = regexprep(pkalist, ',', '\.');
        pkalist = str2double(pkalist);
        pkalist = sort(pkalist,'descend');
        pkalist = pkalist(pkalist>=0 & pkalist<=14);

        % find the nH and charge of the major macrospecies
        ind = find(strcmp(titles, 'major-ms'));
        majorms_smiles = vals{1, ind};
        if isempty(majorms_smiles)
            majorms_smiles = smiles;
        end

        if ispc
            cmd = ['echo ' majorms_smiles ' | babel -ismiles -oinchi ---errorlevel 0 -xFT/noiso'];
        else
            cmd = ['echo "' majorms_smiles '" | babel -ismiles -oinchi ---errorlevel 0 -xFT/noiso'];
        end        
        [success, babel_stdout] = system(cmd);
        if success == 0 && ~isempty(babel_stdout) && strcmp('InChI=',babel_stdout(1:6))
            majorms_nstd_inchi = strtok(babel_stdout);
            [~, nH, charge] = getFormulaAndChargeFromInChI(majorms_nstd_inchi);
        else
            nH = 0;
            charge = 0;
        end
        
        idx = length(KeggSpeciespKa) + 1;
        if ~isempty(pkalist)
            pkas = zeros(length(pkalist)+1,length(pkalist)+1);
            pkas(2:end,1:end-1) = diag(pkalist);
            pkas = pkas + pkas';
            KeggSpeciespKa(idx).pKas = pkas;

            mmsbool = false(size(pkas,1),1);
            if any(pkalist <= 7)
                mmsbool(find(pkalist <= 7,1)) = true;
            else
                mmsbool(end) = true;
            end
            KeggSpeciespKa(idx).majorMSpH7 = mmsbool;                    
            zs = 1:size(pkas,1);
            zs = zs - find(mmsbool);
            zs = zs + charge;
            KeggSpeciespKa(idx).zs = zs;

            nHs = 1:size(pkas,1);
            nHs = nHs - find(mmsbool);
            nHs = nHs + nH;
            KeggSpeciespKa(idx).nHs = nHs;
            KeggSpeciespKa(idx).cid = cid;
        else
            KeggSpeciespKa(idx).pKas = [];
            KeggSpeciespKa(idx).majorMSpH7 = true;
            KeggSpeciespKa(idx).zs = charge;
            KeggSpeciespKa(idx).nHs = nH;
            KeggSpeciespKa(idx).cid = cid;
        end
    end
end
KeggSpeciespKa = KeggSpeciespKa';

