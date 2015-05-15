function [text]=writeTXT (para,fname_out)

% Write a txt file for online PD map to highlight specific reaction nodes.
%
%
% INPUTS
%
% para           A variable that stores two columns: the first column
%                contains a list of reaction names,whereas the second
%                column contains a corresponding list of the colours (Hex
%                triplet, e.g.,
%                https://closedxml.codeplex.com/wikipage?title=Excel%20Indexed%20Colors)
% fanme_out      The name of the output text file name.
%
% OPTIONAL OUTPUT
%
% text           The lines of the text file
%
% Longfei Mao Oct/2014
%



%%%%%%%%%%%%%%%%%%%%%%%%  open

if nargin<2 || isempty(fname_out)
    
    [fname_out, fpath]=uiputfile('*.txt','for Online PD map');
    if(fname_out==0)
        return;
    end
    f_out=fopen([fpath,fname_out],'w');
else
    f_out=fopen(fname_out,'w');
end


%%%%%%%%%%%% read

% blank={' '}
[r,c]=size(para)

if c==1;
    para(:,2)={'#FF0000FF'}; % By default, the colour hex code is set to be red.
end


if ~isempty(strfind(para{1,2},'#'))||~isempty(strfind(para{1,2},'FF'))
    r=r+1;
    s=2;
    text{1,1}=['name', ' ', 'color']; % add title row;
else
    s=1;r=r+1;
end

for rr=s:r; % content rows + one title row
    name=para{rr-1,1};
    
    if ~isempty(para{rr-1,2});
        color=para{rr-1,2};
        
        if length(color)>6;
            st=strfind(color,'FF');  % remove 'FF' necessary for CellDesigner files 
            if ~isempty(st)
                color=color(st+2:end);
            end
            if isempty(strfind(color,'#'));  % add # in front of the color code.
                color=['#',color];
                %errordlg('The format of the colour code is not correct');
            end
            
        end
        
    end
    
    %     if rr==s;
    %         text{1,1}=['name',' ', 'color'];
    %
    %     else
    text{rr,1}=[name,' ',color];
    
end

%%%%%%% Write to the file %%%%


for d=1:length(text);
    
    fprintf(f_out,'%s\n',text{d});
    
end

fclose(f_out);


end