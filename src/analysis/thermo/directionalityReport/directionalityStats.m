function [model,directions]=directionalityStats(model, directions,cumNormProbCutoff,printLevel)
% Build Boolean vectors with reaction directionality statistics
%
% INPUT
% model.directions    a structue of boolean vectors with different directionality
%                     assignments where some vectors contain subsets of others
%
% directions.forwardProbability
%
% qualitatively assigned internal reaction direactions
% .forwardRecon
% .reverseRecon
% .reversibleRecon
% .equilibriumRecon
%
% quantitatively assigned internal reaction direactions
% thermodynamic data is lacking
% .forwardThermo
% .reverseThermo
% .reversibleThermo
% .uncertainThermo
% .equilibriumThermo
%
% OPTIONAL INPUT
% cumNormProbCutoff     {0.2} cutoff for probablity that reaction is
%                       reversible within this cutoff of 0.5
% printLevel            -1  print out to file
%                       0   silent
%                       1   print out to command window
%
%OUTPUT
% directions    a structue of boolean vectors with different directionality
%               assignments where some vectors contain subsets of others
%
% qualtiative -> quantiative changed reaction directions
%   .forward2Forward
%   .forward2Reverse
%   .forward2Reversible
%   .forward2Uncertain
%   .reversible2Forward
%   .reversible2Reverse
%   .reversible2Reversible
%   .reversible2Uncertain
%   .reverse2Forward
%   .reverse2Reverse
%   .reverse2Reversible
%   .reverse2Uncertain
%   .tightened
%
% subsets of qualtiatively forward  -> quantiatively reversible 
%   .forward2Reversible_bydGt0
%   .forward2Reversible_bydGt0LHS
%   .forward2Reversible_bydGt0Mid
%   .forward2Reversible_bydGt0RHS
% 
%   .forward2Reversible_byConc_zero_fixed_DrG0
%   .forward2Reversible_byConc_negative_fixed_DrG0
%   .forward2Reversible_byConc_positive_fixed_DrG0
%   .forward2Reversible_byConc_negative_uncertain_DrG0
%   .forward2Reversible_byConc_positive_uncertain_DrG0

% Ronan M.T. Fleming

if ~exist('cumNormProbCutoff','var')
    directions.cumNormProbCutoff=0.2;
else
    directions.cumNormProbCutoff=cumNormProbCutoff;
end
%must be symmetric about 50:50 to be logically consistent
cumNormProbFwdUpper=0.5+directions.cumNormProbCutoff;
cumNormProbFwdLower=0.5-directions.cumNormProbCutoff;

if ~exist('printLevel','var')
    printLevel=0;
end
if ~exist('fileName','var')
    fileName='directionalityStats.txt';
end

DrGtMin=model.DrGtMin;
DrGtMax=model.DrGtMax;
if any(DrGtMin>DrGtMax)
    error('DrGtMin greater than DrGtMax');
end

DrGtNaNBool=(isnan(model.DrGtMax) | isnan(model.DrGtMin)) & model.SIntRxnBool;
if any(DrGtNaNBool)
    warning([int2str(nnz(DrGtNaNBool)) ' DrGt are NaN']);
end

nEqualDrGt=nnz(DrGtMin==DrGtMax & DrGtMin~=0);
if any(nEqualDrGt)
    fprintf('%s\n',[num2str(nEqualDrGt) '/' num2str(length(DrGtMin)) ' reactions with DrGtMin=DrGtMax~=0' ]);
end

nZeroDrGt=nnz(DrGtMin==0 & DrGtMax==0);
if any(nZeroDrGt)
    fprintf('%s\n',[num2str(nZeroDrGt) '/' num2str(length(DrGtMin)) ' reactions with DrGtMin=DrGtMax=0' ]);
end

[~,nRxn]=size(model.S);
    
% qualitatively assigned directions
forwardRecon=directions.forwardRecon;
reverseRecon=directions.reverseRecon;
reversibleRecon=directions.reversibleRecon;
% quantitatively assigned directions
forwardThermo=directions.forwardThermo;
reverseThermo=directions.reverseThermo;
reversibleThermo=directions.reversibleThermo;
uncertainThermo=directions.uncertainThermo;

%%%%%%CHANGES IN REACTION DIRECTIONS%%%%%%%%%%%
%thermodynamic constraints tightened
tightened=model.lb<model.lb_reconThermo & model.ub_reconThermo<model.ub;

reversible2Forward=reversibleRecon & forwardThermo;
reversible2Reverse=reversibleRecon & reverseThermo;
reversible2Reversible=reversibleRecon & reversibleThermo;
reversible2Uncertain=reversibleRecon & uncertainThermo;

forward2Reverse=forwardRecon & reverseThermo;
forward2Reversible=forwardRecon & reversibleThermo;
forward2Forward=forwardRecon & forwardThermo;
forward2Uncertain=forwardRecon & uncertainThermo;

