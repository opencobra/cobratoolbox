function [annotation] = parseCD(fname)

%
% Parse an XML file into two types of CellDesigner model structures. The
% first type organises data by reaction; the second type organises data
% by property (namely, ID, width, colour, etc.)
%
%
%INPUT
%
% fanme               A CellDesigner XML file
%
%OUTPUTS
%
% annotation          The first type of the parsed model structure
% annotation.r_info   The second type of the parsed model structure
%
%EXAMPLES:
%
% example: parsePD=parseCD('PD_140620_1.xml')
% parsePD_1=parseCD('PD_140620_1.xml')
%
%
% Longfei Mao Oct/2014
%


if nargin<1 || isempty(fname)
    [fname, fpath]=uigetfile('*.xml','SBML Source File');
    if(fname==0)
        return;
    end
    f_id=fopen([fpath,fname],'r');
else
    f_id=fopen(fname,'r');

end



%%%%%%%%%%%%%%%%
% h = waitbar(0,'progressing')
%
% numlines = str2num( perl('countlines.pl',fname) );
% disp(numlines);
%%%%%%%%%%%%%%%%


% data=fread(fr)


%%%%%% defining the names of the interested nodes


toFD=[];
toFD.str=[];

% celldesigner nodes


toFD(1).str='<reaction ';   % starting line
toFD(2).str='</reaction>';  % ending line

toFD(3).str='celldesigner:line width';

toFD(4).str='<celldesigner:reactantLink';

toFD(5).str='<celldesigner:productLink';

%%% those information are yet to be retrieved later....:)

toFD(6).str='</celldesigner:connectScheme>';


toFD(7).str='<celldesigner:listOfModification>';

toFD(8).str='<celldesigner:baseReactant '
toFD(9).str='<celldesigner:baseProduct '

baseReactantAndProduct={'species','alias'};

reactantLink={'reactant','alias'};
productLink={'product','alias'};


%toFD(10).str='<celldesigner:species(\w*) id=' ;   %regular expression for '<celldesigner:speciesAlias'; '<celldesigner:species '

% expression=

%toFD(10).str='<species metaid='

toFD(10).str='<species (\w*)'; % A blank space before the (\w*).

%toFD(10).str='species(\w*)'

listID={' metaid', ' id', ' name'};% keywords in "<reaction "; NOTE: the blank space before each string is intended to distingush the difference between 'metaid' and 'id'

width_color={'width', 'color'}; % width and color of the reaction lines.

name={' id',' species',' name'};  % keywords in "<species "


% name={' id',' species'}; % for Recon2Map

