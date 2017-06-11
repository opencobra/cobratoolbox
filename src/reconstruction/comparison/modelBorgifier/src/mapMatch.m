% This file is published under Creative Commons BY-NC-SA.
%
% Please cite:
% Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale 
% metabolic reconstructions with modelBorgifier. Bioinformatics 
% (Oxford, England), 30(7), 1036?8. http://doi.org/10.1093/bioinformatics/btt747
%
% Correspondance:
% johntsauls@gmail.com
%
% Developed at:
% BRAIN Aktiengesellschaft
% Microbial Production Technologies Unit
% Quantitative Biology and Sequencing Platform
% Darmstaeter Str. 34-36
% 64673 Zwingenberg, Germany
% www.brain-biotech.de
%
function [rmatch, mmatch] = mapMatch(Cmodel,Tmodel,seedMets)
% mapMatch compares the local network topology between the metabolites and
% reactions of two models
%
% USAGE:
%
% INPUTS:
%     Cmodel:    model to be compared
%     Tmodel:    reference model
%     seedMats:  two column cell array with pairs of metabolite names in the
%                two models that are the same
%
% OUTPUTS:
%     rmatch:    pairwise match score between reactions
%     mmatch:    pairwise match score between metabolites
%
% CALLS:
%     None
%
% CALLED BY:
%     compareCbModels
%

% preallocate matching
mmatch = zeros(length(Cmodel.mets), length(Tmodel.mets)) ;
rmatch = zeros(length(Cmodel.rxns), length(Tmodel.rxns)) ;
mcnt = zeros(length(Cmodel.mets), length(Tmodel.mets)) ;
rcnt = zeros(length(Cmodel.rxns), length(Tmodel.rxns)) ;

% Count immediate neighbours for each rxn and met, that is the number of
% metabolites involved in a reaction or the number of reactions that a
% metabolite is involved in.
s1 = Cmodel.S ;
s1(s1 ~= 0) = 1 ;
Cmetinrxn = full(sum(s1, 1))' ;
Crxnwithmet = full(sum(s1, 2)) ;
s2 = Tmodel.S ;
s2(s2 ~= 0) = 1 ;
Tmetinrxn = full(sum(s2, 1))' ;
Trxnwithmet = full(sum(s2, 2)) ;

