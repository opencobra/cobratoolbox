function [isSameModel,differences] = compareModels(modelA,modelB,printLevel)
%compares modelA with modelB, looking for differences between the
%structures
%
% INPUT
% modelA:       structure
% modelB:       structure
% printLevel:    
%
% OUTPUT
% isSameModel:   true if identical models, false otherwise
% differences:   structure listing differences between models
%               *.reason: gives a text stack of why the difference occurred
%                         as well as a field
%               *.where: contains the indices and subfields of the structure
%                        where the comparison failed.
%
%
% Note: This function depends on structeq.m and celleq.m

if~exist('printLevel','var')
    printLevel=1;
end

differences=[];
result = 0;
i=0;
while result==0
    [result, why] = structeq(modelA,modelB);
    if result==0
        i=i+1;
        if printLevel>0
            fprintf('%s\n',why.Reason)
            fprintf('%s\n',why.Where)
        end
        differences(i).reason = why.Reason;
        differences(i).where = why.Where;
        %fieldName = strrep(why.Where,'(1)','');
        fieldName = strtok(why.Where,'(1)');
        eval(['modelB' fieldName ' = modelA' fieldName ';']);
    end
end
isSameModel = i==0;

end