% name={' name',' id'}   % blank space in front each keyword indicates that
% it is intact word, rather than part of the a long word such as "fullname"
% PD map (it doesn't matter what order the keywords appear.


% toFD(9).str=' alias'


% <celldesigner:baseReactant species="s1390" alias="sa248"/>



% strfind(':')+1



r_num=0;  % the number of reaction ID
r_species=0;

r_info.ID={};
r_info.width={};
r_info.color={};
r_info.reactant={};
r_info.product={};
% r_info.number=[];
% r_info.number.rxnNum=[]
r_info.species={};
erroMesg=cellstr('not found');

results=[];

numOfLineOfText=0;
text.str=[];
while ~feof(f_id);

    numOfLineOfText=1+numOfLineOfText;  % read next line.
    rem=fgets(f_id);

    text(numOfLineOfText).str=cellstr(rem)
end

frewind(f_id);

numOfLine=0;
rem=fgets(f_id);
numOfLine=numOfLine+1;

while ischar(rem) % &&r_num<10;
    line_st=strfind(rem,toFD(1).str);


    %   line_species=strfind(rem, toFD(10).str);
    line_species=regexpi(rem, toFD(10).str);
    nnew=1;name_new=[];
    for nna=1:length(name);
        str=strfind(rem,name{nna});
        if (~isempty(str))
            if nnew==1
                name_new{nnew,1}=name{nna};
                nnew=nnew+1;
            else
                ~isempty(strcmp(name_new(:,1),str));
                name_new{nnew,1}=name{nna};
                nnew=nnew+1;
            end
        end

    end



    disp(name_new);  %% construct of a new array of keywords


    %   if (~isempty(line_species))


    % starting module
    if (isempty(line_st))&&(isempty(line_species))

        rem=fgets(f_id);numOfLine=numOfLine+1;

    elseif (~isempty(line_species))
        r_species=r_species+1;           % the number of the "<reaction>".

        for d=1:length(name_new);

            [p_st_s,p_ed_s]=position(rem,name_new{d});

            r_info.species(r_species,d)=cellstr(rem(p_st_s:p_ed_s));
            % results.(r_info.ID{r_num,d}).name(1,2)=r_info.ID(r_num,3);  % retrive reaction name
        end
        rem=fgets(f_id);
        %spLine(r_species)=numOfLine

       r_info.species{r_species,5}=num2str(numOfLine); % record the number of the line that conatins species name.


       numOfLine=numOfLine+1;  % after recording the line number, the line number update incrementally

    elseif (~isempty(line_st))

        r_num=r_num+1;           % the number of the "<reaction>".
        %         ind_rem=strfind(rem,'metaid');
        %         p_st=ind_rem(1)+7;
        %         end_rem=strfind(rem(p_st:end),'"');
        %         p_ed=end_rem+p_st-2;
        [p_st,p_ed]=position(rem,listID{1}); %' metaid');

        r_info.ID(r_num,1)=cellstr(rem(p_st:p_ed));

        [p_st_2,p_ed_2]=position(rem,listID{2}); %' id');


        % r_info.ID(r_num,2)=cellstr(rem(ind_rem(3)+1:ind_rem(4)-1));

        r_info.ID(r_num,2)=cellstr(rem(p_st_2:p_ed_2));
        results.(r_info.ID{r_num,1}).name(1,1)=r_info.ID(r_num,2); % retrive ID


        if (strfind(rem,listID{3}))

            [p_st_3,p_ed_3]=position(rem,listID{3}); %' name');
            r_info.ID(r_num,3)=cellstr(rem(p_st_3:p_ed_3));
            results.(r_info.ID{r_num,1}).name(1,2)=r_info.ID(r_num,3);  % retrive reaction name

        end



        % numOfLine=1+numOfLine;
        % rem=fgets(f_id);
        numbOfWidth=0;% starting from 1;
        numbOfColor=0;


        numbOfreactant=1;
        numbOfproduct=1;


        numOfBase=1;
        numOfBaseP=1;

        line_ed=strfind(rem,toFD(2).str);



        numIndiv=0;


        %%%%


        while (isempty(line_ed));% &&r_num<10 ;  %% identifcation of the line width and colour


            numIndiv=numIndiv+1; % the number of the "<reaction>"; seems not to have a function here.

            rem=fgets(f_id);numOfLine=1+numOfLine;  % read next line.

            % numOfLine=1+numOfLine;  % the number of the ot

            %%%
            % r_info.number(r_num,1)=r_num;

            %%%

            %%%% find species and alias

            if (strfind(rem,toFD(8).str));  % <celldesigner:baseReactant species="s1390" alias="sa248"/>

                %% every new line

                for base=1:length(baseReactantAndProduct);


                    % if (strfind(rem,baseReactant{base})~=0)

                    [p_st,p_ed]=position(rem,baseReactantAndProduct{base});

                    r_info.baseReactant(r_num,numOfBase+base-1)=cellstr(rem(p_st:p_ed));
                    %     results.(r_info.ID{r_num,1}).baseReactant(1,r_num,numOfBase+base-1)=r_info.baseReactant(r_num,numOfBase+base-1)

                    % end
                end



                %  if isfield(r_info,baseReactant);
                results.(r_info.ID{r_num,1}).baseReactant(1,1:numOfBase+base-1)=r_info.baseReactant(r_num,1:numOfBase+base-1);
                %  end

                numOfBase=numOfBase+2;
            end
            if (strfind(rem,toFD(9).str));  % <celldesigner:baseReactant species="s1390" alias="sa248"/>

                %% every new line

                for base=1:length(baseReactantAndProduct);


                    % if (strfind(rem,baseReactant{base})~=0)

                    [p_st,p_ed]=position(rem,baseReactantAndProduct{base});

                    r_info.baseProduct(r_num,numOfBaseP+base-1)=cellstr(rem(p_st:p_ed));
                    %     results.(r_info.ID{r_num,1}).baseReactant(1,r_num,numOfBase+base-1)=r_info.baseReactant(r_num,numOfBase+base-1)

                    % end
                end



                %  if isfield(r_info,baseReactant);
                results.(r_info.ID{r_num,1}).baseProduct(1,1:numOfBaseP+base-1)=r_info.baseProduct(r_num,1:numOfBaseP+base-1);
                %  end

                numOfBaseP=numOfBaseP+2;
            end


            if (strfind(rem,toFD(3).str));     % finding width

                numbOfWidth=1+numbOfWidth;

                ind_rem_width=strfind(rem,width_color{1}); % 'width');
                %  disp(rem);
                % disp(ind_rem_width);

                % r_metaid.width(r_num,1)=cellstr(rem);

                p_st_w=ind_rem_width(1)+7;
                endpos_w=strfind(rem(p_st_w:end),'"');
                p_et_w=endpos_w(1)+p_st_w-2;


                % p_et_w=ind_rem_width(2)-1;
                r_info.width(r_num,numbOfWidth)=cellstr(rem(p_st_w:p_et_w));


                numbOfColor=1+numbOfColor;
                ind_rem_color=strfind(rem,width_color{2}) % 'color');
                p_st_c=ind_rem_color(1)+7;
                endpos_c=strfind(rem(p_st_c:end),'"');
                p_et_c=endpos_c(1)+p_st_c-2;

                r_info.color(r_num,numbOfColor)=cellstr(rem(p_st_c:p_et_c));



                r_info.number(r_num,numbOfWidth)=numOfLine;  %%% record the line number for each line that contains information about the width and color of the


                %%%%%
                results.(r_info.ID{r_num,1}).width(1,numbOfWidth)=r_info.width(r_num,numbOfWidth);
                results.(r_info.ID{r_num,1}).color(1,numbOfWidth)=r_info.color(r_num,numbOfColor);
                results.(r_info.ID{r_num,1}).number(1,numbOfWidth)=numOfLine;


            end


            if (strfind(rem,toFD(4).str));     % '<celldesigner:reactantLink';

                %% 03.05.2015