if ischar(seedMets)
    if strcmpi(seedMets, 'noSeed') % if matching seeds are not provided
        % only consider connections of metabolites and reactions, not stoichiometry
        s1 = logical(s1) ;
        s2 = logical(s2) ;
        % get number of models that each metabolite in Tmodlel occurs in
        tmodelnames = fieldnames(Tmodel.Models) ;
        metInModelSum = Tmodel.Models.(tmodelnames{1}).mets ;
        for im = 2:length(tmodelnames)
            metInModelSum = metInModelSum + Tmodel.Models.(tmodelnames{im}).mets ;
        end
        
        % difference in number of reactions that each metabolite is involved in
        diffNumRxns = abs(repmat((Trxnwithmet ./ metInModelSum)', length(Cmodel.mets), 1) - ...
                          repmat(Crxnwithmet, 1, length(Tmodel.mets))) ;
        % difference in number of metabolites that are involved in each reaction
        diffNumMets = abs(repmat(Tmetinrxn', length(Cmodel.rxns), 1) - ...
                          repmat(Cmetinrxn, 1, length(Tmodel.rxns))) ;
        
        for ir1 = 1:length(Cmodel.rxns)
            for ir2 = 1:length(Tmodel.rxns)
                % for each pair of reactions, get the corresponding sets of
                % metabolites and for those get the average of the minimum
                % difference in numbers of reactions that they are involved in
                rmatch(ir1, ir2) = mean(min(diffNumRxns(s1(:, ir1), s2(:, ir2)))) ;  
            end
        end
        % multiply the average difference in number of reactions of the
        % involved metabolites with the difference in number of metabolites
        % of each pair of reactions
        rmatch = rmatch .* diffNumMets ;
        % convert to distance
        rmatch = 1 ./ (rmatch +1) ;   
    end   
else
    
    % seed the matching process with pre-matched metabolites
    for ism = 1:size(seedMets, 1)
        mmatch(strcmp(Cmodel.mets, seedMets{ism, 1}), strcmp(Tmodel.mets, seedMets{ism, 2})) = inf ;
        mcnt(  strcmp(Cmodel.mets, seedMets{ism, 1}), strcmp(Tmodel.mets, seedMets{ism, 2})) = 1 ;
    end
    
    Cmodeltodo = 1:length(Crxnwithmet) ;
    r1todo = 1:length(Cmetinrxn) ;
    
    % take out too highly connected metabolites
    Cmodeltodo(Crxnwithmet > 60) = [] ;
    
    h = waitbar(1) ;
    
    while length(Cmodeltodo) >= 1
        % find best matching metabolite and the reactions it is involved in
        mmatchnorm = mmatch ./ (mcnt + 1) ;
        maxMmatch = max(mmatchnorm(Cmodeltodo, :), [], 2) ;
        if max(maxMmatch) > 0
            nowmpos = Cmodeltodo(maxMmatch == max(maxMmatch)) ;
            
            for im = 1:length(nowmpos)
                nowmpos1 = nowmpos(im) ;
                if  max(mmatch(nowmpos1, :)) > 0
                    nowmpos2a = find(mmatchnorm(nowmpos1, :) >= 0.5);
                    for iTmodel = 1:length(nowmpos2a)
                        nowmpos2 = nowmpos2a(iTmodel) ;
                        rx1 = find(Cmodel.S(nowmpos1, :)) ;
                        rx2 = find(Tmodel.S(nowmpos2, :)) ;
                        if length(rx1) == length(rx2)
                            % calculate similarity among reactions and add to rmatch
                            rmatch(rx1, rx2) = (rmatch(rx1,rx2) + 1./ ...
                                (1 + abs(repmat(Cmetinrxn(rx1), 1, length(rx2)) - ...
                                       repmat(Tmetinrxn(rx2)', length(rx1), 1)))) ;
                            rcnt(rx1, rx2) = rcnt(rx1, rx2) + 1 ;
                        end
                    end
                    % don't do the same metabolite again
                    Cmodeltodo(Cmodeltodo == nowmpos1) = [] ;
                end
            end
        else
            % only non-connected metabolites left
            Cmodeltodo = [] ;
        end
        
        % find best matching reaction and the metabolites it involves
        rmatchnorm = rmatch ./ (rcnt + 1) ;
        maxRmatch = max(rmatchnorm(r1todo, :), [], 2) ;
        if max(maxRmatch) > 0
            nowrpos = r1todo(maxRmatch == max(maxRmatch)) ;
            
            for ir = 1:length(nowrpos)
                nowrpos1 = nowrpos(ir) ;
                if  max(rmatch(nowrpos1, :)) > 0
                    nowrpos2a = find(rmatchnorm(nowrpos1, :) >= 0.5) ;
                    for ir2 = 1:length(nowrpos2a)
                        nowrpos2 = nowrpos2a(ir2) ;
                        met1 = find(Cmodel.S(:, nowrpos1)) ;
                        met2 = find(Tmodel.S(:, nowrpos2)) ;
                        if length(met1) == length(met2)
                            % calculate similarity among metabolites and add to mmatch
                            mmatch(met1, met2) = (mmatch(met1, met2) + 1./ ...
                                (1 + abs(repmat(Crxnwithmet(met1), 1, length(met2)) - ...
                                repmat(Trxnwithmet(met2)', length(met1), 1)))) ;
                            mcnt(met1, met2) = mcnt(met1, met2) + 1 ;
                        end
                    end
                end
                % don't do the same reaction again
                r1todo(r1todo == nowrpos1) = [] ;
            end
        end
        waitbar(length(Cmodeltodo) / length(Cmodel.mets))
    end
    
    close(h)
end