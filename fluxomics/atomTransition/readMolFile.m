function [atomBlock,bondBlock,nAtoms,nBonds,nonHformula]=readMolFile(filename)
%read an MDL mol file 

if ~ischar(filename)
    fid=filename;
else
    fid=fopen(filename,'r');
end

tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);
%The Counts Line
%aaabbblllfffcccsssxxxrrrpppiiimmmvvvvvv
% [x]=fscanf(fid,'%3d',length('aaabbblllfffcccsssxxxrrrpppiiimmmvvvvvv'));
% nAtoms=x(1);
% nBonds=x(2);
% tline = fgetl(fid);
% The above (fscanf) failed in at least one case where the Counts Line was
% ' 96100  0  0  0  0            999 V2000' (for HC01609.mol in Recon 2)
tline = fgetl(fid);
nAtoms = str2double(tline(1:3));
nBonds = str2double(tline(4:6));

%read atom Block
atomBlock=readAtomBlock(fid,nAtoms);

%chemical nonHformula
allBiologicalElements={'C','H','O','P','N','S','Mg','Na','K','Cl','Ca','Zn','Fe','Cu','Mo','I'};
numBiologicalElements=zeros(length(allBiologicalElements),1);
for n=1:size(atomBlock,1)
    bool=strcmp(atomBlock{n,1},allBiologicalElements);
    if any(bool)
        numBiologicalElements(bool)=numBiologicalElements(bool)+1;
    else
        error('no matchin element symbol found');
    end
end
nonHformula='';
for n=1:length(allBiologicalElements)
    if numBiologicalElements(n)~=0
        if numBiologicalElements(n)==1
            nonHformula=[nonHformula allBiologicalElements{n}];
        else
            nonHformula=[nonHformula allBiologicalElements{n} int2str(numBiologicalElements(n))];
        end
    end
end
    

%read bond Block
bondBlock=readBondBlock(fid,nBonds);

%last lines
token='';
k=1;
while ~strcmp(tline,'M  END')
    tline   = fgetl(fid);
    k=k+1;
    if k==1000
        disp(tline)
        error('not the end of the molecule file')
    end
end