%                 numbOfreactant=1+numbOfreactant;
%                 ind_rem_reactant=strfind(rem,'"');
%
%                 p_st_r=ind_rem_reactant(1)+1;
%                 p_et_r=ind_rem_reactant(2)-1;
%
%                 r_info.reactant(r_num,numbOfreactant)=cellstr(rem(p_st_r:p_et_r));
%
%                 results.(r_info.ID{r_num,1}).reactant(1,numbOfreactant)=r_info.reactant(r_num,numbOfreactant)




                for link=1:length(reactantLink);

                    if strfind(reactantLink{link},'reactant');
                        ind_rem_reactant=strfind(rem,'"');

                        p_st_r=ind_rem_reactant(1)+1;
                        p_et_r=ind_rem_reactant(2)-1;

                        r_info.reactant(r_num,numbOfreactant+link-1)=cellstr(rem(p_st_r:p_et_r));
                    else

                        [p_st,p_ed]=position(rem,reactantLink{link});

                        r_info.reactant(r_num,numbOfreactant+link-1)=cellstr(rem(p_st:p_ed));

                    end
                end



                %  if isfield(r_info,baseReactant);
                results.(r_info.ID{r_num,1}).reactant(1,1:numbOfreactant+link-1)=r_info.reactant(r_num,1:numbOfreactant+link-1);
                %  end

                numbOfreactant=numbOfreactant+2;





                %% 9.10.2014
