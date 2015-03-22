## Matlab Bindings 
This archive contains the standalone libSBML Matlab bindings. To install them, simply extract the folder, start MATLAB and add the folder to your MATLAB path (using [addPath](http://www.mathworks.com/help/matlab/ref/addpath.html)). 

You can verify that everything works as planned, by changing into that directory and running `TranslateSBML('test.xml')`. If everything went as planned, you will see a MATLAB structure representing that toy test model. In that case you might want to save the changes to your path, using the [savepath](http://www.mathworks.com/help/matlab/ref/savepath.html) command. 

For more information please see the [libSBML Matlab API Documentation][1], especially the [Known issues][2].


[1]: http://sbml.org/Software/libSBML/docs/matlab-api/
[2]: http://sbml.org/Software/libSBML/docs/matlab-api/libsbml-issues.html

---
3/19/2015 7:36:39 PM Frank T. Bergmann