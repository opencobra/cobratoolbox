function [speciespKas, includedMets] = assignpKasToSpecies(mets, neutralMolfileDir, msDistrDir, pKaDir)
% Use each metabolite's InChI and ChemAxon's cxcalc (calculator plugin) to
% get `pKas(I = 0)`, charges and numbers of protons for all microspecies
% present at pH 5-9.
%
% USAGE:
%
%    [metList, noMolMetList] = mol2sdf(mets, molfileDir, sdfFileName, includeRs)
%
% INPUTS:
%    mets:                 Cell array of metabolite ID. Current implementation
%                          assumes ID are formatted as `BiGG_ID[Compartment]`;
%                          e.g., 'atp[c]' for ATP in cytosol.
%    neutralMolfileDir:    Path to directory containing molfiles for neutral
%                          metabolites. Molfiles must be named with the
%                          metabolite ID in mets; e.g., `atp.mol`.
%    msDistrDir:           Path to directory containing metabolite species
%                          distributions at pH 5, 6, 7, 8 and 9. Species
%                          distributions are created with the ChemAxon
%                          calculator plugin. Names of SD files containing
%                          species distributions should be formatted as
%                          `metID_msdistr_pHA.sdf`; e.g., `atp_msdistr_pH5.sdf`.
%    pKaDir:               Path to directory containing pKa estimates for
%                          metabolites. pKas are estimated with the ChemAxon
%                          calculator plugin. Names of text files containing
%                          pKa estimates should be formatted as
%                          `metID_pkas.txt`; e.g., `atp_pkas.txt`.
%
% OUTPUT:
%    speciespKas:          Structure containing the following fields for each metabolite:
%
%                            * .inchis - `n x 1` cell array with a species-specific InChI string
%                              for each species. `inchis(1) = InChI` for species 1 etc.
%                              Note that species 1 is the species with the fewest hydrogen atoms etc.
%                            * .formulas - `n x 1` cell array with species-specific chemical formulas.
%                            * .zs - `n x 1` vector containing the charge on each species.
%                            * .nHs - `n x 1` vector containing the number of hydrogen atoms in each species.
%                            * .majorMSpH7 - `n x 1` boolean vector with a logical 1 in the row for
%                              the major microspecies at pH 7 according to ChemAxon.
%                            * .abundanceAtpH7 - `n x 1` vector with species percentage abundance at pH 7.
%                            * .pKas - `n x n` matrix where element `i, j` is the pKa for the
%                              acid-base equilibrium between species `i` and `j`.
%                            * includedMets - Cell array of metabolite ID for those metabolites that
%                              were included in speciespKas. Should include all metabolites that had molfiles in `neutralMolfileDir`.

phs = 5:9; % Physiological pH range

dirData = dir(neutralMolfileDir);
molfileList = cat(2,dirData.name);
molfileList = regexp(molfileList,'.mol','split');
molfileList = regexprep(molfileList,'\.','');
molfileList = molfileList(~cellfun('isempty',molfileList));

includedMets = {};

model.mets = mets;
nMets = length(model.mets);
done = cell(nMets,1);

