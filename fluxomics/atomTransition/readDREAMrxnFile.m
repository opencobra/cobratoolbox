function reactantMapping=readDREAMrxnFile(filename,rxnFilePath)
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
remain=tline4;
metAbbr={}; z=1;
stoichCoef=1;
while ~strcmp(remain,' ')
    [token, remain] = strtok(remain,' +<=>');
    if strcmp(token,'-')
        %this ignores the fucking - in the -> <-
        [token, remain] = strtok(remain,' +<=>');
    end
    if length(token)>1 || isletter(token(1))
        if stoichCoef==1
            %ignore hydrogen
            if ~strcmp('h[',token(1:2))
                metAbbr{z}=token;
                z=z+1;
            end
        else
            for n=1:stoichCoef
                if ~strcmp('h[',token(1:2))
                    metAbbr{z}=token;
                    z=z+1;
                end
            end
            stoichCoef=1;
        end
    else
        stoichCoef=str2num(token);
    end
    %disp(token)
end

%number of non hydrogen substrates and products
[nReactants,count]=fscanf(fid,'%3d',2);
numSubstrates=nReactants(1);
numProducts=nReactants(2);
tline = fgetl(fid);

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

