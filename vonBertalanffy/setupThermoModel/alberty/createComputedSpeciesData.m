function computedSpeciesData = createComputedSpeciesData(metSpeciespKa,metGroupCont)

% Use group contribution estimated standard Gibbs energies of formation for
% predominant metabolite species at pH 7, and ChemAxon estimated pKa for species
% equilibria, to calculate standard Gibbs energies of formation for
% nonpredominant metabolite species.
%
% computedSpeciesData = createComputedSpeciesData(metSpeciespKa,metGroupCont)
%
% INPUTS
% metSpeciespKa         Structure containing pKa for acid-base equilibria between
%                       metabolite species. pKa are estimated with ChemAxon's
%                       pKa calculator plugin (see function "assignpKasToSpecies")
% metGroupCont          Structure array with group contribution method output
%                       mapped to BiGG metabolites.
%
% OUTPUT
% computedSpeciesData   Structure with thermodynamic data for metabolite
%                       species. Contains two fields for each metabolite:
%                       .abbreviation: Metabolite abbreviation
%                       .basicData:    Cell array with 4 columns; 1) dGf0
%                                      (kJ/mol), 2)dHf0, 3) charge, 4)
%                                      #Hydrogens



R = 1.9858775 * 1e-3; % Gas constant in kcal/(mol*K)
T = 298; % Temperature in K

metGroupContMets = cat(2,metGroupCont.abbreviation);
metGroupContMets = regexp(metGroupContMets,'\[\w\]','split');
metGroupContMets = metGroupContMets(~cellfun('isempty',metGroupContMets));

speciesData = metSpeciespKa;
nMets = length(speciesData);
noDfG0Idx = [];
includedMets = {};

