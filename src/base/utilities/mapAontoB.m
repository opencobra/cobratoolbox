function [Bout,LIBkey,LOCAkey] = mapAontoB(Akey,Bkey,Ain,Bin)
% Maps the data from Ain onto Bin by matching primary keys from Akey onto Bkey 
%
% USAGE:
%   [Bout,LIBkey,LOCAkey] = mapAontoB(Akey,Bkey,Ain,Bin)
%
% INPUTS:
%  Akey: m x 1 primary key in array or table Ain                    
%  Bkey: n x 1 primary key in array or table Bin 
%  Ain: m x z array or table 
%
% OPTIONAL INPUTS:
%  Bin: n x y array or table, which is created starting from Bkey if Bin is not provided.
%
%  Ain.Properties.VariableNames: required if Ain is a table
%
% OUTPUTS:
%  Bout:  n x y array or table, which is created starting from Bkey if Bin is not provided.
%  LIBkey:  n x 1 array of the same size as B containing true where the elements of B are in A and false otherwise. Output from [LIBkey,LOCAkey] = ismember(Bkey,Akey);         
%  LOCAkey: n x 1 array containing the lowest absolute index in A for each element in B which is a member of A and 0 if there is no such index.Output from [LIBkey,LOCAkey] = ismember(Bkey,Akey);          
%
% EXAMPLE:
%
% NOTE:
%
% Author(s):

if class(Akey)~=class(Bkey)
    error('class of Akey and Bkey must be the same')
end

if length(unique(Akey))~=length(Akey)
    error('mapAontoB assumes that each Akey entry is unique')
end

inputNameAkey = inputname(1);
inputNameBkey = inputname(2);

classAin = class(Ain);




%LIBkey: an array of the same size as Bkey containing true where the elements of B are in A and false otherwise.
%LOCAkey: an array LOCB containing the lowest absolute index in Akey for each element in Bkey which is a member of Akey and 0 if there is no such index.
[LIBkey,LOCAkey] = ismember(Bkey,Akey);

if exist('Ain','var')
    [~,nlt] = size(Ain);
    if exist('Bin','var')
        classBin = class(Bin);
        if classAin ~= classBin
            error('Class of Ain and Bin must be the same')
        end
        
        if isa(Ain,'table')
            if ischar(Bkey) && ischar(Akey)
                [Bout,ileft,iright] = outerjoin(Bin,Ain,'LeftKeys',Bkey,'RightKeys',Akey,'MergeKeys',1);
            else
                [Bout,ileft,iright] = outerjoin(Bin,Ain,'MergeKeys',1);
            end
            Bout=Bout(iright~=0,:);
        else
            Bout(LIBkey,:) =  Ain(LOCAkey(LOCAkey~=0),:);
        end
    else
        switch classAin
            case 'cell'
                Bout=cell(length(Bkey),nlt);
            case 'double'
                Bout=sparse(length(Bkey),nlt)*NaN;
            case 'logical'
                Bout=false(length(Bkey),nlt);
            case 'int64'
                Bout=sparse(length(Bkey),nlt)*NaN;
            case 'table'
                varTypes = cellfun(@ (x) class(Ain.(x)), Ain.Properties.VariableNames, 'UniformOutput', false);
                varNames = Ain.Properties.VariableNames;
                Bout = table('Size',[length(Bkey), size(Ain,2)],'VariableTypes',varTypes,'VariableNames',varNames);
                
            otherwise
                error('unrecognised class')
        end
        
        switch classAin
            case 'table'
                %Bout = Ain(LOCAkey(LOCAkey~=0),:);
                Bout(LIBkey,:) =  Ain(LOCAkey(LOCAkey~=0),:);
                %Bout(LIBkey,boolBin) =  Ain(LOCAkey(LOCAkey~=0),boolAin);
            otherwise
                Bout(LIBkey,:) =  Ain(LOCAkey(LOCAkey~=0),:);
        end
    end
else
    classAkey = class(Akey);
    switch classAkey
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
    Bout(LIBkey) =  Bkey(LIBkey(LOCAkey~=0));
end


end

