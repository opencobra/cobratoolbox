function [ ref,d] = addColour( parsed,listRxn_Color)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% written by Longfei Mao
ref=parsed;


listRxn=listRxn_Color(:,1); % coloumn 1: reaction IDs;
a=size(listRxn_Color)

if length(a)<2
    listColor=[];
    
    listColor=listRxn_Color(:,2); % coloumn 2: html colour codes;
    p=1;
else
    p=0;
end






for r=1:length(listRxn);
    
    newRxnName=listRxn{r};
    
    if ~isfield(ref,listRxn{r})
        
        newRxnName=strcat('R_',listRxn{r});
        if  isempty(strfind(newRxnName,'(e)'))
            newRxnName=strrep(newRxnName,'(e)','_e');
        end
        
    end
    if ~isfield(ref,newRxnName)
        disp(listRxn{r});
        fprintf('error ! the listRxn{%d}',r);
        r=r+1
    else
        [rw,cw]=size(ref.(newRxnName).color)
        
        for  ddr=1:rw
            
            if ischar(ref.(newRxnName).width{ddr,1}) % if it is char such as ('1.0');then convert it into double;
                ref.(newRxnName).width{ddr,1}=str2double(ref.(newRxnName).width{ddr,1})
            end
%                 try
            w(1)=ref.(newRxnName).width{ddr,1}
%             catch
% %                 disp(w(1))
%                  disp(newRxnName);
%                 disp(ref.(newRxnName).width{ddr,1});
%             end
            
            %disp(ref.(newRxnName).width(ddr,1));disp('dddd');
            %disp(w(1));
            %              if isempty(w)
            %                  w=0;
            %              end
            %

                fprintf('w value is %d\n',w(1));
            if w(1)>1&&w(1)<=10;  % flux ranges from 2 to 10 will be highligthed
                
                if p==0;
                    if w(1)<=5  % flux below 5 will be highlighted in blue.
                        colorStr='#FF0000FF'
                   else
                        
                        colorStr='#FFFF0000'; %'#EFDECD';% flux below 5 will be highlighted in red.
                    end
                    
                elseif p==1
                    colorStr=listColor{ddr};  % ddr is the row number for each reaction;
                end
                fprintf('p value is %d\n',p);
                     colorStr=strrep(colorStr,'#','');
                    fprintf('colorStr is %s\n',colorStr);               
                
                for  ddc=1:cw
   
                    ref.(newRxnName).color{ddr,ddc}=colorStr;
                    fprintf('set %s ''s colour to %d \n',newRxnName,ref.(newRxnName).color{ddr,ddc});
                end
            end
   
            
        end
        
    end
    
    
    
    
    
end