%                 [p_st,p_ed]=position(rem,' alias');
%                 numbOfreactant=1+numbOfreactant;
%                 r_info.reactant(r_num,numbOfreactant)=cellstr(rem(p_st:p_ed));
%                 results.(r_info.ID{r_num,1}).reactant(1,numbOfreactant)=r_info.reactant(r_num,numbOfreactant)


            end





            if (strfind(rem,toFD(5).str));


                %                 numbOfproduct=1+numbOfproduct;
                %                 ind_rem_product=strfind(rem,'"');
                %
                %
                %                 p_st_p=ind_rem_product(1)+1;
                %                 p_et_p=ind_rem_product(2)-1;
                %                 r_info.product(r_num,numbOfproduct)=cellstr(rem(p_st_p:p_et_p));
                %
                %
                %                 results.(r_info.ID{r_num,1}).product(1,numbOfproduct)=r_info.product(r_num,numbOfproduct)


                for link=1:length(productLink);
                    if strfind(productLink{link},'product');
                        ind_rem_product=strfind(rem,'"');

                        p_st_r=ind_rem_product(1)+1;
                        p_et_r=ind_rem_product(2)-1;

                        r_info.product(r_num,numbOfproduct+link-1)=cellstr(rem(p_st_r:p_et_r));
                    else


                        [p_st,p_ed]=position(rem,productLink{link});

                        r_info.product(r_num,numbOfproduct+link-1)=cellstr(rem(p_st:p_ed));

                    end
                end



                %  if isfield(r_info,baseReactant);
                results.(r_info.ID{r_num,1}).product(1,1:numbOfproduct+link-1)=r_info.product(r_num,1:numbOfproduct+link-1);
                %  end

                numbOfproduct=numbOfproduct+2;



            end








            %if r_num
            % break

            line_ed=strfind(rem,toFD(2).str);

            % end

        end



        % if (strfind(rem,toFD(2).str))
        %    break
        % end



    end



end

%%
%  dd='<celldesigner:extension>'

%rdline[]=fgets(fr);
%  tline = fgets(f_id);

% while ischar(tline)
%     disp(tline)
%     tline = fgetl(fo);
% end

%   idx=mstrfind(upper(rem),upper(dd));
%
%   idx_2=findstr(ans,'"');dd2=ddd(2)
%
%   rem=rem(1:end)

%   if(~isempty(idx))
%     rem=rem(idx(1)+1:end);
%     ready=0;
%     break;
%   end

annotation=results;
r_info.XMLtext=text;
annotation.r_info=r_info;


end

function [p_st,p_ed]=position(str_long,str_ID)
%% name='metaid';

ind_pos=strfind(str_long,str_ID);

l=length(str_ID)+2;
try
    p_st=ind_pos(1)+l;
catch
    error('cannot find the Keyword in the the line');
end

end_rem=strfind(str_long(p_st:end),'"');

p_ed=end_rem(1)+p_st-2;


end


% function [p_st,p_ed]=position2(str_long,str_ID)
% %% name='metaid';
%
%         ind_pos=strfind(str_long,str_ID);
%         l=length(str_ID)+2;
%         p_st=ind_pos{1}+l
%        % end_rem=strfind(str_long{1}(ind_pos{1}:end),'"');
%         end_rem=strfind(str_long{1}(p_st:end),'"');
%         % disp(str_long{1}(ind_pos{1}:end));
%         disp(str_long{1}(p_st:end));
%         p_ed=end_rem(1)+p_st-2;
%         disp(p_ed);
%
%
%       % string=str_long{1}(p_st:p_ed);
%
% end
