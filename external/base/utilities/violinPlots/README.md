# Violin Plots for Matlab

A violin plot is an easy to read substitute for a box plot that
replaces the box shape with a kernel density estimate of the data, and
optionally overlays the data points itself.
 
Additional constructor parameters include the width of the plot, the
bandwidth of the kernel density estimation, and the X-axis position of
the violin plot.

```matlab
load carbig MPG Origin
Origin = cellstr(Origin);
figure
vs = violinplot(MPG, Origin);
ylabel('Fuel Economy in MPG');
xlim([0.5, 7.5]);
```

![example image](example.png)
