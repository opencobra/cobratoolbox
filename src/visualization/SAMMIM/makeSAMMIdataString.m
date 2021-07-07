function tblstring = makeSAMMIdataString(tbl)
    tblstring = '[[''';
    
    %Headers
    tblstring = strcat(tblstring,strjoin(tbl.Properties.VariableNames,''','''),'''],');
    
    %Data
    dat = table2array(tbl);
    
    %Make key string
    fun = @(a) strjoin(sprintfc('%g',a{1}),'","');
    fd = arrayfun(fun,num2cell(dat,2),'UniformOutput',false);
    fd = strcat('["',tbl.Properties.RowNames,'","',fd,'"]');
    tblstring = strcat(tblstring,strjoin(fd,','),']');
end