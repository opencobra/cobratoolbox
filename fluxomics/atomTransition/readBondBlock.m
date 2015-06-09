function bondBlock=readBondBlock(fid,nBonds)
%read an atom block from a mol file and return the data as an array

bondBlock=zeros(nBonds,3);

%format:
%111222tttsssxxxrrrccc

for n=1:nBonds
    %atom numbers
    [firstAtomNumber,count]=fscanf(fid,'%3d',1);
    bondBlock(n,1)=firstAtomNumber;
    [secondAtomNumber,count]=fscanf(fid,'%3d',1);
    bondBlock(n,2)=secondAtomNumber;
    %bond type
    [ttt,count]=fscanf(fid,'%3d',1);
    bondBlock(n,3)=ttt;
    %bond stereo
    [sss,count]=fscanf(fid,'%3d',1);
    %not used
    [xxx,count]=fscanf(fid,'%3c',1);
    %bond topology
    [rrr,count]=fscanf(fid,'%3d',1);
    %reacting center status
    [ccc,count]=fscanf(fid,'%3d',1);
    tline = fgetl(fid);
end