for k = 1:nMets
    disp(['Starting on metabolite ' num2str(k) '. Only ' num2str(nMets-k) ' metabolites to go.'])

    if ~any(strcmp(model.mets{k}(1:end-3),done))
        done{k} = model.mets{k}(1:end-3);

        if any(strcmp(molfileList,model.mets{k}(1:(end-3))))
            includedMets = [includedMets; model.mets{k}(1:end-3)];

            % Get data from sdf files with microspecies distributions
            % for all species with molfractions above threshold
            totalCharges = {};
            chargedAtoms = {};
            atomicCharges = {};
            currentPhs = {};
            percentages = {};
            mmsPh7Bool = {};

            fid5 = fopen('abundantSpecies.sdf', 'w+'); % Create separate sdf file for species with molfractions above threshold
            fclose(fid5);

            for n = 1:length(phs)
                ph = phs(n);

                newPh = 1; % True while processing first microspecies at each pH

                %     Open microspecies distribution at ph
                fid2 = fopen([msDistrDir filesep model.mets{k}(1:(end-3)) '_msdistr_ph' num2str(ph) '.sdf'], 'r'); % Open sdf file with microspecies distribution for reading

                charged = 0; % Neutral until proven charged

                %     Parse speciesDistribution.sdf for all microspecies that are present at ph
                while 1
                    tline = fgetl(fid2); % Get next line of speciesPhDistribution.sdf

                    if ~ischar(tline) % Exit while loop if the last line of speciesPhDistribution.sdf is reached, continue at next pH
                        fclose(fid2);
                        delete currentSpecies.sdf
                        pause(eps);
                        break;
                    end

                    fid3 = fopen('currentSpecies.sdf', 'a'); % Create separate sdf file for species with molfractions above threshold
                    fprintf(fid3, '%s\r\n', tline); % Copy line to abundantSpecies.sdf
                    fclose(fid3);

                    if ~isempty(strfind(tline, 'M  CHG'))
                        charged = 1;
                        chargeLine = tline;
                    end

                    if ~isempty(strfind(tline, '>  <DISTR')) % Get the percentage of current microspecies at ph
                        percentLine = fgetl(fid2);
                        fid3 = fopen('currentSpecies.sdf', 'a'); % Create separate sdf file for species with molfractions above threshold
                        fprintf(fid3, '%s\r\n', percentLine); % Copy line to abundantSpecies.sdf
                        fclose(fid3);

                        percentage = str2double(regexprep(percentLine, ',', '\.'));

                        if percentage == 0 % Exit while loop at first microspecies that is not present at current pH. Continue at next pH.
                            fclose(fid2);
                            delete currentSpecies.sdf
                            pause(eps);
                            break;
                        else
                            currentPhs = [currentPhs; {ph}];
                            percentages = [percentages; {percentage}];

                            % Get numbers of atoms carrying charge, charge on each atom
                            % and total charge
                            currentChargedAtoms = [];
                            currentAtomicCharges = [];

                            if charged
                                splitLine = regexp(strtrim(chargeLine(11:end)), '\s+', 'split');
                                AtomIdx = 1:2:(length(splitLine)-1);
                                chargeIdx = 2:2:length(splitLine);

                                for m = 1:length(AtomIdx)
                                    currentChargedAtoms = [currentChargedAtoms, str2double(splitLine{AtomIdx(m)})];
                                end

                                for m = 1:length(chargeIdx)
                                    currentAtomicCharges = [currentAtomicCharges, str2double(splitLine{chargeIdx(m)})];
                                end

                                currentTotalCharge = sum(currentAtomicCharges);

                            else
                                currentTotalCharge = 0;

                            end

                            chargedAtoms = [chargedAtoms; {currentChargedAtoms}];
                            atomicCharges = [atomicCharges; {currentAtomicCharges}];
                            totalCharges = [totalCharges; {currentTotalCharge}];
                        end
                    end

                    if ~isempty(strfind(tline, '$$$$')) % End of sdf for current species
                        system('type currentSpecies.sdf >> abundantSpecies.sdf');
                        delete currentSpecies.sdf
                        pause(eps);
                        if ph == 7 && newPh
                            mmsPh7Bool = [mmsPh7Bool; {true}]; % True for major microspecies at pH 7, the one WebGCM computes Gibbs energy of formation for
                        else
                            mmsPh7Bool = [mmsPh7Bool; {false}];
                        end

                        newPh = 0; % reset
                        charged = 0; % Reset
                    end
                end
            end

            % Get additional species data
            % Get formulas
            [~, formulas] = system('cxcalc formula abundantSpecies.sdf');
            formulas = regexp(formulas,'\s','split');
            formulas = formulas(4:2:2*length(mmsPh7Bool)+3)';

            % Get number of hydrogen atoms
            numberHs = cell(size(formulas));
            for spnr = 1:length(formulas)
                numberHs{spnr} = numAtomsOfElementInFormula(formulas{spnr},'H');
            end

            % Get inchis for all species in abundantSpecies.sdf
            [~, inchis] = system('obabel abundantSpecies.sdf -oinchi -xFwT/nostereo');
            inchis = regexp(inchis, '\n', 'split');
            inchiIdx = regexp(inchis,'InChI=');
            inchis = inchis(~cellfun('isempty',inchiIdx))';
            inchiIdx = inchiIdx(~cellfun('isempty',inchiIdx))';

            if ~isempty(setdiff(1:length(inchis),strmatch('InChI=',inchis)))
                errlins = setdiff(1:length(inchis),strmatch('InChI=',inchis));
                for errlini = 1:length(errlins)
                    inchis{errlins(errlini)} = inchis{errlins(errlini)}(inchiIdx{errlins(errlini)}:end);
                end
            end

            % Create dataArray with all species data (non-unique)
            dataArray = [inchis formulas numberHs totalCharges chargedAtoms atomicCharges currentPhs percentages mmsPh7Bool];

            % Sum up percentages for different stereoisomers of the same
            % species at the same pH
            stiCorrectedDataArray = [];

            for stph = 5:9
                currentpHBool = cat(1,dataArray{:,7}) == stph;
                dataArrayCurrentpH = dataArray(currentpHBool,:);
                uniqueInchisCurrentpH = unique(inchis(currentpHBool));
                for stinr = 1:length(uniqueInchisCurrentpH)
                    stiCorrectedDataArray = [stiCorrectedDataArray; dataArrayCurrentpH(find(ismember(dataArrayCurrentpH(:,1),uniqueInchisCurrentpH{stinr}),1),:)];
                    stiCorrectedDataArray{end,8} = sum(cat(1,dataArrayCurrentpH{ismember(dataArrayCurrentpH(:,1),uniqueInchisCurrentpH{stinr}),8}));
                end
            end

            dataArray = stiCorrectedDataArray;

            % Discard species that are present below some logical
            % threshold percentage
            thresholdPercentage = 1;
            belowThresholdBool = cat(1,dataArray{:,8}) < thresholdPercentage;
            dataArray = dataArray(~belowThresholdBool,:);

            abundanceAtpH7 = zeros(size(dataArray,1),1);
            abundanceAtpH7(cat(1,dataArray{:,7}) == 7) = cat(1,dataArray{cat(1,dataArray{:,7})==7,8});
            dataArray = [dataArray, num2cell(abundanceAtpH7)];

            % Get inchis for all species in abundantSpecies.sdf
            %                 [~, uniqueInchis] = system('obabel abundantSpecies.sdf -oinchi -xFwuT/nostereo');
            %                 uniqueInchis = regexp(uniqueInchis, '\n', 'split');
            %                 uniqueInchis = uniqueInchis(strmatch('InChI=',uniqueInchis))';
            inchis = dataArray(:,1);
            uniqueInchis = unique(inchis);

            uniqueDataArray = {};
            for inr = 1:length(uniqueInchis)
                sameSpeciesBool = ismember(dataArray(:,1),uniqueInchis{inr});
                tmpDataArray = dataArray(sameSpeciesBool,:);
                [~, speciesIdxInTmpDataArray] = max(cat(1,tmpDataArray{:,8}));
                uniqueDataArray = [uniqueDataArray; tmpDataArray(speciesIdxInTmpDataArray,:)];
                if any(cat(1,dataArray{sameSpeciesBool,9}))
                    uniqueDataArray{end,9} = true;
                end
                uniqueDataArray{end,10} = max(cat(1,dataArray{sameSpeciesBool,10}));
            end

            dataArray = uniqueDataArray;

            % Get charge and number of H atoms for fully protonated
            % species for later corrections
            nmoldir = fopen([neutralMolfileDir filesep model.mets{k}(1:(end-3)), '.mol'], 'r');
            nmolcharged = false;

            while 1
                tline = fgetl(nmoldir);

                if ~ischar(tline)
                    break;
                end

                if ~isempty(strfind(tline, 'M  CHG'))
                    nmolcharged = true;
                    nmolAcharges = regexp(tline(12:end),'\s+','split');
                    nmolAcharges = nmolAcharges(~cellfun('isempty',nmolAcharges));
                    nmolAcharges = nmolAcharges(2:2:end);
                    acnum = [];
                    for acIdx = 1:length(nmolAcharges)
                        acnum = [acnum, str2double(nmolAcharges(acIdx))];
                    end
                    nmolcharge = sum(acnum);
                end
            end

            fclose(nmoldir);

            if ~nmolcharged
                nmolcharge = 0;
            end

            [~, nmolformula] = system(['cxcalc formula ' neutralMolfileDir filesep model.mets{k}(1:(end-3)), '.mol']);
            nmolformula = regexp(nmolformula,'\s','split');
            nmolformula = nmolformula{4};
            nmolnH = numAtomsOfElementInFormula(nmolformula,'H');

            dataArray(:,3) = num2cell(nmolnH + (cat(1,dataArray{:,4}) - nmolcharge));
            dataArray = sortrows(dataArray,[3, 4]); % Sort by number of hydrogen atoms, then charge, in ascending order so row 1 contains data for species 1.

            % Boolean vector indicating major microspecies at pH 7
            mmsBool = logical(cat(1,dataArray{:,9}));

            % % Figure out which groups are in equilibrium at the specified pH by
            % comparing numbering of atoms carrying charge in each microspecies.
            nSpecies = size(dataArray,1);
            metIdx = length(includedMets);

            speciespKas(metIdx).abbreviation = includedMets{metIdx};
            speciespKas(metIdx).inchis = dataArray(:,1);
            speciespKas(metIdx).formulas = dataArray(:,2);
            speciespKas(metIdx).zs = cat(1,dataArray{:,4});
            speciespKas(metIdx).nHs = cat(1,dataArray{:,3});
            speciespKas(metIdx).majorMSpH7 = mmsBool;
            speciespKas(metIdx).abundanceAtpH7 = cat(1,dataArray{:,10});


            if nSpecies >= 2 % If there is only one species there is no need to compute pKas

                % Get species pKas
                maxChargedAtom = max(unique(cat(2,dataArray{:,5}))); % Find highest atomic number carrying charge
                chargeMatrix = zeros (nSpecies,maxChargedAtom); % Each column is an atom, each row a species. Each element is the charge on an atom in a species.
                atomNumbers = {};

                for n = 1:nSpecies
                    if ~isempty(dataArray{n,5}) % If empty the species is neutral and no atoms carry charge
                        chargeMatrix(n,dataArray{n,5}) = dataArray{n,6}; % Populate chargeMatrix
                    end
                end

                speciesEquilibriumBool = false(nSpecies,nSpecies);
                for spRows = 1:nSpecies
                    for spCols = 1:nSpecies
                        if length(find(chargeMatrix(spRows,:) ~= chargeMatrix(spCols,:))) == 1 && abs(abs(dataArray{spRows,4}) - abs(dataArray{spCols,4})) == 1
                            speciesEquilibriumBool(spRows,spCols) = true;
                        end
                    end
                end

                speciesEquilibriumAtomNrs = zeros(size(speciesEquilibriumBool));
                for n = 1:(nSpecies-1)
                    theseAtomNumbers = [];
                    oneup = find(speciesEquilibriumBool(n,:) & (1:nSpecies > n)); % Find row indices of all species with one more H atom

                    if ~isempty(oneup) % Not for species with the highest number of H atoms
                        for l = 1:length(oneup)
                            theseAtomNumbers = [theseAtomNumbers, find(chargeMatrix(n,:) ~= chargeMatrix(oneup(l),:))]; % Find number of atom being protonated/deprotonated in acid-base equilibrium between species n and species n+1
                            speciesEquilibriumAtomNrs(n,oneup(l)) = find(chargeMatrix(n,:) ~= chargeMatrix(oneup(l),:));
                        end

                        atomNumbers = [atomNumbers; {theseAtomNumbers}];
                    end
                end
                speciesEquilibriumAtomNrs = speciesEquilibriumAtomNrs + speciesEquilibriumAtomNrs';

                fid4 = fopen([pKaDir filesep model.mets{k}(1:(end-3)) '_pkas.txt'], 'r'); % Open txt file with pkas for reading
                headerline = fgetl(fid4);
                pkaline = fgetl(fid4);
                fclose(fid4);

                %     Construct two column cell array with pkas of all functional groups
                %     and numbers of atoms associated with each pka
                splitline = regexp(pkaline, '\s', 'split');
                pkaCells = splitline(2:end-1);
                pkaCells = pkaCells(~cellfun('isempty',pkaCells));
                pkaCells = regexprep(pkaCells, ',', '\.');

                splitAtomNumbers = regexp(splitline{end}, ',', 'split');
                pkaCells = [pkaCells;splitAtomNumbers]';
                pkaMat = zeros(size(pkaCells));

                for n = 1:size(pkaMat,1);
                    pkaMat(n,1) = str2double(pkaCells{n,1});
                    pkaMat(n,2) = str2double(pkaCells{n,2});

                end

                %     Correlate numbers of atoms associated with each pka with numbers of
                %     atoms in atomNumbers to get pka for equilibrium between each pair of
                %     microspecies
                speciesEquilibriumPkas = zeros(size(speciesEquilibriumBool));

                for n = 1:length(atomNumbers)
                    for m = 1:length(atomNumbers{n})
                        pkaIdx = find(atomNumbers{n}(m) == pkaMat(:,2));
                        if length(pkaIdx) == 1
                            speciesEquilibriumPkas(speciesEquilibriumAtomNrs == pkaMat(pkaIdx,2)) = pkaMat(pkaIdx,1);

                        elseif length(pkaIdx) > 1 % Many atoms will have two pKas; one acidic (for when it donates a proton) and one basic (for when it accepts a proton)
                            [~, minIdx] = min(abs(dataArray{n,7} - pkaMat(pkaIdx,1))); % Assume the appropriate pKa is the one closer to the pH where species is present at its maximum
                            speciesEquilibriumPkas(speciesEquilibriumAtomNrs == pkaMat(pkaIdx(minIdx),2)) = pkaMat(pkaIdx(minIdx),1);
                        end

                    end

                end

                speciespKas(metIdx).pKas = speciesEquilibriumPkas;

            else
                speciespKas(metIdx).abbreviation = includedMets{metIdx};
                speciespKas(metIdx).inchis = dataArray(:,1);
                speciespKas(metIdx).formulas = dataArray(:,2);
                speciespKas(metIdx).zs = cat(1,dataArray{:,4});
                speciespKas(metIdx).nHs = cat(1,dataArray{:,3});
                speciespKas(metIdx).majorMSpH7 = mmsBool;
                speciespKas(metIdx).abundanceAtpH7 = 100;
                speciespKas(metIdx).pKas = [];
            end

        end

    end

end

speciespKas = speciespKas';