reverse2Reverse =  reverseRecon & reverseThermo;
reverse2Forward   =  reverseRecon & forwardThermo;
reverse2Reversible =  reverseRecon & reversibleThermo;
reverse2Uncertain  =  reverseRecon & uncertainThermo;

%%%%%%CAUSES TO CHANGES IN REACTION DIRECTIONS%%%%%%%%%%%
% model.DrGtMax = model.DrGt0Max + gasConstant*T*(R'*log(model.concMax) - F'*log(model.concMin));
% model.DrGtMin = model.DrGt0Min + gasConstant*T*(R'*log(model.concMin) - F'*log(model.concMax));
% model.DrGtMaxMeanConc = model.DrGt0Max + gasConstant*T*(R-F)'*log((model.concMax+model.concMin)/2);
% model.DrGtMinMeanConc = model.DrGt0Min + gasConstant*T*(R-F)'*log((model.concMax+model.concMin)/2);
    
forward2Reversible_bydGt0=forwardRecon & reversibleThermo & model.DrGtMin<0 & model.DrGtMax>0; % dGfGCforward2ReversibleBool_bydGt0

forward2Reversible_byConc_negative_fixed_DrG0 = forwardRecon & reversibleThermo & model.DrGt0Min==model.DrGt0Max & model.DrGtMax<=0; %dGfGCforward2ReversibleBool_byConc_No_dGt0ErrorLHS
forward2Reversible_byConc_positive_fixed_DrG0 = forwardRecon & reversibleThermo & model.DrGt0Min==model.DrGt0Max & model.DrGtMin>0; %dGfGCforward2ReversibleBool_byConc_No_dGt0ErrorRHS

forward2Reversible_bydGt0LHS=forward2Reversible_bydGt0 & directions.forwardProbability>cumNormProbFwdUpper; %dGfGCforward2ReversibleBool_bydGt0LHS
forward2Reversible_bydGt0Mid=forward2Reversible_bydGt0 & directions.forwardProbability>=cumNormProbFwdLower & directions.forwardProbability<=cumNormProbFwdUpper;%dGfGCforward2ReversibleBool_bydGt0Mid
forward2Reversible_bydGt0RHS=forward2Reversible_bydGt0 & directions.forwardProbability<cumNormProbFwdLower; %dGfGCforward2ReversibleBool_bydGt0RHS

forward2Reversible_byConc_negative_uncertain_DrG0 = forwardRecon & reversibleThermo & model.DrGt0Min~=model.DrGt0Max & model.DrGt0Max<0; %dGfGCforward2ReversibleBool_byConcLHS
forward2Reversible_byConc_positive_uncertain_DrG0 = forwardRecon & reversibleThermo & model.DrGt0Min~=model.DrGt0Max & model.DrGt0Min>0; %dGfGCforward2ReversibleBool_byConcRHS

forward2Reversible_byConc_zero_fixed_DrG0 = forwardRecon & reversibleThermo & model.DrGt0Min==0 & model.DrGt0Max==0;%new to v2

if printLevel<0
    fid=fopen(fileName,'w');
else
    fid=1;
end

