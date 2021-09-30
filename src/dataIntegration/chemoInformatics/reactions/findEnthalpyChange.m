function [enthalpyChange, substrateMass] = findEnthalpyChange(model, rxnList, rxnDir, printLevel)
% Calculate the enthalphy change for mass balanced reactions in a
% metabolic network based on atom mapping data.
%
% The enthalpy change are based on:
% Huheey, pps. A-21 to A-34; T.L. Cottrell, "The Strengths of Chemical
% Bonds," 2nd ed., Butterworths, London, 1958;
% B. deB. Darwent, "National Standard Reference Data Series," National
% Bureau of Standards, No. 31,Washington, DC, 1970; S.W. Benson, J. Chem.
% Educ., 42, 502 (1965)
%
% USAGE:
%
%    [enthalpyChange, substrateMass] = findEnthalpyChange(model, rxnList, rxnDir, printLevel)
%
% INPUTS:
%    model:     COBRA model with following fields:
%
%                   * .rxns - An n x 1 array of reaction identifiers.
%                             Should match metabolite identifiers in
%    rxnList    List of reactions from which the number of broken and
%               formed bonds will be computed.
%    rxnDir     Directory of with the RXN files.
%    printLevel Print figure with the relation of mass vs bondsBF bondsE
%
% OUTPUTS:
%    enthalpyChange	An n x 1 vector with the bond enthalpies in kJ/mol.
%                   External or pasive transpor reactions are equal to 0;
%                   missing and unbalanced reactions are NaN.
%    substrateMass Total mass of the substrates
%
% .. Author: - German A. Preciat Gonzalez 12/06/2017

if nargin < 2 || isempty(rxnList)
    rxnList = model.rxns;
end
rxnDir = [regexprep(rxnDir,'(/|\\)$',''), filesep];
if nargin < 4 || isempty(printLevel)
    printLevel = 0;
end

% Load chemical data
bondsArray = {'1 H H'; '1 B H'; '1 C H'; '1 H Si'; '1 Ge H'; '1 H Sn'; ...
    '1 H N'; '1 H P'; '1 As H'; '1 H O'; '1 H S'; '1 H Se'; '1 H Te'; ...
    '1 F H'; '1 Cl H'; '1 Br H'; '1 H I'; '1 B B'; '1 B O'; '1 B F'; ...
    '1 B Cl'; '1 B Br'; '1 C C'; '2 C C'; '3 C C'; '1 C Si'; '1 C Ge'; ...
    '1 C Sn'; '1 C Pb'; '1 C N'; '2 C N'; '3 C N'; '1 C P'; '1 C O'; ...
    '2 C O'; '3 C O'; '1 C B'; '1 C S'; '2 C S'; '1 C F'; '1 C Cl'; ...
    '1 C Br'; '1 C I'; '1 Si Si'; '1 N Si'; '1 O Si'; '1 S Si'; ...
    '1 F Si'; '1 Cl Si'; '1 Br Si'; '1 I Si'; '1 Ge N'; '1 F Ge'; ...
    '1 Cl Ge'; '1 Br Ge'; '1 Ge I'; '1 F Sn'; '1 Cl Sn'; '1 Br Sn'; ...
    '1 I Sn'; '1 N P'; '1 F Pb'; '1 Cl Pb'; '1 Br Pb'; '1 I Pb'; ...
    '1 N N'; '2 N N'; '3 N N'; '1 N O'; '2 N O'; '1 F N'; '1 Cl N'; ...
    '1 P P'; '1 O S'; '1 O P'; '2 O P'; '2 P S'; '1 F P'; '1 Cl P'; ...
    '1 Br P'; '1 I P'; '1 As As'; '1 As O'; '1 As F'; '1 As Cl'; ...
    '1 As Br'; '1 As I'; '1 Sb Sb'; '1 F Sb'; '1 Cl Sb'; '1 O O'; ...
    '2 O O'; '1 F O'; '2 O S'; '1 S S'; '2 S S'; '1 F S'; '1 Cl S'; ...
    '1 Se Se'; '2 Se Se'; '1 F F'; '1 Cl Cl'; '1 Br Br'; '1 I I'; ...
    '1 At At'; '1 I O'; '1 F I'; '1 Cl I'; '1 Br I'; '1 F Kr'; '1 O Xe';...
    '1 F Xe'};
bondsEnergy = [432; 389; 411; 318; 288; 251; 386; 322; 247; 459; 363; ...
    276; 238; 565; 428; 362; 295; 293; 536; 613; 456; 377; 346; 602; ...
    835; 318; 238; 192; 130; 305; 615; 887; 264; 358; 799; 1072; 356; ...
    272; 573; 485; 327; 285; 213; 222; 355; 452; 293; 565; 381; 310; ...
    234; 188; 257; 470; 349; 276; 414; 323; 237; 205; 210; 331; 243; ...
    201; 142; 167; 418; 942; 201; 607; 283; 313; 201; 1; 335; 544; ...
    335; 490; 326; 264; 184; 146; 301; 484; 322; 458; 200; 121; 440; ...
    248; 142; 494; 190; 522; 226; 425; 284; 255; 172; 272; 155; 240; ...
    190; 148; 116; 201; 273; 208; 175; 50; 84; 130]; % kJ/mol

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
modeltmp = findSExRxnInd(model,[], printLevel);
exIdx = modeltmp.ExchRxnBool;
clear modeltmp

