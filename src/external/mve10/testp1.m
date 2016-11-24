% test on problem p1

load p1;
warning off;
[x,E] = mve_run(A,b,x0);
fprintf('  Done with mve_run(A,b,x0) ......\n')
pause(2)
[x,E] = mve_run(A,b);
fprintf('  Done with mve_run(A,b) ......\n')
warning on;
