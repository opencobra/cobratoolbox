function MMN = generateMoietyMoleculeNetwork(model,L,moietyFormulae,mbool)
%Generate a structure to represent a network that associates moieties to molecules

[nMet,~]=size(model.S);
[nMoieties, nMappedMet] = size(L);

if ~exist('mbool','var')
    if nMet==nMappedMet
        mbool=true(nMet,1);
    else
        if nMet==nMoieties
            L=L';
            [nMoieties, nMappedMet] = size(L);
        else
            error('mbool must be provided if the number of columns of L is different from the number of rows of model.S')
        end
    end
else
    if nMappedMet~=nnz(mbool)
        if nMoieties==nnz(mbool)
            L=L';
            [nMoieties, nMappedMet] = size(L);
        else
            error('mbool must have the same number of nonzeros as the number of columns of L')
        end
    end
end

MMN=struct();

MMN.L = L;

%order of the numbers matches the order of the rows of L
moietyID = zeros(nMoieties,1);
for i=1:nMoieties
    moietyID(i) = i;
end

moietyFormulae = hillformula(moietyFormulae);

isotopeAbundance = 0; %use polyisotopic inexact mass i.e. uses all isotopes of each element weighted by natural abundance 
generalFormula = 1; %NaN for unknown elements
[moietyMasses, knownMasses, unknownElements, Ematrix, elements] = getMolecularMass(moietyFormulae,isotopeAbundance,generalFormula);

NumMolecules = sum(L,2);

%table of moiety properties
MMN.moi = table(moietyID,moietyFormulae,moietyMasses,NumMolecules,'VariableNames',{'Name','Formula','Mass','NumMolecules'});

if 0
    %     Error using parse_formula>parse_formula_ (line 197)
    %     Could not parse formula:
    %     C30H56NO12FULLRCO
    %     ^^^
    molFormulae = hillformula(model.metFormulas(mbool));
else
    molFormulae = model.metFormulas(mbool);
end

%order of the numbers matches the order of the columns of L
molID = zeros(nMappedMet,1);
for i=1:nMappedMet
    molID(i) = i;
end

[molecularMasses, knownMasses, unknownElements, Ematrix, elements] = getMolecularMass(model.metFormulas(mbool),isotopeAbundance,generalFormula);

NumMoieties = sum(L,1)';

%table of molecule properties
MMN.mol = table(molID,model.mets(mbool),molFormulae,molecularMasses,NumMoieties,'VariableNames',{'Name','Mets','Formula','Mass','NumMoieties'});

end

