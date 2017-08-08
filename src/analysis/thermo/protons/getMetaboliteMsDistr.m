function getMetaboliteMsDistr(mets, molfiledir, msdistrdir, phs)
% Calculate microspecies distributions at all pH values in phs using
% ChemAxon's cxcalc. Metabolite mol files in molfiledir are input to cxcalc. Mol file names
% should correspond to the metabolite ID in mets (it is assumed that
% compartment assignments are appended to the end of metabolite ID in the
% format `metID[c]`). Microspecies distributions are returned as .sdf files
% in `msdistrdir`
%
% USAGE:
%
%    getMetaboliteMsDistr(mets, molfiledir, msdistrdir, phs)
%
% INPUTS:
%    mets:          metabolites
%    molfiledir:    directory with mol files
%    msdistrdir:    directory with microspecies distributions
%    phs:           pH values

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

    if ~any(strcmp(model.mets{n}(1:(end-3)),done))
        done = [done; {model.mets{n}(1:(end-3))}];

        if any(strcmp(molfilelist,mets{n}(1:(end-3))))

            for m = 1:length(phs)
                ph = phs(m);

                if ispc
                    system(['cxcalc -o ', msdistrdir, filesep, model.mets{n}(1:(end-3)), '_msdistr_ph', num2str(ph), '.sdf msdistr -H ', num2str(ph), ' -M true ', molfiledir, filesep, model.mets{n}(1:(end-3)), '.mol']);
                end

            end

        end

    end

end
