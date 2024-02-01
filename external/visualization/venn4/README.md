[![DOI](https://zenodo.org/badge/562717209.svg)](https://zenodo.org/badge/latestdoi/562717209)
[![View Venn diagram on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/120118-venn-diagram)

# venn: A simple MATLAB function to draw Venn diagram of two to four sets with optional labels

User can specify the number of sets to draw (maximum four) and label each set and the intersectional regions between sets.
 
Man Ho Wong, 2022.

## Installation

Requirement: MATLAB R2007a or above.

User can download the file `venn.m` in this repository directly or intall the function via MATLAB's Add-On Explorer.

## Usage

```
Input : n [positive integer]
          Number of sets to draw
        sets [string | char | cellstr | numeric]
             An array of set names in left-to-right order
        labels [string | char | cellstr | numeric]
               An array of label names for labeling each section;
               Elements in the array must follow the following order: 
               For diagram with Set A and B, labels for 3 sections are
               A, B and A&B.
               For diagram with Set A, B and C, labels for 7 sections are
               A, B, C, D, A&B, A&C, B&C and A&B&C.                 
               For diagram with Set A, B, C and D, labels for 15 sections
               are A, B, C, D, A&B, A&C, A&D, B&C, B&D, C&D, A&B&C, A&B&D 
               , A&C&D, B&C&D, A&B&C&D.
               Any extra labels will be ignored.
        colors [rows of RGB triplet]
               Color map for fill colors in left-to-right order.
               e.g. [1 0 0; 0 1 0; 0 0 1] represents red, green, blue;
               If number of colors is less than n, colors will be
               repeated.
        alpha [0 to 1]
              Fill color transparency; 0 = fully transparent.
        edgeC [RGB triplet]
              Edge color (only effective when 'edgeW' is > 0).
        edgeW [positive number]
              Edge width (By default, there is no edge)
        labelC [RGB triplet]
               Color of section labels.

Output : A Veenn diagram will be drawn on a new figure.
         vennfig (optional): A handle to the figure.
```

## Examples

Draw three sets with default settings:

```
venn(3);
```
![3sets1](resources/3sets1.png)

Assign names and use random integers as section labels:
```
mysets = ["A" "B" "C" "D"];
mylabels = randi(100,[15,1]);
```

Draw two sets with labels; set fill alpha (transparency) to 0.7, set label color to white and use black edges with custom thickness:

```
venn(2,'sets',mysets,'labels',mylabels,'alpha',0.7,'edgeC',[0 0 0],'labelC',[1 1 1],'edgeW',5);
```
![2sets](resources/2sets.png)


Draw three sets with labels; set fill alpha to 0 and use black edges with custom thickness:

```
venn(3,'sets',mysets,'labels',mylabels,'alpha',0,'edgeC',[0 0 0],'edgeW',3);
```
![3sets2](resources/3sets2.png)

Draw four sets with labels; use custom color map, set alpha to 0.5 and use white edges with custom thickness:

```
c = summer(4);
venn(4,'sets',mysets,'labels',mylabels,'colors',c,'alpha',0.5,'edgeC',[1 1 1],'edgeW',3);
```
![4sets](resources/4sets.png)

## License

This project is licensed under [GNU General Public License v3.0.](LICENSE)

## Cite As
Wong, M. H. (2022). venn: A simple MATLAB function to draw Venn diagram of two to four sets with optional labels. (1.0.0). Zenodo. https://doi.org/10.5281/zenodo.7297812