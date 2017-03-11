%
testS=10;
switch testS
    case 3
        S=[-1;-1;-1;1;1];
        
        A=[1,0,0,0,0,0,0;
            0,1,0,0,0,0,0;
            0,0,1,0,0,0,0;
            0,0,0,1,0,0,0;
            0,0,0,0,1,0,0];
        
        
        B=[-1, 0, 0;
            -1, 0, 0;
            0,-1, 0;
            0, 0, 1;
            0, 0, 1;
            1,-1, 0;
            0, 1,-1];
        
        C=[1;
            1;
            1];
        
        S2=A*B*C;
    case 2
        S=[-1;
            -2;
            -3;
            -4;
            1;
            2;
            3;
            4];
    case 3
        S=[-1,0,-1,-1;
            -2,0,0,-1;
            -3,-1,0,0;
            -4,-2,0,0;
            1,0,1,0;
            2,1,0,0;
            3,1,0,1;
            4,1,0,1];
    case 4
        S=[-1;-1;1;1;1];
    case 5
        S=[-1,2;-1,2;-1,2;-1,2;-1,2];
    case 9
        load /home/rfleming/workspace/graphStoich/data/modelCollection/ecoli_core_xls2model.mat
        S=model.S;
        if 0
        S2=model.S(:,[1,6]);
        S=S2(sum(S2~=0,2)~=0,:);
        disp(full(S))
        %pause(eps)
        end
    case 10
        load /home/rfleming/workspace/graphStoich/data/modelCollection/121114_Recon2betaModel.mat
        model=modelRecon2beta121114;
        S=model.S;
end

[A,B,C]=bilinearDecomposition(S);
if 1
    fprintf('%s\t%s\t%s\n',' ','#row','#col')
    fprintf('%s\t%d\t%d\n','S',size(S))
    fprintf('%s\t%d\t%d\n','A',size(A))
    fprintf('%s\t%d\t%d\n','B',size(B))
    fprintf('%s\t%d\t%d\n','C',size(C))
end

if 1
    save('/home/rfleming/workspace/graphStoich/data/bilinearDecompositionRecon2.mat','model','S','A','B','C')
end



