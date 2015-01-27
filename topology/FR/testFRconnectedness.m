%script to test the connectedness of an [F R]

if 0
FR=[1,0,0,0,0,0,0,0,0,1; %1
    0,0,0,1,0,1,0,0,0,0; %2
    0,0,0,0,1,0,1,0,0,0; %3
    0,0,0,0,1,1,0,0,0,0; %4
    0,0,0,1,0,0,1,0,0,0; %5
    1,0,0,0,0,0,0,0,1,0];%6
else
FR=[1,0,0,0,0,0,0,0,0,1; %1
    0,0,0,1,4,1,0,0,0,0; %2
    0,0,0,0,1,0,1,0,0,0; %3
    0,0,0,0,1,1,0,0,0,0; %4
    0,0,0,1,0,0,1,0,0,0; %5
    1,0,0,0,0,0,0,0,1,0];%6
end

[m,n]=size(FR);

[rankFR,p,q]      = getRankLUSOL(FR);


%[sci sizes] = scomponents(FR);

%indices of rows that are dependent
dR=p(rankFR+1:length(p));


F=FR(:,1:5);
R=FR(:,6:10);

[largestConnectedRowsFRBool,largestConnectedColsFRVBool]=largestConnectedFR(F,R,1);
[connectedRowsFRBool,connectedColsFRVBool]=connectedFR(F,R);

disp(connectedRowsFRBool)
disp(largestConnectedRowsFRBool)

if 0
    disp(largestConnectedColsFRVBool)
    disp(connectedColsFRVBool)
end