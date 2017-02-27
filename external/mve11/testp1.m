% test on problem p1

load p1;
%warning off;
[x1,E1] = mve_run(A,b,x0);
fprintf('  Done with mve_run(A,b,x0) ......\n')
pause(1)
[x2,E2] = mve_run(A,b);
fprintf('  Done with mve_run(A,b) ......\n')
%warning on;
