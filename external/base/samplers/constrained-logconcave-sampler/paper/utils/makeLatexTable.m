function [text] = makeLatexTable(col_headers, row_headers, data,caption,label)
%MAKELATEXTABLE data is a r x c size matrix. col_headers is a cell array of
%length c. row_headers is a cell array of length r.
%
%this function returns a string of latex code that represents the table of
%data

if nargin < 4
   caption = 'caption'; 
end
if nargin < 5
    label = 'label';
end

c = length(col_headers);
r = length(row_headers);
assert(c==size(data,2) && r==size(data,1));

text = initTableCode(caption,label);
text = strcat(text,'{',repmat('|c',1,c+1),'|}\n');
text = strcat(text,'\\hline \n');
%first do the column headers
for i=1:c
    text = strcat(text,'& ',col_headers{i});
end

text = strcat(text,'\\\\ \n');
text = strcat(text,'\\hline \n');
%now do table data

for i=1:r
    text = strcat(text,row_headers{i});
    
    for j=1:c
       text = strcat(text,' & ', num2str(data(i,j))); 
    end
    text = strcat(text,'\\\\ \n');
    text = strcat(text,'\\hline \n');
end

text = strcat(text,'\\end{tabular}\n\\end{table}\n');

end

function [text] = initTableCode(caption, label)
text = '\\begin{table}[]\n\\centering\n\\caption{';
text = strcat(text,caption);
text = strcat(text,'}\n\\label{');
text = strcat(text,label);
text = strcat(text,'}\n\\begin{tabular}');

end