for metIdx = 1:nMets
    met = speciesData(metIdx).abbreviation;
    nSpecies = length(speciesData(metIdx).nHs);
    speciesData(metIdx).dGf0s = nan(nSpecies,1);
    metGcIdx = strcmp(metGroupContMets,met);
    
    if any(metGcIdx)
        includedMets = [includedMets; {met}];
        metGcIdx = find(metGcIdx,1);
        
        gcmSpeciesBool = speciesData(metIdx).zs == metGroupCont(metGcIdx,1).chargeMarvin;
        mmsBool = speciesData(metIdx).majorMSpH7;
        notInRangeBool = false;
        
        if sum(gcmSpeciesBool) > 1
            if gcmSpeciesBool(mmsBool)
                gcmSpeciesBool = mmsBool;
            elseif any(speciesData(metIdx).abundanceAtpH7 ~= 0 & gcmSpeciesBool)
                gcmSpeciesBool(speciesData(metIdx).abundanceAtpH7 ~= max(speciesData(metIdx).abundanceAtpH7(gcmSpeciesBool))) = false;
            else
                gcmSpeciesBool(gcmSpeciesBool) = false;
            end
        end
        
        if ~any(gcmSpeciesBool)
            disp(['GCM major microspecies for ' speciesData(metIdx).abbreviation ' not found.']);
            notInRangeBool = true;
        end
        
        if nSpecies >= 2 && ~notInRangeBool
            speciesData(metIdx).gcmSpecies = gcmSpeciesBool;
            
            % Calculate species Gibbs energies of formation from WebGCM
            % estimate for the major microspecies at pH 7 and pKas
            gcmSpeciesIdx = find(speciesData(metIdx).gcmSpecies); % Index of major microspecies at pH 7
            speciesData(metIdx).dGf0s(gcmSpeciesIdx) = metGroupCont(metGcIdx,1).delta_G_formation; % Insert WebGCM estimate of the Gibbs energy of formation for the major microspecies at pH 7
            
            speciesEquilibriumPkas = speciesData(metIdx).pKas;
            speciesEquilibriumBool = speciesEquilibriumPkas ~= 0;
            speciesEquilibriumDoneBool = false(size(speciesEquilibriumBool));
            equilibriaCounter = zeros(size(speciesData(metIdx).dGf0s));
            equilibriaCounter(gcmSpeciesIdx) = 1;
            
            while any(any(speciesEquilibriumDoneBool ~= speciesEquilibriumBool))
                for spRow = 1:nSpecies
                    for spCol = 1:nSpecies
                        thisSpeciesDfG0 = nan;
                        if speciesEquilibriumBool(spRow,spCol)
                            if ~speciesEquilibriumDoneBool(spRow,spCol)
                                if ~isnan(speciesData(metIdx).dGf0s(spRow))
                                    if spCol > spRow
                                        thisSpeciesDfG0 = speciesData(metIdx).dGf0s(spRow) - R*T*log(10)*speciesEquilibriumPkas(spRow,spCol);
                                        if isnan(speciesData(metIdx).dGf0s(spCol))
                                            speciesData(metIdx).dGf0s(spCol) = thisSpeciesDfG0;
                                            equilibriaCounter(spCol) = 1;
                                        else
                                            speciesData(metIdx).dGf0s(spCol) = (1/(equilibriaCounter(spCol) + 1)) * (equilibriaCounter(spCol)*speciesData(metIdx).dGf0s(spCol) + thisSpeciesDfG0); % Also need to figure out how to calculate running standard deviation
                                            equilibriaCounter(spCol) = equilibriaCounter(spCol) + 1;
                                        end
                                        
                                        speciesEquilibriumDoneBool(spRow,spCol) = true;
                                        speciesEquilibriumDoneBool(spCol,spRow) = true;
                                    else
                                        thisSpeciesDfG0 = speciesData(metIdx).dGf0s(spRow) + R*T*log(10)*speciesEquilibriumPkas(spRow,spCol);
                                        if isnan(speciesData(metIdx).dGf0s(spCol))
                                            speciesData(metIdx).dGf0s(spCol) = thisSpeciesDfG0;
                                            equilibriaCounter(spCol) = 1;
                                        else
                                            speciesData(metIdx).dGf0s(spCol) = (1/(equilibriaCounter(spCol) + 1)) * (equilibriaCounter(spCol)*speciesData(metIdx).dGf0s(spCol) + thisSpeciesDfG0);
                                            equilibriaCounter(spCol) = equilibriaCounter(spCol) + 1;
                                        end
                                        
                                        speciesEquilibriumDoneBool(spRow,spCol) = true;
                                        speciesEquilibriumDoneBool(spCol,spRow) = true;
                                    end
                                elseif ~isnan(speciesData(metIdx).dGf0s(spCol))
                                    if spRow > spCol
                                        thisSpeciesDfG0 = speciesData(metIdx).dGf0s(spCol) - R*T*log(10)*speciesEquilibriumPkas(spRow,spCol);
                                        if isnan(speciesData(metIdx).dGf0s(spRow))
                                            speciesData(metIdx).dGf0s(spRow) = thisSpeciesDfG0;
                                            equilibriaCounter(spRow) = 1;
                                        else
                                            speciesData(metIdx).dGf0s(spRow) = (1/(equilibriaCounter(spRow) + 1)) * (equilibriaCounter(spRow)*speciesData(metIdx).dGf0s(spRow) + thisSpeciesDfG0);
                                            equilibriaCounter(spRow) = equilibriaCounter(spRow) + 1;
                                        end
                                        
                                        speciesEquilibriumDoneBool(spRow,spCol) = true;
                                        speciesEquilibriumDoneBool(spCol,spRow) = true;
                                    else
                                        thisSpeciesDfG0 = speciesData(metIdx).dGf0s(spCol) + R*T*log(10)*speciesEquilibriumPkas(spRow,spCol);
                                        if isnan(speciesData(metIdx).dGf0s(spRow))
                                            speciesData(metIdx).dGf0s(spRow) = thisSpeciesDfG0;
                                            equilibriaCounter(spRow) = 1;
                                        else
                                            speciesData(metIdx).dGf0s(spRow) = (1/(equilibriaCounter(spRow) + 1)) * (equilibriaCounter(spRow)*speciesData(metIdx).dGf0s(spRow) + thisSpeciesDfG0);
                                            equilibriaCounter(spRow) = equilibriaCounter(spRow) + 1;
                                        end
                                        
                                        speciesEquilibriumDoneBool(spRow,spCol) = true;
                                        speciesEquilibriumDoneBool(spCol,spRow) = true;
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
        else
            speciesData(metIdx).inchis = {};
            speciesData(metIdx).formulas = metGroupCont(metGcIdx,1).formulaMarvin;
            speciesData(metIdx).zs = metGroupCont(metGcIdx,1).chargeMarvin;
            speciesData(metIdx).nHs = numAtomsOfElementInFormula(speciesData(metIdx).formulas,'H');
            speciesData(metIdx).majorMSpH7 = true;
            speciesData(metIdx).gcmSpecies = true;
            speciesData(metIdx).pKas = [];
            speciesData(metIdx).dGf0s = metGroupCont(metGcIdx,1).delta_G_formation;
        end
        
    else
        noDfG0Idx = [noDfG0Idx; metIdx];
    end
