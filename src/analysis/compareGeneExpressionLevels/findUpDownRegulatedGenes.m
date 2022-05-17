function result = findUpDownRegulatedGenes(source, target, trDataPath)
    try
        cnt = 1;
        sourceDataSetName = char(source);
        targetDataSetName = char(target);
        trSource=readtable(trDataPath,'Sheet',sourceDataSetName); 
        trTarget=readtable(trDataPath,'Sheet',targetDataSetName);
        
        for i=1:1:height(trSource)
            result{cnt,1} = trSource.Geneid{i};
            result{cnt,2} = trSource.Data(i);
            result{cnt,3} = trTarget.Data(i);
            if trSource.Data(i) > trTarget.Data(i)
                result{cnt,4} = 'Down';
            elseif trSource.Data(i) < trTarget.Data(i)
                result{cnt,4} = 'Up';
            else
                result{cnt,4} = 'Equal';
            end
            cnt = cnt + 1;
        end
    catch e
        disp(e);
    end
end