% Calculate enthalpy change
[allSubstrateMass, enthalpyChange] = deal(zeros(size(rxnList)));
unbalancedBool = false(size(rxnList));
for i = 1:size(rxnList, 1)
    
    clearvars -except unbalanced enthalpyChange exIdx atomicWeight atomicElements ...
        printLevel bondsEnergy bondsArray rxnDir model i rxnList ...
        unbalancedBool allSubstrateMass unbalancedBool
    
    substrateMass = 0;
    rxnFile = [rxnDir rxnList{i} '.rxn'];
    
    % Check if the file exists
    if isfile(rxnFile) && ~exIdx(i)
        
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
                
                enthalpyChange(i, 1) = 0;
                
                % No bonds in the product(s)
            case 1
                for j = 1 : length(bondTypeS)
                    
                    % Looks for the avarage energy of a chemical bond based on the literature
                    matrixS_enthalpy(rowS(j), colS(j)) = findBondEnergy([bondTypeS(j) elementsS(rowS(j)) elementsS(colS(j))], bondsArray, bondsEnergy);
                    matrixS_enthalpy(colS(j), rowS(j)) = findBondEnergy([bondTypeS(j) elementsS(rowS(j)) elementsS(colS(j))], bondsArray, bondsEnergy);
                end
                matrixP_enthalpy = zeros(length(matrixS_enthalpy));
                matrixP_BBF = zeros(length(matrixS_BBF));
                
                % No bonds in the substrate(s)
            case 2
                for j = 1 : length(bondTypeP)
                    matrixP_enthalpy(rowP(j), colP(j)) = findBondEnergy([bondTypeP(j) elementsP(rowP(j)) elementsP(colP(j))], bondsArray, bondsEnergy);
                    matrixP_enthalpy(colP(j), rowP(j)) = findBondEnergy([bondTypeP(j) elementsP(rowP(j)) elementsP(colP(j))], bondsArray, bondsEnergy);
                end
                matrixS_enthalpy = zeros(length(matrixP_enthalpy));
                
                % Bonds for substrate(s) and product(s)
            case 3
                for j = 1 : length(bondTypeS)
                    matrixS_enthalpy(rowS(j), colS(j)) = findBondEnergy([bondTypeS(j) elementsS(rowS(j)) elementsS(colS(j))], bondsArray, bondsEnergy);
                    matrixS_enthalpy(colS(j), rowS(j)) = findBondEnergy([bondTypeS(j) elementsS(rowS(j)) elementsS(colS(j))], bondsArray, bondsEnergy);
                end
                for j = 1 : length(bondTypeP)
                    matrixP_enthalpy(rowP(j), colP(j)) = findBondEnergy([bondTypeP(j) elementsP(rowP(j)) elementsP(colP(j))], bondsArray, bondsEnergy);
                    matrixP_enthalpy(colP(j), rowP(j)) = findBondEnergy([bondTypeP(j) elementsP(rowP(j)) elementsP(colP(j))], bondsArray, bondsEnergy);
                end
                if length(matrixS_enthalpy) ~= length(matrixP_enthalpy)
                    if length(matrixS_enthalpy) > length(matrixP_enthalpy)
                        matrixP_enthalpy(length(matrixS_enthalpy),length(matrixS_enthalpy)) = 0;
                    else
                        matrixS_enthalpy(length(matrixP_enthalpy),length(matrixP_enthalpy)) = 0;
                    end
                end
                
        end
        if exist('matrixS_enthalpy', 'var') && exist('matrixP_enthalpy', 'var')
            
            totalMatrix = matrixS_enthalpy - matrixP_enthalpy;
            enthalpyChange(i) = sum(totalMatrix(find(totalMatrix))) / 2;
            
        end
        
    elseif exIdx(i)
        
        % Mass inbalanced reactions equal to zero
        enthalpyChange(i, 1) = 0;
        
    else
        
        % Missing RXN file equal to NaN
        enthalpyChange(i, 1) = NaN;
        if printLevel > 0
            allSubstrateMass(i) = NaN;
        end
        
    end
    
    % Assing substrateMass
    allSubstrateMass(i, 1) = substrateMass;
end

% Consider unbalanced as missing
enthalpyChange(unbalancedBool) = NaN;

if printLevel > 0
    [mass, idx] = sort(allSubstrateMass);
    figure
    scatter(mass, enthalpyChange(idx), 'filled')
    be = enthalpyChange(idx);
    mass1 = mass;
    mass1(isnan(be) | isnan(mass)) = [];
    be(isnan(be) | isnan(mass)) = [];
    title({'Total mass of substrates vs bond', 'enthalpies', ...
        ['Correlation = ' num2str(round(corr(mass1, abs(be),'Type','Spearman'), 2))]}, 'FontSize', 20)
    ylabel('Enthalpy change (kJ/mol)', 'FontSize', 18)
    yline(0)
    xlabel('Mass of substrates (amu)', 'FontSize', 18)
    
end
substrateMass = allSubstrateMass;
end

function bondsEnergy = findBondEnergy(bondArray, bondsArray, bondsEnergy)
% Looks for the avarage energy of a chemical bond

% Missing: bonds with R groups, '1 C Se', '1 N S', '1 O Se', '2 O Se', '1
% Br C', '1 Cl O', '2 P Se'

bondArray = strjoin(sort(bondArray));
bondIdx = find(ismember(bondsArray, bondArray));

if ~isempty(bondIdx)
    bondsEnergy = bondsEnergy(bondIdx);
else
    bondsEnergy = NaN;
end

end
