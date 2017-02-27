load data2d;
[x,E] = mve_run(A,b,x0);
fprintf('  drawing ..........\n')
draw_ellipse(A,b,x0,x,E);
text(1.25,0.62,'x^*')         
text(0.88,0.20,'x^0')    
shg