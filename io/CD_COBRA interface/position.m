function [string,p_st,p_ed]=position(str_long,str_ID)
%% name='metaid';

        ind_pos=strfind(str_long,str_ID);
        l=length(str_ID)+2;       
        p_st=ind_pos{1}+l
       % end_rem=strfind(str_long{1}(ind_pos{1}:end),'"');
        end_rem=strfind(str_long{1}(p_st:end),'"');
        % disp(str_long{1}(ind_pos{1}:end));
        disp(str_long{1}(p_st:end));
        p_ed=end_rem(1)+p_st-2;
        disp(p_ed);

        
       string=str_long{1}(p_st:p_ed);
        
end


