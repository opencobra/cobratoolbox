function [bondsBrokenAndFormed, substrateMass] = findBondsBrokenAndFormed(model, rxnList, rxnDir, printLevel)
% Calculate the the bonds broken and formed for the mass balanced reactions
% in a metabolic network based on atom mapping data.
%
% USAGE:
%
%    [bondsBrokenAndFormed, substrateMass] = findBondsBrokenAndFormed(model, rxnDir, printLevel)
%
% INPUTS:
%    model:     COBRA model with following fields:
%
%                   * .rxns - An n x 1 array of reaction identifiers.
%                             Should match metabolite identifiers in
%    rxnList    List of reactions from which the enthalpy change
%               will be computed.
%    rxnDir     Directory of with the RXN files.
%    printLevel Print figure with the relation of mass vs bondsBF bondsE
%
% OUTPUTS:
%    bondsBF       An n x 1 vector with the number of bonds broken and
%                  formed. External or pasive transpor reactions are equal
%                  to 0; missing and unbalanced reactions are NaN.
%    substrateMass Total mass of the substrates
%
% .. Author: - German A. Preciat Gonzalez 12/06/2017

rxnDir = [regexprep(rxnDir,'(/|\\)$',''), filesep];
if nargin < 4 || isempty(printLevel)
    printLevel = 0;
end

% Atomic weight
atomicElements = {'H'; 'He'; 'Li'; 'Be'; 'B'; 'C'; 'N'; 'O'; 'F'; ...
    'Ne'; 'Na'; 'Mg'; 'Al'; 'Si'; 'P'; 'S'; 'Cl'; 'K'; 'Ar'; 'Ca'; ...
    'Sc'; 'Ti'; 'V'; 'Cr'; 'Mn'; 'Fe'; 'Ni'; 'Co'; 'Cu'; 'Zn'; 'Ga';...
    'Ge'; 'As'; 'Se'; 'Br'; 'Kr'; 'Rb'; 'Sr'; 'Y'; 'Zr'; 'Nb'; 'Mo';...
    'Tc'; 'Ru'; 'Rh'; 'Pd'; 'Ag'; 'Cd'; 'In'; 'Sn'; 'Sb'; 'I'; 'Te';...
    'Xe'; 'Cs'; 'Ba'; 'La'; 'Ce'; 'Pr'; 'Nd'; 'Pm'; 'Sm'; 'Eu'; ...
    'Gd'; 'Tb'; 'Dy'; 'Ho'; 'Er'; 'Tm'; 'Yb'; 'Lu'; 'Hf'; 'Ta'; 'W';...
    'Re'; 'Os'; 'Ir'; 'Pt'; 'Au'; 'Hg'; 'Tl'; 'Pb'; 'Bi'; 'Po'; ...
    'At'; 'Rn'; 'Fr'; 'Ra'; 'Ac'; 'Pa'; 'Th'; 'Np'; 'U'; 'Pu'; 'Am';...
    'Bk'; 'Cm'; 'No'; 'Cf'; 'Es'; 'Hs'; 'Mt'; 'Fm'; 'Md'; 'Lr'; ...
    'Rf'; 'Bh'; 'Db'; 'Sg'; 'Uun'; 'Uuu'; 'Uub'; 'A'; 'R'; '*'};
atomicWeight = [1.00797; 4.0026; 6.941; 9.01218; 10.81; 12.011; ...
    14.0067; 15.9994; 18.998403; 20.179; 22.98977; 24.305; 26.98154; ...
    28.0855; 30.97376; 32.06; 35.453; 39.0983; 39.948; 40.08; ...
    44.9559; 47.9; 50.9415; 51.996; 54.938; 55.847; 58.7; 58.9332; ...
    63.546; 65.38; 69.72; 72.59; 74.9216; 78.96; 79.904; 83.8; ...
    85.4678; 87.62; 88.9059; 91.22; 92.9064; 95.94; 98; 101.07; ...
    102.9055; 106.4; 107.868; 112.41; 114.82; 118.69; 121.75; ...
    126.9045; 127.6; 131.3; 132.9054; 137.33; 138.9055; 140.12; ...
    140.9077; 144.24; 145; 150.4; 151.96; 157.25; 158.9254; 162.5; ...
    164.9304; 167.26; 168.9342; 173.04; 174.967; 178.49; 180.9479; ...
    183.85; 186.207; 190.2; 192.22; 195.09; 196.9665; 200.59; ...
    204.37; 207.2; 208.9804; 209; 210; 222; 223; 226.0254; 227.0278; ...
    231.0359; 232.0381; 237.0482; 238.029; 242; 243; 247; 247; 250; ...
    251; 252; 255; 256; 257; 258; 260; 261; 262; 262; 263; 269; 272; ...
    277; NaN; NaN; NaN]; % amu


