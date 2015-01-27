function atomMappings=readAtomMapping(filename)
%read in an atom mapping matrix from a file

fid = fopen(filename);

tline = fgetl(fid);
nMapping=1;
while ischar(tline)
    if ~strcmp(tline(1),'#') %ignore mappings with # in front
        
        remain=tline;
        
        numAtoms=1;
        while ~strcmp(remain,'')
            [token1, remain] = strtok(remain,'[,]');
            [token2, remain] = strtok(remain,'[,]');
            [token3, remain] = strtok(remain,'[,]');
            if 0
                fprintf('%s%i\t%i\t%i\n','$',numAtoms,str2num(token1),str2num(token2));
            end
            atomMappings(numAtoms,2*nMapping-1)=str2num(token1);
            atomMappings(numAtoms,2*nMapping  )=str2num(token2);
            %increment
            numAtoms = numAtoms+1;
        end
        %increment
        nMapping=nMapping+1;
    end
    tline = fgetl(fid);
end

fclose(fid);
