%test the computation of circuits with Johnsons algorithm with CellNetAnalyzer
makeLoopToyModel

S1=model.S(:,1:3);

undirected=0;
C1 = getStoichCircuitsJohnson(S1,undirected);


S2 =[-1     0   -1
     1    -1     0
     0     1    1];

undirected=1;
C2 = getStoichCircuitsJohnson(S2,undirected);


%C1 & C2 should be the same