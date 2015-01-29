function [r_info] = readCD(parsed)

% converting the parsed Matlab struct (the outputed by parseCD)


r_info.ID=fieldnames(parsed);

% a={'ID','reactant','product','number','width','color'};
attribute={'number','width','color'}; % add any attribute name here
for r=1:length(r_info.ID(:,1)); % number of reactions
    if strcmp(r_info.ID{r},'r_info')~=1; % excluding the field, 'r_info'.
        for e=1:length(attribute);     % number of attributes
            
            for s=1:length(parsed.(r_info.ID{r}).(attribute{e})(1,:))
                r_info.(attribute{e})(r,s)=parsed.(r_info.ID{r}).(attribute{e})(1,s)
            end
        end
    end
end

if isfield(parsed.r_info,'species')
r_info.species=parsed.r_info.species;
end



end

