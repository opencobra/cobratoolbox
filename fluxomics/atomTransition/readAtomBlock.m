function atomBlock=readAtomBlock(fid,nAtoms)
%read an atom block from a mol file and return the data as a cell file

atomBlock=cell(nAtoms,5);

%format:
%xxxxx.xxxxyyyyy.yyyyzzzzz.zzzz aaaddcccssshhhbbbvvvHHHrrriiimmmnnneee

for n=1:nAtoms
    %atom coordinates
    [xyz,count]=fscanf(fid,'%10g',3);
    atomBlock{n,3}=xyz(1);
    atomBlock{n,4}=xyz(2);
    atomBlock{n,5}=xyz(3);
    %space
    [space,count]=fscanf(fid,'%1c',1);
    %atom symbol
    [aaa,count]=fscanf(fid,'%3c',1);
    atomSymbol = strtok(aaa, ' ');
    atomBlock{n,1}= atomSymbol;
    %mass difference
    [dd,count]=fscanf(fid,'%2c',1);
    %charge
    [ccc,count]=fscanf(fid,'%3c',1);
    %atom stereo parity
    [sss,count]=fscanf(fid,'%3c',1);
    %hydrogen count +1
    [hhh,count]=fscanf(fid,'%3c',1);
    %stereo care box
    [bbb,count]=fscanf(fid,'%3c',1);
    %valence
    [vvv,count]=fscanf(fid,'%3c',1);
    %H0 designer
    [HHH,count]=fscanf(fid,'%3c',1);
    %not used
    [rrr,count]=fscanf(fid,'%3c',1);
    %not used
    [iii,count]=fscanf(fid,'%3c',1);
    %atom-mapping number
    [mmm,count]=fscanf(fid,'%3d',1);
    atomBlock{n,2}=mmm;
    %inversion/retention flag
    [eee,count]=fscanf(fid,'%3c',1);
    %exact change flag
    [nnn,count]=fscanf(fid,'%3c',1);
    tline = fgetl(fid);
end