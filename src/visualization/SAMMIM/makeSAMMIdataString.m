function tblstring = makeSAMMIdataString(tbl)
% Converts a data table into the array-string format used by the SAMMI
% front-end to receive flux, concentration, or width data
%
% USAGE:
%
%    tblstring = makeSAMMIdataString(tbl)
%
% INPUT:
%    tbl:          MATLAB table with fields:
%
%                    * .Properties.VariableNames - condition names, one
%                      column of numeric data per condition
%                    * .Properties.RowNames - reaction or metabolite
%                      identifiers, one per row
%
% OUTPUT:
%    tblstring:    Character array encoding `tbl` as the nested array
%                  string `[[headers],[rowName,val1,val2,...],...]` used
%                  by the SAMMI front-end

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