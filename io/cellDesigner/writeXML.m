function [annotedText] = writeXML(fname,parsed,fname_out)


% example:  aaa=writeXML('PD_140620_1.xml',parsePD,'text.html')

% ref - A matlab variable that stores the number of the lines

% fanme_out - the output file name.

% annotedText - A matla variable storing the XML lines
%%%%%%%%%%%%%%%%%%%%%%%%  open


% if nargin<4
% var='m'
% else
%     fba_sol
%  if strcmp(var,'m');


if nargin<3 || isempty(fname_out)    
    
    [fname_out, fpath]=uiputfile('*.xml','CellDesigner SBML Source File');
    if(fname_out==0)
        return;
    end
    f_out=fopen([fpath,fname_out],'w');
else
    f_out=fopen(fname_out,'w');
end

if nargin<1 || isempty(fname)
    [fname, fpath]=uigetfile('*.xml','CellDesigner SBML Source File');
    if(fname==0)
        return;
    end
    f_id=fopen([fpath,fname],'r');
else
    f_id=fopen(fname,'r');
    
end

numOfLine=0;
%test=[];
text.str=[];

while ~feof(f_id);
    numOfLine=numOfLine+1;
    
    rem=fgets(f_id);
    
    text(numOfLine).str=cellstr(rem);
        
end

fclose(f_id);

%%%%%%%%%%%%%%%%%%%%%%%%  modify

ref=readCD(parsed); %% read the the list of the reactions and associated information.
% ref=parsed.r_info;


r_c=size(ref.number)

%while ~feof(f_id);

%numOfLine=0;
%rem=fgets(f_id);numOfLine=numOfLine+1;

items={'width','color'};

for r=1:r_c(1,1); % the row number; the reaction number.
    
    
    for c=1:r_c(1,2); % the column number
        % numOfLine=numOfLine+1;
        %disp(numOfLine);
        
        if isnumeric(ref.number(r,c))&&ref.number(r,c)>0;
            num=ref.number(r,c) % the pre-identified row number 
            %%% <read>    
            
            
            %%
            for i=1:length(items); % the first round sets 'width'; the second round sets 'color'.
     
                subText=ref.(items{i})(r,c);                
                %%% <write>
                reText=cellstr(text(num).str)
                                
                %%% find the text that will be replaced.
                %             ind_rem_width=strfind(reText,'width');
                %               %  disp(rem);
                %                % disp(ind_rem_width);
                %
                %                 % r_metaid.width(r_num,1)=cellstr(rem);
                %
                %                % try
                %
                %                 p_st_w=ind_rem_width{1}+7;
                %                % catch
                %                    % disp(ind_rem_width);
                %                % end
                %
                %                %try
                %                 endpos_w=strfind(reText{1}(p_st_w:end),'"');
                %               % catch
                %                    disp(endpos_w)
                %              %  end
                %              %  try
                %                 p_et_w=endpos_w(1)+p_st_w-2;
                %
                %              %  catch
                %                    disp(endpos_w)
                %               % end
                %
                %
                %                % p_et_w=ind_rem_width(2)-1;
                %                % r_info.width(r_num,numbOfWidth)=cellstr(rem(p_st_w:p_et_w));
                %                 ToBeRplaced=reText{1}(p_st_w:p_et_w)
                
                %%% find location and replace it
                
             ToBeRplaced=position(reText,items{i})
                %%%                
                %try
                if ~isstr(subText{1})  % test if subText{1} contains a string
                   warning('OK');
                   disp(subText{1});
                   subText{1}=num2str(subText{1}) % convert the double type into string type
                end
                
                text(num).str=strrep(text(num).str,ToBeRplaced,subText{1}) %% or subText{1}, exchangeable here.
                %catch
                
                disp(subText{1});
                
              % end
                
                % disp([numOfLine,subText,ToBeRplaced,text(numOfLine).str]);
                     
                %disp(text(num).str);
                %disp(subText);
            end
            
        end
    end
end

% if isfield(ref,'species');
%     
%     for line=1:length(text);
%         
%         reText=cellstr(text(line).str)
%         for nn=1:length(ref.species(:,1))
%             if ~isempty(ref.species{nn,3})
%                 if strcmpi(text(line),ref.species{nn,1});
%                     ToBeRplaced=position(reText,' name')
%                     %ToBeRplaced=ref.species{nn,3};
%                     text(line).str=strrep(text(num).str,ToBeRplaced,ref.species{nn,3})
%                     fprintf('original text is %s and is replaced with %s',ToBeRplaced,ref.species{nn,3});
%                 end
%             end
%         end
%         
%     end
% else
%     warning('cannot find the field name ''species''');
% end




annotedText=text;




%%%%%%%%%%%%%%%%%%%%%%%%  write

for d=1:length(text);
    
    fprintf(f_out,'%s\n',char(text(d).str));
    
end

fclose(f_out);


end






