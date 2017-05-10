%script to test extremePathways.m
clear

%model.description='loop3a';
%model.description='loop3b';
%model.description='loop3b';
%model.description='hyper3';
%model.description='hyper3atom';
%model.description='schilling';
%model.description='13pdo';
%model.description='loopTwoExpa';
%model.description='iTryp';
%model.description='iCoreED';
model.description='iAF1260';

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
    case 'iCoreED'
        load iCoreED_modelT.mat
    case 'iAF1260'
        load iAF1260.mat
        model=iAF1;
end
[p, output] = findExtremePool(model);
 
[B,L] = greedyExtremePoolBasis(model);