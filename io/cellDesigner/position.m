function [string,p_st,p_ed]=position(str_long,str_ID)
%
% Retrieve the value of an attribute (str_ID) in the line (str_long) of the
% XML file and identify the starting and ending indices of the value in the
% attribute line of the XML file.
%
% INPUTS
% 
% str_long       A string of the line of the XML file
% str_ID         The name of the attribute
%
% OUTPUTS
%
% string        The value of the attribute 
% p_st          The starting index of the value
% p_ed          The ending index of the value
%
%
% Longfei Mao Oct/2014

%% name='metaid';

        ind_pos=strfind(str_long,str_ID);
        l=length(str_ID)+2;       
        p_st=ind_pos{1}+l
       % end_rem=strfind(str_long{1}(ind_pos{1}:end),'"');
        end_rem=strfind(str_long{1}(p_st:end),'"');
        % disp(str_long{1}(ind_pos{1}:end));
        disp(str_long{1}(p_st:end));
        
%         if size(end_rem)
%         end_rem{1}=[];
%         end
        
        p_ed=end_rem(1)+p_st-2;
        disp(p_ed);

        
       string=str_long{1}(p_st:p_ed);
        
end


