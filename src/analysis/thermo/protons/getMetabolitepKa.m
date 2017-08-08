function getMetabolitepKa(mets, molfiledir, pkadir)
% Compute pKas of the metabolites listed in mets using ChemAxon's cxcalc.
% Metabolite mol files in molfiledir are input to cxcalc. Mol file names
% should correspond to the metabolite ID in mets (it is assumed that
% compartment assignments are appended to the end of metabolite ID in the
% format `metID[c]`). Text files with `pKas` are returned in `pkadir`.
%
% USAGE:
%
%    getMetabolitepKa(mets, molfiledir, pkadir)
%
% INPUTS:
%    mets:          metabolites
%    molfiledir:    directory with mol files
%    pkadir:        directory with text files with `pKas`

d = dir(molfiledir);
molfilelist = cat(2,d.name);
molfilelist = regexp(molfilelist,'.mol','split');
molfilelist = regexprep(molfilelist,'\.','');
molfilelist = molfilelist(~cellfun('isempty',molfilelist))';

nMet = length(mets);
done = {};

model.mets = mets;

for n = 1:nMet
    disp(n)

    if ~any(strcmp(mets{n}(1:(end-3)),done))
        done = [done; {mets{n}(1:(end-3))}];

        if any(strcmp(molfilelist,mets{n}(1:(end-3))))

            if ispc
                system(['cxcalc -o ', pkadir, filesep, model.mets{n}(1:(end-3)), '_pkas.txt pka -M true -a 20 -b 20 ', molfiledir, filesep, model.mets{n}(1:(end-3)) '.mol']);
            end

        end

    end

end
