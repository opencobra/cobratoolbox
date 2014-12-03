function [text]=writeTXT (para,fname_out)
 
%% Input

% para is a variable that stores two columns: a list of reaction name, and
% a list of colours.
% para(c,1)='name'; 
% para(c,2)='color';

% color - Hex triplet;


%%%%%%%%%%%%%%%%%%%%%%%%  open

if nargin<3 || isempty(fname_out)

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
if strfind(para{1,2},'#');
   r=r+1;
    s=2; 
    text{1,1}=['name',' ', 'color']; % add title row;
else
    s=1;r=r+1;
end

for rr=s:r; % content rows + one title row
    name=para{rr-1,1};
    color=para{rr-1,2};
%     if rr==s;
%         text{1,1}=['name',' ', 'color'];
% 
%     else
        text{rr,1}=[name,' ',color];

%     end

end

%%%%%%% Write


for d=1:length(text);
    
    fprintf(f_out,'%s\n',text{d});
    
end

fclose(f_out);


end