% Get list of RXN files
d = dir(rxnDir);
d = d(~[d.isdir]);
aRxns = {d.name}';
aRxns = aRxns(~cellfun('isempty',regexp(aRxns,'(\.rxn)$')));
% Identifiers for atom mapped reactions
aRxns = regexprep(aRxns, '(\.rxn)$','');
assert(~isempty(aRxns), 'RXN files directory is empty or nonexistent.')

% Identify mass inbalanced reactions
rxnsIdx = findRxnIDs(model, rxnList);
modeltmp = findSExRxnInd(model,[], printLevel);
exIdx = modeltmp.ExchRxnBool(rxnsIdx);
clear modeltmp

% Calculate bonds broken and formed
[allSubstrateMass, bondsBrokenAndFormed] = deal(zeros(size(rxnList)));
unbalancedBool = false(size(rxnList));
for i = 1:size(rxnList, 1)
    
    clearvars -except unbalanced bondsBrokenAndFormed exIdx atomicWeight ...
        atomicElements printLevel bondsEnergy bondsArray rxnDir model i ...
        unbalancedBool allSubstrateMass unbalancedBool rxnList
    
    substrateMass = 0;
    
    rxnFile = [rxnDir rxnList{i} '.rxn'];
    if isfile(rxnFile) % Check if the file exists
        
        % Read the MDL RXN file
        rxnFileData = regexp( fileread(rxnFile), '\n', 'split')';
        
        % Count number of products and substrates
        substrates = str2double(rxnFileData{5}(1:3));
        products = str2double(rxnFileData{5}(4:6));
        
        % Identify where a molecule starts
        begmol = strmatch('$MOL',rxnFileData);
        
        % Initialaze the number of atoms/bonds in substrates/products
        [bondsS, bondsP, atomsS, atomsP] = deal(0);
        
        % Obtain atoms and bond information
        for j = 1:substrates + products
            
            noOfAtoms = str2double(rxnFileData{begmol(j) + 4}(1:3));
            noOfBonds = str2double(rxnFileData{begmol(j) + 4}(4:6));
            if j <= substrates
                moleculeType = 'S';
            else
                moleculeType = 'P';
            end
            
            % Look for the # atoms, mapping numbers and their elements
            % corresponding the mapping number
            for k = 1:noOfAtoms
                if j <= substrates
                    substrateMass = substrateMass + atomicWeight(ismember(atomicElements, strtrim(rxnFileData{begmol(j) + 4 + k}(32:33))));
                end
                switch moleculeType
                    case 'S'
                        atomsS = atomsS + 1;
                        mappingsS(atomsS) = str2double(rxnFileData{begmol(j) + 4 + k}(61:63));
                        if mappingsS(atomsS) == 0
                            unbalancedBool(i) = true;
                            continue
                        end
                        elementsS{mappingsS(atomsS)} = strtrim(rxnFileData{begmol(j) + 4 + k}(32:33));
                    case 'P'
                        atomsP = atomsP + 1;
                        mappingsP(atomsP) = str2double(rxnFileData{begmol(j) + 4 + k}(61:63));
                        if mappingsP(atomsP) == 0
                            unbalancedBool(i) = true;
                            continue
                        end
                        elementsP{mappingsP(atomsP)} = strtrim(rxnFileData{begmol(j) + 4 + k}(32:33));
                end
            end
            
            % Check if the corresponding molecule is just an atom or not
            if noOfBonds > 0
                % Look for the # of bonds, the row atom (the mapping number of
                % the first atom in the bond), the column atom (the mapping
                % number of second atom in the bond) and the bond type
                for k = 1:noOfBonds
                    rowAtom = str2double(rxnFileData{begmol(j) + 4 + k + noOfAtoms}(1:3));
                    colAtom = str2double(rxnFileData{begmol(j) + 4 + k + noOfAtoms}(4:6));
                    switch moleculeType
                        case 'S'
                            bondsS = bondsS +1;
                            rowS(bondsS, 1) = str2double(rxnFileData{begmol(j)+ 4 + rowAtom}(61:63));
                            colS(bondsS, 1) = str2double(rxnFileData{begmol(j)+ 4 + colAtom}(61:63));
                            bondTypeS{bondsS, 1} = rxnFileData{begmol(j) + 4 + k + noOfAtoms}(9);
                        case 'P'
                            bondsP = bondsP +1;
                            rowP(bondsP, 1) = str2double(rxnFileData{begmol(j)+ 4 + rowAtom}(61:63));
                            colP(bondsP, 1) = str2double(rxnFileData{begmol(j)+ 4 + colAtom}(61:63));
                            bondTypeP{bondsP, 1} = rxnFileData{begmol(j) + 4 + k + noOfAtoms}(9);
                    end
                end
            end
        end
        
        % Check if the reaction mapps for the same elements
        %         assert(isequal(elementsP, elementsS), 'The reaction mapps for different elements')
        
        if ~isequal(elementsP, elementsS) || unbalancedBool(i)
            unbalancedBool(i) = true;
            clear elementsP elementsS
            continue
        end
        
        % Create the matrices
        switch exist('bondTypeS', 'var') + exist('bondTypeP', 'var') * 2
            % No bonds in the reaction
            case 0
                
                bondsBrokenAndFormed(i, 1) = 0;
                
                % No bonds in the product(s)
            case 1
                for j = 1 : length(bondTypeS)
                    
                    % Looks for the avarage energy of a chemical bond based on the literature
                    matrixS_BBF(rowS(j), colS(j)) = str2double(bondTypeS{j});
                    matrixS_BBF(colS(j), rowS(j)) = str2double(bondTypeS{j});
                end
                matrixP_BBF = zeros(length(matrixS_BBF));
                
                % No bonds in the substrate(s)
            case 2
                for j = 1 : length(bondTypeP)
                    matrixP_BBF(rowP(j), colP(j)) = str2double(bondTypeP{j});
                    matrixP_BBF(colP(j), rowP(j)) = str2double(bondTypeP{j});
                end
                matrixS_BBF = zeros(length(matrixP_BBF));
                
                % Bonds for substrate(s) and product(s)
            case 3
                for j = 1 : length(bondTypeS)
                    matrixS_BBF(rowS(j), colS(j)) = str2double(bondTypeS{j});
                    matrixS_BBF(colS(j), rowS(j)) = str2double(bondTypeS{j});
                end
                for j = 1 : length(bondTypeP)
                    matrixP_BBF(rowP(j), colP(j)) = str2double(bondTypeP{j});
                    matrixP_BBF(colP(j), rowP(j)) = str2double(bondTypeP{j});
                end
                if length(matrixS_BBF) ~= length(matrixP_BBF)
                    if length(matrixS_BBF) > length(matrixP_BBF)
                        matrixP_BBF(length(matrixS_BBF),length(matrixS_BBF)) = 0;
                    else
                        matrixS_BBF(length(matrixP_BBF),length(matrixP_BBF)) = 0;
                    end
                end
                
        end
        
        % Sum the number of bonds broken and formed
        if exist('matrixS_BBF', 'var') && exist('matrixP_BBF', 'var')
            bondsBrokenAndFormed(i) = sum(sum(abs(matrixS_BBF - matrixP_BBF))') / 2;
        end
        
    elseif ismember(i, exIdx)
        
        % Mass inbalanced reactions equal to zero
        bondsBrokenAndFormed(i, 1) = 0;
        
    else
        
        % Missing RXN file equal to NaN
        bondsBrokenAndFormed(i, 1) = NaN;
        if printLevel > 0
            allSubstrateMass(i) = NaN;
        end
        
    end
    
    % Assing substrateMass
    allSubstrateMass(i, 1) = substrateMass;
    
end

% Consider unbalanced as missing
bondsBrokenAndFormed(unbalancedBool) = NaN;

if printLevel > 0
    [mass, idx] = sort(allSubstrateMass);
    figure
    scatter(mass, bondsBrokenAndFormed(idx), 'filled')
    bonds = bondsBrokenAndFormed(idx);
    mass1 = mass;
    mass1(isnan(bonds) | isnan(mass)) = [];
    bonds(isnan(bonds) | isnan(mass)) = [];
    title({'Total mass of substrates vs bonds', ...
        'broken and formed', ...
        ['Correlation = ' num2str(round(corr(mass1, bonds,'Type','Spearman'), 2))]}, 'FontSize', 20)
    xlabel('Mass of substrates (amu)', 'FontSize', 18)
    ylabel('Number of bonds broken and formed', 'FontSize', 18)
    
end
substrateMass = allSubstrateMass;
end