if printLevel~=0
    fprintf(fid,'%s\n','Qualitative internal reaction directionality:');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(model.SIntRxnBool)),' internal reconstruction reaction directions.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(forwardRecon)), ' forward reconstruction assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(reverseRecon)), ' reverse reconstruction assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(reversibleRecon)), ' reversible reconstruction assignment.');
    fprintf(fid,'\n');
       
    fprintf(fid,'%s\n','Quantitative internal reaction directionality:');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(model.SIntRxnBool)),' internal reconstruction reaction directions.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(forwardThermo)+nnz(reverseThermo)+nnz(reversibleThermo)),  ' of which have a thermodynamic assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(uncertainThermo)),  ' of which have no thermodynamic assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(forwardThermo)), ' forward thermodynamic only assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(reverseThermo)), ' reverse thermodynamic only assignment.');
    fprintf(fid,'%10s\t%s\n',int2str(nnz(reversibleThermo)), ' reversible thermodynamic only assignment.');
    fprintf(fid,'\n');
    
    fprintf(fid,'%s\n','Qualitiative vs Quantitative:');
    fprintf(fid,'%10i\t%s\n',nnz(reversible2Reversible),' Reversible -> Reversible');
    fprintf(fid,'%10i\t%s\n',nnz(reversible2Forward),' Reversible -> Forward');
    fprintf(fid,'%10i\t%s\n',nnz(reversible2Reverse),' Reversible -> Reverse');
    fprintf(fid,'%10i\t%s\n',nnz(reversible2Uncertain),' Reversible -> Uncertain');
    fprintf(fid,'%10i\t%s\n',nnz(forward2Forward),' Forward -> Forward');
    fprintf(fid,'%10i\t%s\n',nnz(forward2Reverse),' Forward -> Reverse');
    fprintf(fid,'%10i\t%s\n',nnz(forward2Reversible),' Forward -> Reversible');
    fprintf(fid,'%10i\t%s\n',nnz(forward2Uncertain),' Forward -> Uncertain');
    fprintf(fid,'%10i\t%s\n',nnz(reverse2Reversible),' Reverse -> Reverse');
    fprintf(fid,'%10i\t%s\n',nnz(reverse2Forward),' Reverse -> Forward');
    fprintf(fid,'%10i\t%s\n',nnz(reverse2Reversible),' Reverse -> Reversible');
    fprintf(fid,'%10i\t%s\n',nnz(reverse2Uncertain),' Reversible -> Uncertain');
    fprintf(fid,'\n');
    
    fprintf(fid,'%s\n','Breakdown of relaxation of reaction directionality, Qualitiative vs Quantitative:');
    %total number of qualitatively forward reactions that are
    %quantitatively reversible
    fprintf(fid,'%10i\t%s\n',nnz(forward2Reversible),' qualitatively forward reactions that are quantitatively reversible (total).');
    %qualitatively forward reactions that are quantitatively reversible by
    %the range of dGt0
    fprintf(fid,'%10i\t%s%s\n',nnz(forward2Reversible_bydGt0LHS),' of which are quantitatively reversible by range of dGt0. ',['P(\Delta_{r}G^{\primeo}<0) > ' num2str(cumNormProbFwdUpper)]);
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf(fid,'%10i\t%s%s\n',nnz(forward2Reversible_bydGt0Mid),' of which are quantitatively reversible by range of dGt0. ',[num2str(cumNormProbFwdLower) '< P(\Delta_{r}G^{\primeo}<0) < ' num2str(cumNormProbFwdUpper)]);
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf(fid,'%10i\t%s%s\n',nnz(forward2Reversible_bydGt0RHS),' of which are quantitatively reversible by range of dGt0. ',['P(\Delta_{r}G^{\primeo}<0) < ' num2str(cumNormProbFwdLower)]);
    %qualitatively forward reactions that are quantitatively
    %reversible by concentration alone (no dGt0 error)
    fprintf(fid,'%10i\t%s\n',nnz(forward2Reversible_byConc_zero_fixed_DrG0),' of which are quantitatively forward by fixed dGr0t, but reversible by concentration alone (zero fixed DrGt0).');
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf(fid,'%10i\t%s\n',nnz(forward2Reversible_byConc_negative_fixed_DrG0),' of which are quantitatively reverse by dGr0t, but reversible by concentration (negative fixed DrGt0).');
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf(fid,'%10i\t%s\n',nnz(forward2Reversible_byConc_positive_fixed_DrG0),' of which are quantitatively forward by dGr0t, but reversible by concentration (positve fixed DrGt0).');
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf(fid,'%10i\t%s\n',nnz(forward2Reversible_byConc_negative_uncertain_DrG0),' of which are quantitatively reverse by dGr0t, but reversible by concentration (uncertain negative DrGt0).');
    %qualitatively reverse reactions that are quantitatively
    %reversible by concentration alone (with dGt0 error)
    fprintf(fid,'%10i\t%s\n',nnz(forward2Reversible_byConc_positive_uncertain_DrG0),' of which are quantitatively forward by dGr0t, but reversible by concentration (uncertain positive DrGt0).');
end
if printLevel<0
    fclose(fid);
end


%changed directions
directions.forward2Forward=forward2Forward;
directions.forward2Reverse=forward2Reverse;
directions.forward2Reversible=forward2Reversible;
directions.forward2Uncertain=forward2Uncertain;
directions.reversible2Forward=reversible2Forward;
directions.reversible2Reverse=reversible2Reverse;
directions.reversible2Reversible=reversible2Reversible;
directions.reversible2Uncertain=reversible2Uncertain;
directions.reverse2Forward=reverse2Forward;
directions.reverse2Reverse=reverse2Reverse;
directions.reverse2Reversible=reverse2Reversible;
directions.reverse2Uncertain=reverse2Uncertain;

directions.tightened=tightened;

%all forward reversible classes
directions.forward2Reversible_bydGt0=forward2Reversible_bydGt0;
directions.forward2Reversible_bydGt0LHS=forward2Reversible_bydGt0LHS;
directions.forward2Reversible_bydGt0Mid=forward2Reversible_bydGt0Mid;
directions.forward2Reversible_bydGt0RHS=forward2Reversible_bydGt0RHS;

directions.forward2Reversible_byConc_zero_fixed_DrG0=forward2Reversible_byConc_zero_fixed_DrG0;
directions.forward2Reversible_byConc_negative_fixed_DrG0=forward2Reversible_byConc_negative_fixed_DrG0;
directions.forward2Reversible_byConc_positive_fixed_DrG0=forward2Reversible_byConc_positive_fixed_DrG0;
directions.forward2Reversible_byConc_negative_uncertain_DrG0=forward2Reversible_byConc_negative_uncertain_DrG0;
directions.forward2Reversible_byConc_positive_uncertain_DrG0=forward2Reversible_byConc_positive_uncertain_DrG0;