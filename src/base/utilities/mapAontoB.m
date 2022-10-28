function Bout = mapAontoB(Akey,Bkey,Ain,Bin)

%LIBkey: an array of the same size as Bkey containing true where the elements of B are in A and false otherwise.
%LOCAkey: an array LOCB containing the lowest absolute index in Akey for each element in Bkey which is a member of Akey and 0 if there is no such index.
[LIBkey,LOCAkey] = ismember(Bkey,Akey);

if exist('Bin','var')
    Bout = Bin;
else
    classAin = class(Ain);
    switch classAin
        case 'cell'
            Bout=cell(length(Bkey),1);
        case 'double'
            Bout=sparse(length(Bkey),1)*NaN;
        case 'logical'
            Bout=false(length(Bkey),1);
        case 'int64'
            Bout=sparse(length(Bkey),1)*NaN;   
        otherwise
            error('unrecognised class')
    end
end

Bout(LIBkey) =  Ain(LOCAkey(LOCAkey~=0));

end

