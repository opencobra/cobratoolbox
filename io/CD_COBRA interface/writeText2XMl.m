function [ text ] = writeText2XMl( text, fname_out )
%WRITETEXT2XML Summary of this function goes here
%   text=writeText2XMl( text, fname_out )




if nargin<2 || isempty(fname_out)    
    
    [fname_out, fpath]=uiputfile('*.xml','CellDesigner SBML Source File');
    if(fname_out==0)
        return;
    end
    f_out=fopen([fpath,fname_out],'w');
else
    f_out=fopen(fname_out,'w');
end


for d=1:length(text);
    
    fprintf(f_out,'%s\n',char(text(d).str));
    
end

fclose(f_out);


end


