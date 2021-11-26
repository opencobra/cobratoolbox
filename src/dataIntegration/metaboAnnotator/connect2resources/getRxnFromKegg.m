function [keggkeggRxn] = getkeggRxnFromKegg(metabolite_structure,  metabolite_structure_rBioNet, metsField)
%get reaction from kegg

if ~exist('metabolite_structure_rBioNet','var')
    load met_strc_rBioNet;
end

% get kegg ID from metabolite_structure_rBioNet
[VMH2IDmappingAll,VMH2IDmappingPresent,VMH2IDmappingMissing]=getIDfromMetStructure(metabolite_structure_rBioNet,'keggId');

F = fieldnames(metabolite_structure);
if ~exist('metsField','var')
    metsField = F;
end
[VMH2IDmappingAllInput,VMH2IDmappingPresentInput,VMH2IDmappingMissingInput]=getIDfromMetStructure(metabolite_structure,'keggId');

idx = find(ismember(F,metsField));
cnt = 1;
for i = 1:length(idx)
    if ~isempty(metabolite_structure.(F{idx(i)}).keggId) && length(find(isnan(metabolite_structure.(F{idx(i)}).keggId)))==0
        
        kegg = metabolite_structure.(F{idx(i)}).keggId
        url = ['https://www.genome.jp/dbget-bin/www_bget?cpd:' kegg];
        syst = urlread(url);
        [R,rem] = split(syst,'<a href="/entry/R');
        for k = 2 : length(R)
            cntc = 1;
            clear tok2
            [tok2,rem] = split(R{k},'>');
            Rkegg = regexprep(tok2{2},'<\/a','');
            % go to the webpage
            url = ['https://www.genome.jp/entry/' Rkegg];
            syst = urlread(url);
            if contains(syst,'<nobr>Entry</nobr>')
                keggRxn{cnt,cntc} = F{idx(i)}; cntc = cntc + 1;
                keggRxn{cnt,cntc} = Rkegg;cntc = cntc + 1;
                % get reaction name
                if  contains(syst,'<nobr>Name</nobr>')
                    [tok,rem] = split(syst,'<nobr>Name</nobr>');
                    [tok2,rem] = split(tok{2},'</div>');
                    [tok3,rem] = split(tok2{1},'">');
                    keggRxn{cnt,cntc} = strtrim(regexprep(tok3{end},'<br>',''));cntc = cntc + 1;
                else
                    cntc = cntc + 1;
                end
                
                % Entry (Kegg keggRxn Id)
                [tok,rem] = split(syst,'<nobr>Entry</nobr>');
                [tok2,rem] = split(tok{1},'</title>');
                [tok2b,rem] = split(tok2{1},'>');
                
                [tok3,rem] = split((tok2b{5}),'KEGG REACTION: ');
                keggRxn{cnt,cntc} = tok3{2};cntc = cntc + 1;
                %Definition
                
                [tok,rem] = split(syst,'<nobr>Definition</nobr>');
                [tok2,rem] = split(tok{2},'</div>');
                [tok3,rem] = split(tok2{1},'">');
                x= regexprep(tok3{end},'<br>','');
                keggRxn{cnt,cntc} = strtrim(regexprep(x,'&lt;=&gt;','<=>'));cntc = cntc + 1;
                
                % get reaction equation
                [tok,rem] = split(syst,'<nobr>Equation</nobr>');
                [tok2,rem] = split(tok{2},'</div>');
                [tok3,rem] = split(tok2{1},'overflow-y:hidden">');
                tok3{2} = regexprep(tok3{2},'<br>','');
                
                r = regexprep(tok3{2},'(C\d+">)(\w+)','$2');
                r = regexprep(r,'<a href="/entry/','');
                r = regexprep(r,'</a>','');
                r = strtrim(regexprep(r,'&lt;=&gt;','<=>'));
                keggRxn{cnt,cntc} = r; cntc = cntc + 1;
                
                % try to get the reaction in terms of VMHId
                keggR = r;
                keggR = regexprep(keggR,'+','');
                keggR = regexprep(keggR,'<=>','');
                keggR = regexprep(keggR,'  ',' ');
                
                keggM = split(keggR,' ');
                rAbbr = r;
                rName = r;
                for w = 1 :length(keggM)
                    y = find(ismember(VMH2IDmappingPresent(:,2),keggM{w}));
                    if ~isempty(y)
                        idy{w,1} = y(1);
                        hc =contains(VMH2IDmappingPresent(y), 'HC');
                        if length(y)>1 && find(hc) % chose the non HC VMH metabolite
                             idy{w,1} = y(find(~hc));
                        end
                        rAbbr= regexprep(rAbbr,VMH2IDmappingPresent{idy{w,1},2},VMH2IDmappingPresent{idy{w,1},3});
                        rName = regexprep(rName,VMH2IDmappingPresent{idy{w,1},2},VMH2IDmappingPresent{idy{w,1},4});
                    end
                    y = find(ismember(VMH2IDmappingPresentInput(:,2),keggM{w}));
                    if ~isempty(y)
                        idy{w,1} = y(1);
                        rAbbr= regexprep(rAbbr,VMH2IDmappingPresentInput{idy{w,1},2},VMH2IDmappingPresentInput{idy{w,1},3});
                        rName = regexprep(rName,VMH2IDmappingPresentInput{idy{w,1},2},VMH2IDmappingPresentInput{idy{w,1},4});
                    end
                end
                keggRxn{cnt,cntc} = rAbbr;cntc = cntc + 1;
                keggRxn{cnt,cntc} = rName;cntc = cntc + 1;
                % get EC number
                if  contains(syst,'<nobr>Enzyme</nobr>')
                    [tok,rem] = split(syst,'<nobr>Enzyme</nobr>');
                    [tok2,rem] = split(tok{2},'<a href="/entry/');
                    [tok3,rem] = split(tok2{2},'">');
                    keggRxn{cnt,cntc} = strtrim(tok3{1});cntc = cntc + 1;
                else
                    cntc = cntc + 1;
                end
                
                % get associated gene from kegg
                url2 = ['https://www.genome.jp/dbget-bin/get_linkdb?-t+genes+rn:' Rkegg];
                syst2 = urlread(url2);
                % find human
                if contains(syst2,'hsa:') 
                    [tokg,rem] = split(syst2,'<a href="/entry/hsa:');
                    [tokg2,rem] = split(tokg{2},'">');
                    keggRxn{cnt,cntc} =  tokg2{1};cntc = cntc + 1;
                    % get kegg ontology for reaction
                    [tokg3,rem] = split(tokg2{2},'</a>');
                    x = regexprep(tokg3{2},'(\s+)(K\d+)(\s+)(\w+)','$2');
                    [tokg4,rem] = split(x,' ');
                    
                    keggRxn{cnt,cntc} = strtrim(tokg4{1});cntc = cntc + 1;
                end
                
                cnt = cnt + 1;
            end
        end
    end
end
