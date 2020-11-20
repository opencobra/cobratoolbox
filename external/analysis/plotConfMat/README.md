# plotConfMat
Plots a confusion matrix with colorscale, absolute numbers and precision normalized percentages. 
This is a basic alternative to matlab's [plotconfusion](https://uk.mathworks.com/help/nnet/ref/plotconfusion.html) if you do not
have the Neural Network Toolbox.

usage:
```matlab
plotConfMat(confmat)
```
or
```matlab
plotConfMat(confmat, labels)
```
if you want to specify the class labels.
