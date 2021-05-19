function parsevec = makeSAMMIparseVector(dat)
    if ismember('flux',fields(dat))
        for i = 1:length(dat)
            if isempty(dat(i).flux)
                dat(i).flux = NaN(length(dat(i).rxns),1);
            end
        end
        tmp = arrayfun(@(x) strcat('["',x.name,'",',strjoin(strcat('["',x.rxns,'","',sprintfc('%g',x.flux),'"]'),','),']'),dat,'UniformOutput',false);
    else
        tmp = arrayfun(@(x) strcat('["',x.name,'",',strjoin(strcat('["',x.rxns,'"]'),','),']'),dat,'UniformOutput',false);
    end
    %Finalize
    tmp = strjoin(tmp,',');
    parsevec = strcat('[',tmp,']');
end
























