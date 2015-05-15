function [r_info] = readCD(parsed)

%Convert the a type of the parsed model structure (orgnised by reaction)
% into the other type of the parsed model structure (organised by property
% (namely, ID, width, colour, etc.)
%
%
%INPUT
%
% parsed       the first type of the parsed model structure outputed by
%              'parseCD' funciton (more user-friendely to modify speicfic
%              graphic properties for speicific reactions)
%
%OUTPUT
%
% r_info       the second type of the parsed model structure (similar to a
%              COBRA Matlab structure).
%
% Longfei Mao Oct/2014

parsed_temp=rmfield(parsed,'r_info');

r_info_temp.ID=fieldnames(parsed_temp);
% a={'ID','reactant','product','number','width','color'};


names_l1=fieldnames(parsed);

attribute=fieldnames(parsed.(names_l1{1}))' % retrieve the field names of the first entry of the model structure.

% attribute={'number','width','color'}; % add any attribute names here
for r=1:length(r_info_temp.ID(:,1)); % number of reactions
    if strcmp(r_info_temp.ID{r},'r_info')~=1; % excluding the field, 'r_info'.
        for e=1:length(attribute);     % number of attributes
            if isfield(parsed.(r_info_temp.ID{r}),(attribute{e})) % Check if the field name exsits. In some cases, the field name may not appear for some entiries.  
                for s=1:length(parsed.(r_info_temp.ID{r}).(attribute{e})(1,:))
                    r_info_temp.(attribute{e})(r,s)=parsed.(r_info_temp.ID{r}).(attribute{e})(1,s)
                end
            end
        end
    end
end
if isfield(parsed.r_info,'species')
    r_info_temp.species=parsed.r_info.species;
end


r_info=r_info_temp;

r_info=rmfield(r_info,'name');
r_info.ID(:,2:(size(r_info_temp.name,2)+1))=r_info_temp.name(:,:);







