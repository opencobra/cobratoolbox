function [bonds,nAtoms] = extractBondsFromMol(molname)
%extract the information on the bonds within a mol file
%
%INPUT
% molname   name of mol file (without .mol suffix)
%
%OUTPUT
% bonds     Bond block (1 row for each bond): 1st atom, 2nd atom, bond type
% nAtoms    number of atoms in mol file

fid=fopen([molname '.mol']);

%header
tline = fgetl(fid);
tline = fgetl(fid);
tline = fgetl(fid);

%connection table header
remain = fgetl(fid);
[token1, remain] = strtok(remain);
nAtoms=str2num(token1);
[token2, remain] = strtok(remain);
nBonds=str2num(token2);

for n=1:nAtoms
    tline = fgetl(fid);
end

bonds=zeros(nBonds,3);
for n=1:nBonds
    remain = fgetl(fid);
    [token1, remain] = strtok(remain);
    bonds(n,1)=str2num(token1);
    [token2, remain] = strtok(remain);
    bonds(n,2)=str2num(token2);
    [token3, remain] = strtok(remain);
    bonds(n,3)=str2num(token3);
end

fclose(fid);
    
