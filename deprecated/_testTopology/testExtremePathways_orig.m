%script to test extremePathways.m
clear

model.description='loop3b';
%model.description='loop3b';
%model.description='hyper3';
%model.description='hyper3atom';
%model.description='schilling';
%model.description='13pdo';
%model.description='loopTwoExpa';
%model.description='iTryp';
%model.description='iCore';

switch model.description
    case 'loop3a'
        S=[-1,0,1;
            1,-1,0;
            0,1,-1];
        model.S=S;

    case 'loop3b'
        S=[1,0,1;
          -1,-1,0;
           0,1,-1];
        model.S=S;

    case 'hyper3'
        S=[-1,1,0;
            1,-1,0;
            0,-1,1;
            0,1,-1];
        model.S=S;
    case 'hyper3atom'
        S=[-1,1,0,0;
            1,-1,0,0;
            0,0,-1,1;
            0,0,1,-1];
        model.S=S;
        
    case '3by6_2ex'
        S=  [-1     0       1 ;
            1      -1      0 ;
            0      1       -1 ];
        Se= [1     0    0 ;
            0      0    0 ;
            0      0   -1];
        model.S=[S Se];
    case '3by5_2ex'
        S=  [-1     0       1 ;
            1      -1      0 ;
            0      1       -1 ];
        Se= [1     0    0 ;
            0      0    0 ;
            0      0   -1];
        model.S=[S Se];
    case '3by6_3ex'
        S=  [-1     0       1 ;
            1      -1      0 ;
            0      1       -1 ];
        Se= [1     0    0 ;
            0     -1    0 ;
            0      0   -1];
        model.S=[S Se];
    case 'schilling'
        S=  [-1     0       1 ;
            1      -1      0 ;
            0      1       -1 ];
        Se= [1     0    0 ;
            0      1    0 ;
            0      0    1];
        model.S=[S Se];
        model.directionality=[1,1,1,0,0,0];
    case 'loopTwoExpa'
        S=  [-1     0       1       0       1;
            1      -1      0       0       0;
            0      1       -1      -1      0;
            0      0       0       1       -1];
        model.S=S;
        model.directionality=[0,0,0,0,0];
    case '13pdo'
        %reads in the 13pdo model
        %model = xls2model('R_and_M.xls');
        %load /home/rfleming/workspace/graphStoich/data/13pdo21-Aug-2010.mat
        load 13pdo-July-20-2011.mat
        %the description is the text used for the input and output files
        %for lrs, the program which calculates the extreme pathways
        model.description='13pdo';
        %model.SIntRxnBool=true(38,1);
        %model.SIntRxnBool(33:38,1)=0;
    case 'iTryp'
        %load iTrypAnaerobicGlycolysisLoop
        load /home/rfleming/workspace/Stanford/convexFBA/data/siliconTrypanosome/data/stoichioTryp/iTrypAnaerobicGlycolysisLoop.mat

        model.description='iTryp';
        %model.S(:,23)=model.S(:,23)*-1;
        
    case 'iCore'
        load iCore
        %finds the reactions in the model which export/import from the model
        %boundary i.e. mass unbalanced reactions
        %e.g. Exchange reactions
        %     Demand reactions
        %     Sink reactions
        model = findSExRxnInd(iCore);
        %Integerize 'CYTBD'
        %'2 h[c] + 0.5 o2[c] + q8h2[c]  -> h2o[c] + 2 h[e] + q8[c] '
        model.S(:,strcmp(model.rxns,'CYTBD'))=model.S(:,strcmp(model.rxns,'CYTBD'))*2;
        model.description='iCore';
end

switch model.description
    case 'iCore'
        %dont calculate extreme pathways
        P=[];
    otherwise
        fprintf('%s\n','Extreme pathways')
        %calculates the matrix of extreme pathways, P
        positivity=0;
        [P,V]=extremePathways(model,positivity);
        %make the matrices full rather than sparse
        P=full(P);
        V=full(V);
        %display the matrix of extreme pathways
        disp(full(P))
end

fprintf('%s\n','Extreme pools')
%calculates the matrix of extreme pools
positivity=1;
[Pl,Vl,A]=extremePools(model,positivity);
%make the matrices full rather than sparse
Pl=full(Pl);
Vl=full(Vl);
if 1
    %display the matrix of extreme pools
    disp(full(Pl))
end

%save pathways and pools to the model
model.P=P;
model.Pl=Pl;
%save the workspace with the date
save([model.description '_Paths_Pools_' date],'model');
