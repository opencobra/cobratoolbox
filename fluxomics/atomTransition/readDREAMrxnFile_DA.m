function reactantMapping=readDREAMrxnFile_DA(filename,rxnFilePath)
%read a rxn file output from DREAM and generate reactantMapping structure
%
% reactantMapping                   #reactants x 1 struct array with fields (i = 1 ... #reactants):
% 
% reactantMapping(i).nAtoms         #atoms in ith reactant
%
% reactantMapping(i).nBonds         #bonds in ith reactant
%
% reactantMapping(i).atomBlock      #atom x 5 cell array with columns:
%                                   atomic symbol;atom-mapping number; x position, y position, z position
%
% reactantMapping(i).bondBlock      #bond x 3 numeric array with columns:
%                                   first atom number, second atom number, bond type
%
% reactantMapping.numSubstrates    #substrates in reaction (ignoring hydrogen)
% reactantMapping.numProducts      #products in reaction (ignoring hydrogen)
%                   
    
if ~exist('rxnFilePath','var')
    rxnFilePath=[pwd filesep];
end

filename2=[rxnFilePath filename];
fid=fopen(filename2,'r');
if fid==-1
    error(['File ' filename2 ' not found.']);
end

tline1 = fgetl(fid);
tline2 = fgetl(fid);
tline3 = fgetl(fid);
tline4 = fgetl(fid);

%TODO - better to have met ids in each mol file
rxnFormula = tline2;
mets = strtrim(regexp(rxnFormula,'\s[^\[\s]+\[\w\]','match'))';
stoichCoeffs = strtrim(regexp(rxnFormula,'\d*\s[^\[\s]+\[\w\]','match'))';
stoichCoeffs = regexp(stoichCoeffs,'\d*\s','match');

% nonH_bool = true(size(mets));
% hidx = strmatch('h[',mets);
% nonH_bool(hidx) = false;
% mets = mets(nonH_bool);
% stoichCoeffs = stoichCoeffs(nonH_bool);

repBool = ~cellfun('isempty',stoichCoeffs);
if any(repBool)
    metAbbr = {};
    for i = 1:length(mets)
        stoichCoeff = stoichCoeffs{i};
        if ~isempty(stoichCoeff)
            stoichCoeff = str2double(stoichCoeff{:});
            metAbbr = [metAbbr; repmat(mets(i),stoichCoeff,1)];
        else
            metAbbr = [metAbbr; mets(i)];
        end
    end
else
    metAbbr = mets;
end

%number substrates and products
% [nReactants,count]=fscanf(fid,'%3d',2);
% numSubstrates=nReactants(1);
% numProducts=nReactants(2);
% tline = fgetl(fid);
% More robust code:
tline = fgetl(fid);
numSubstrates = str2double(tline(1:3));
numProducts = str2double(tline(4:6));


reactantMapping.numSubstrates=numSubstrates;
reactantMapping.numProducts=numProducts;

for n=1:numSubstrates+numProducts
    dollarMol = fgetl(fid);
    if ~strcmp(dollarMol,'$MOL')
        disp(dollarMol)
        error('not the start of a mol file')
    end
    [atomBlock,bondBlock,nAtoms,nBonds,nonHformula]=readMolFile(fid);
    reactantMapping(n,1).metAbbr=metAbbr{n};
    reactantMapping(n,1).atomBlock=atomBlock;
    reactantMapping(n,1).bondBlock=bondBlock;
    reactantMapping(n,1).nAtoms=nAtoms;
    reactantMapping(n,1).nBonds=nBonds;
    reactantMapping(n,1).nonHformula=nonHformula;
end