end

speciesData = speciesData(setdiff(1:metIdx,noDfG0Idx));

% Create computedSpeciesData from speciesData. computedSpeciesData is
% formatted like Alberty2006 struct.
for n = 1:length(includedMets)
    computedSpeciesData(1,n).abbreviation = includedMets{n};
    computedSpeciesData(1,n).mmspH7Bool = speciesData(n,1).majorMSpH7;
    computedSpeciesData(1,n).gcmSpecies = speciesData(n,1).gcmSpecies;
    
    nSpecies = length(speciesData(n,1).nHs);
    basicDataMat = nan(nSpecies,4);
    
    basicDataMat(:,1) = speciesData(n,1).dGf0s * 4.184; % Convert from kcal/mol to kJ/mol
    basicDataMat(:,3) = speciesData(n,1).zs;
    basicDataMat(:,4) = speciesData(n,1).nHs;
    
    computedSpeciesData(1,n).basicData = basicDataMat;
end

% Average metabolite species standard Gibbs energies of formation over
% species of the same metabolite that have the same charge
for n = 1:length(computedSpeciesData)
    if isempty(computedSpeciesData(n).gcmSpecies)
        computedSpeciesData(n).gcmSpecies = true;
    end
    if isempty(computedSpeciesData(n).mmspH7Bool)
        computedSpeciesData(n).mmspH7Bool = true;
    end
    basicData = computedSpeciesData(n).basicData;
    newBasicData = [];
    newGcmSpecies = [];
    newMmspH7Bool = [];
    done = [];
    for m = 1:size(basicData,1)
        if ~any(done == m)
            newBasicData = [newBasicData; basicData(m,:)];
            newGcmSpecies = [newGcmSpecies; computedSpeciesData(n).gcmSpecies(m)];
            newMmspH7Bool = [newMmspH7Bool; computedSpeciesData(n).mmspH7Bool(m)];
            equalnHbool = (basicData(:,3) == basicData(m,3));
            done = [done; find(equalnHbool)];
            if sum(equalnHbool) > 1
                newBasicData(end,1) = min(basicData(equalnHbool,1)) + -8.3144621e-3*298.15*log(sum(exp((-1/(8.3144621e-3*298.15))*(basicData(equalnHbool,1) - min(basicData(equalnHbool,1))))));
                if any(computedSpeciesData(n).gcmSpecies(equalnHbool))
                    newGcmSpecies(end) = true;
                end
                if any(computedSpeciesData(n).mmspH7Bool(equalnHbool))
                    newMmspH7Bool(end) = true;
                end
                
            end
        end
    end
    computedSpeciesData(n).basicData = newBasicData;
    computedSpeciesData(n).gcmSpecies = newGcmSpecies;
    computedSpeciesData(n).mmspH7Bool = newMmspH7Bool;
end
