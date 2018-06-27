function varargout = venn (varargin)

%VENN   Plot 2- or 3- circle area-proportional Venn diagram
%
%  venn(A, I)
%  venn(Z)
%  venn(..., F)
%  venn(..., 'ErrMinMode', MODE)
%  H = venn(...)
%  [H, S] = venn(...)
%  [H, S] = venn(..., 'Plot', 'off')
%  S = venn(..., 'Plot', 'off')
%  [...] = venn(..., P1, V1, P2, V2, ...) 
%
%venn(A, I) by itself plots circles with total areas A, and intersection
%area(s) I. For two-circle venn diagrams, A is a two element vector of circle 
%areas [c1 c2] and I is a scalar specifying the area of intersection between 
%them. For three-circle venn diagrams, A is a three element vector [c1 c2 c3], 
%and I is a four element vector [i12 i13 i23 i123], specifiying the 
%two-circle intersection areas i12, i13, i23, and the three-circle
%intersection i123.
%
%venn(Z) plots a Venn diagram with zone areas specified by the vector Z. 
%For a 2-circle venn diagram, Z is a three element vector [z1 z2 z12]
%For a 3-circle venn, Z is a 7 element vector [z1 z2 z3 z12 z13 z23 z123]
%
%venn(..., F) specifies optional optimization options. VENN uses FMINBND to
%locate optimum pair-wise circle distances, and FMINSEARCH to optimize
%overall three-circle alignment. F is a structure with fields specifying
%optimization options for these functions. F may be a two-element array of
%structures, in which case the first structure is used for FMINBND
%function calls, and the second structure is used for FMINSEARCH function
%calls.
%
%venn(..., 'ErrMinMode', MODE)
%Used for 3-circle venn diagrams only. MODE can be 'TotalError' (default), 
%'None', or 'ChowRodgers'. When ErrMinMode is 'None', the positions and 
%sizes of the three circles are fixed by their pairwise-intersections, 
%which means there may be a large amount of error in the area of the three-
%circle intersection. Specifying ErrMinMode as 'TotalError' attempts to 
%minimize the total error in all four intersection zones. The area of the 
%three circles are kept constant in proportion to their populations. The 
%'ChowRodgers' mode uses the the method proposed by Chow and Rodgers 
%[Ref. 1] to draw 'nice' three-circle venn diagrams which appear more 
%visually representative of the desired areas, although the actual areas of 
%the circles are allowed to deviate from requested values.
%
%H = venn(...) returns a two- or three- element vector to the patches 
%representing the circles. 
%
%[H, S] = venn(...) returns a structure containing descriptive values
%computed for the requested venn diagram. S is a structure with the
%following fields, where C is the number of circles (N = 2 or 3), Z is
%the number of zones (Z = 3 or 7), and I is the number of intersection 
%areas (1 or 4)
%
% Radius            C-element vector of circle radii
%
% Position          C*2 array of circle centers
%
% ZoneCentroid      Z*2 array of zone centroids (Can be used for labeling)
%
% CirclePop         C-element vector of supplied circle populations. 
%                   (I.e., the 'true' circle areas)
%
% CircleArea        C-element of actual circle areas
%
% CircleAreaError   = (CircleArea-CirclePop)/CirclePop
%
% IntersectPop      I-element vector of supplied intersection populations
%                   (I.e., the 'true' intersection areas)
%
% IntersectArea     I-element vector of actual intersection areas
%
% IntersectError    = (IntersectArea-IntersectPop)/IntersectPop
%
% ZonePop           Z-element vector of supplied zone populations. (I.e.
%                   'true' zone areas
%
% ZoneArea          Z-element vector of actual zone areas.
%
% ZoneAreaError     = (ZoneArea-ZonePop)/ZonePop
% 
%
%[H, S] = venn(..., 'Plot', 'off')
%S = venn(..., 'Plot', 'off')
%Returns a structure of computed values, without plotting the diagram. This 
%which can be useful when S is used to draw custom venn diagrams or for 
%exporting venn diagram data to another application. When Plot is set to off, 
%the handles vector H is returned as an empty array. Alternatively, the command
%S = venn(..., 'Plot', 'off) will return only the output structure.
%
%[...] = venn(..., P1, V1, P2, V2, ...) 
%Specifies additional patch settings in standard Matlab parameter/value 
%pair syntax. Parameters can be any valid patch parameter. Values for patch 
%parameters can either be single values, or a cell array of length LENGTH(A), 
%in which case each value in the cell array is applied to the corresponding 
%circle in A.
%
%Examples
%
%   %Plot a simple 2-circle venn diagram with custom patch properties
%   figure, axis equal, axis off
%   A = [300 200]; I = 150;
%   venn(A,I,'FaceColor',{'r','y'},'FaceAlpha',{1,0.6},'EdgeColor','black')
%
%   %Compare ErrMinModes
%   A = [350 300 275]; I = [100 80 60 40];
%   figure
%   subplot(1,3,1), h1 = venn(A,I,'ErrMinMode','None');
%   axis image,  title ('No 3-Circle Error Minimization')
%   subplot(1,3,2), h2 = venn(A,I,'ErrMinMode','TotalError');
%   axis image,  title ('Total Error Mode')
%   subplot(1,3,3), h3 = venn(A,I,'ErrMinMode','ChowRodgers');
%   axis image, title ('Chow-Rodgers Mode')
%   set([h1 h2], 'FaceAlpha', 0.6)
%
%   %Using the same areas as above, display the error optimization at each 
%   iteration. Get the output structure.
%   F = struct('Display', 'iter');
%   [H,S] = venn(A,I,F,'ErrMinMode','ChowRodgers','FaceAlpha', 0.6);
%
%   %Now label each zone 
%   for i = 1:7
%       text(S.ZoneCentroid(i,1), S.ZoneCentroid(i,2), ['Zone ' num2str(i)])
%   end
%
%See also patch, bar, optimset, fminbdn, fminsearch
%
%Copyright (C) 2008 Darik Gamble, University of Waterloo.
%dgamble@engmail.uwaterloo.ca
%
%References
%1. S Chow and P Rodgers. Extended Abstract: Constructing Area-Proportional
%   Venn and Euler Diagrams with Three Circles. Presented at Euler Diagrams 
%   Workshop 2005. Paris. Available online: 
%   http://www.cs.kent.ac.uk/pubs/2005/2354/content.pdf
%
%2. S Chow and F Ruskey. Drawing Area-Proportional Venn and Euler Diagrams. 
%   Lecture Notes in Computer Science. 2004. 2912: 466-477. Springer-Verlag. 
%   Available online: http://www.springerlink.com/content/rxhtlmqav45gc84q/
%
%3. MP Fewell. Area of Common Overlap of Three Circles. Australian Government 
%   Department of Defence. Defence Technology and Science Organisation. 2006. 
%   DSTO-TN-0722. Available online:
%   http://dspace.dsto.defence.gov.au/dspace/bitstream/1947/4551/4/DSTO-TN-0722.PR.pdf


%Variable overview
%   A0, A   Desired and actual circle areas
%               A = [A1 A2] or [A1 A2 A3]
%   I0, I   Desired and actual intersection areas
%               I = I12 or [I12 I13 I23 I123]
%   Z0, Z   Desired and actual zone areas
%               Z = [Z1 Z2 Z12] or [Z1 Z2 Z3 Z12 Z13 Z23 Z123]
%   x, y    Circle centers
%               x = [x1 x2] or [x1 x2 x3]
%   r       Circle radii
%               r = [r1 r2] or [r1 r2 r3]
%   d       Pair-wise distances between circles
%               d = d12 or [d12 d13 d23]
    


    %Parse input arguments and preallocate settings
    [A0, I0, Z0, nCirc, fminOpts, vennOpts, patchOpts] = parseArgsIn (varargin);
    [d, x, y, A, I, Z] = preallocVectors (nCirc);
    zoneCentroids = []; %Will only be calculated if needed
    
    %Circle Radii
    r = sqrt(A0/pi);

    %Determine distance between first circle pair    
    d(1) = circPairDist(r(1), r(2), I0(1), fminOpts(1));
    
    %Position of second circle is now known
    x(2) = d(1); 
    
    %First intersection area 
    I(1) = areaIntersect2Circ(r(1), r(2), d(1));
    
    if nCirc==3
        %Pairwise distances for remaining pairs 1&3 and 2&3
        d(2) = circPairDist(r(1), r(3), I0(2), fminOpts(1)); %d13
        d(3) = circPairDist(r(2), r(3), I0(3), fminOpts(1)); %d23

        %Check triangle inequality
        srtD = sort(d);
        if ~(srtD(end)<(srtD(1)+srtD(2)))
            error('venn:triangleInequality', 'Triangle inequality not satisfied')
        end

        %Guess the initial position of the third circle using the law of cosines
        alpha = acos( (d(1)^2 + d(2)^2 - d(3)^2)  / (2 * d(1) * d(2)) );
        x(3) = d(2)*cos(alpha);
        y(3) = d(2)*sin(alpha);

        %Each pair-wise intersection fixes the distance between each pair
        %of circles, so technically there are no degrees of freedom left in
        %which to adjust the three-circle intersection. We can either try
        %moving the third circle around to minimize the total error, or
        %apply Chow-Rodgers 
        
        switch vennOpts.ErrMinMode
            case 'TotalError'
                %Minimize total intersection area error by moving the third circle
                pos = fminsearch(@threeCircleAreaError, [x(3) y(3)], fminOpts(2));
                x(3) = pos(1);
                y(3) = pos(2);
            case 'ChowRodgers'
                %note that doChowRodgersSearch updates x and y in this
                %workspace as a nested fcn
                doChowRodgersSearch;
        end

        %Make sure everything is 'up to date' after optimization
        update3CircleData;
        
    end
    
    %Are we supposed to plot?
    if vennOpts.Plot
        if isempty(vennOpts.Parent)
            vennOpts.Parent = gca;
        end
        hVenn = drawCircles(vennOpts.Parent, x, y, r, patchOpts.Parameters, patchOpts.Values);
    else
        hVenn = [];
    end
    
    %Only determine zone centroids if they're needed 
    %Needed for output structure 
    nOut = nargout;
    if (nOut==1 && ~vennOpts.Plot) || nOut==2
        if nCirc == 2
            %Need to calculate new areas
            A = A0; %Areas never change for 2-circle venn
            Z = calcZoneAreas(2, A, I);
            zoneCentroids = zoneCentroids2(d, r, Z);
        else
            zoneCentroids = zoneCentroids3(x, y, d, r, Z);
        end
    end
        
    %Figure out output arguments
    if nOut==1
        if vennOpts.Plot
            varargout{1} = hVenn;
        else
            varargout{1} = getOutputStruct;
        end
    elseif nOut==2
        varargout{1} = hVenn;
        varargout{2} = getOutputStruct;
    end
        
    
    
    function err = threeCircleAreaError (pos)
        
        x3 = pos(1);
        y3 = pos(2);
        
        %Calculate distances
        d(2) = sqrt(x3^2 + y3^2); %d13
        d(3) = sqrt((x3-d(1))^2 + y3^2); %d23
        
        %Calculate intersections
        %Note: we're only moving the third circle, so I12 is not changing
        I(2:3) = areaIntersect2Circ (r(1:2), r([3 3]), d(2:3)); %I13 and I23
        I(4) = areaIntersect3Circ (r, d); %I123
        
        %Replace 0 (no intersection) with infinite error
        I(I==0) = Inf;
        
        %Error
        err = sum(abs((I-I0)./I0));
        
    end


    function doChowRodgersSearch
        
        %Adapted from Ref. [1]
        
        %Initialize an index matrix to select all 7choose2 zone pairs (21 pairs)
        idx = nchoosek(1:7, 2);
                
        %Which zone-zone pairs are considered equal?
        %Zones within 10% of each other considered equal
        zonePairAreas0 = Z0(idx);
        
        %Percent difference in population between the two members of a pair
        ar0 = 2*abs(zonePairAreas0(:,1)-zonePairAreas0(:,2))./sum(zonePairAreas0, 2)*100;
        eqPairCutoff = 10;  
        pairIsEq = ar0<=eqPairCutoff;
        
        %Calculate allowable range for pairs of zones considered unequal
        if any(~pairIsEq)
            %Sort zone areas
            [zUneqAreas0, zUneqAreasSrtIdx] = sort(zonePairAreas0(~pairIsEq,:), 2);
            
            %Make a real index array out of the inconvenient index sort returns
            n = sum(~pairIsEq);
            zUneqAreasSrtIdx = sub2ind([n,2], [1:n; 1:n]', zUneqAreasSrtIdx);
            
            %rp = (largepopulation/smallpopulation)-1
            rp = zUneqAreas0(:,2)./zUneqAreas0(:,1)-1;
            rpMin = 1 + 0.3*rp;
            rpMax = 1 + 2*rp;
        end
        
        %Preallocate zone error vector
        zoneErr = zeros(1,21); 

        %Initialize independent parameters to search over
        guessParams = [r(1) x(2) r(2) x(3) y(3) r(3)];
        
        %Search!
        pp = fminsearch(@chowRodgersErr, guessParams, fminOpts(2));  
        
        [r(1) x(2) r(2) x(3) y(3) r(3)] = deal(pp(1), pp(2), pp(3), pp(4), pp(5), pp(6));
        
        
        function err = chowRodgersErr (p)
            
            %params = [x2 r2 x3 y3 r3]
            [r(1), x(2), r(2), x(3), y(3), r(3)] = deal(p(1), p(2), p(3), p(4), p(5), p(6));
             
            %After changing x2, r2, x3, y3, and r3, update circle areas,
            %distances, intersection areas, zone areas
            update3CircleData;

            if any(pairIsEq)
                %For zone pairs considered equal, error is equal to square of the
                %distance beyond the cutoff; 0 within cutoff
                zAreas = Z(idx(pairIsEq,:));
                ar = 2*abs(zAreas(:,1)-zAreas(:,2))./sum(zAreas, 2)*100;
                isWithinRange = ar<eqPairCutoff;
                ar(isWithinRange) = 0;
                ar(~isWithinRange) = ar(~isWithinRange) - eqPairCutoff;

                %Amplify error for equal zones with unequal areas
                eqZoneUneqAreaErrorGain = 10;
                ar(~isWithinRange) = ar(~isWithinRange)*eqZoneUneqAreaErrorGain;

                zoneErr(pairIsEq) = ar.^2;
            end

            if any(~pairIsEq)
                %For zone pairs considered unequal, error is equal to square of
                %the distance from the allowable range of rp

                %rp = (largepopulation/smallpopulation)-1
                zUneqPairAreas = Z(idx(~pairIsEq,:));
                
                %Sort based on the population sizes (determined by parent
                %function doChowRodgersSearch)
                zUneqPairAreas = zUneqPairAreas(zUneqAreasSrtIdx);
                rp = zUneqPairAreas(:,2)./zUneqPairAreas(:,1)-1;

                lessThanMin = rp<rpMin;
                moreThanMax = rp>rpMax;
                rp(~lessThanMin & ~moreThanMax) = 0;
                
                %Determine how far out of range errors are
                rp(lessThanMin) = rp(lessThanMin) - rpMin(lessThanMin);
                rp(moreThanMax) = rp(moreThanMax) - rpMax(moreThanMax);          

                %Consider the case where rp < rpMin to be more
                %erroneous than the case where rp > rpMax 
                tooSmallErrorGain = 10;
                rp(lessThanMin) = rp(lessThanMin)*tooSmallErrorGain;

                zoneErr(~pairIsEq) = rp.^2;
            end
            
            %Total error
            err = sum(zoneErr);
            
        end %chowRodgersErr
        
    end %doChowRodgersSearch

    function update3CircleData
        
        %Circle areas
        A = pi*r.^2;

        %Calculate distances
        d(1) = abs(x(2)); %d12
        d(2) = sqrt(x(3)^2 + y(3)^2); %d13
        d(3) = sqrt((x(3)-d(1))^2 + y(3)^2); %d23

        %Calculate actual intersection areas
        I(1:3) = areaIntersect2Circ (r([1 1 2]), r([2 3 3]), d); %I12, I13, I23
        I(4) = areaIntersect3Circ (r, d); %I123

        %Calculate actual zone areas
        Z = calcZoneAreas(3, A, I);

    end

    function S = getOutputStruct
               
        S = struct(...
            'Radius'                ,r                      ,...        
            'Position'              ,[x' y']                ,...
            'ZoneCentroid'          ,zoneCentroids          ,...
            'CirclePop'             ,A0                     ,...
            'CircleArea'            ,A                      ,...
            'CircleAreaError'       ,(A-A0)./A0             ,...
            'IntersectPop'          ,I0                     ,...
            'IntersectArea'         ,I                      ,...
            'IntersectError'        ,(I-I0)./I0             ,...
            'ZonePop'               ,Z0                     ,...
            'ZoneArea'              ,Z                      ,...
            'ZoneAreaError'         ,(Z-Z0)./Z0             );  
        end

end %venn

        
function D = circPairDist (rA, rB, I, opts)
    %Returns an estimate of the distance between two circles with radii rA and
    %rB with area of intersection I
    %opts is a structure of FMINBND search options
    D = fminbnd(@areadiff, 0, rA+rB, opts);
    function dA = areadiff (d)
        intersectArea = areaIntersect2Circ (rA, rB, d);
        dA = abs(I-intersectArea)/I;
    end
end

function hCirc = drawCircles(hParent, xc, yc, r, P, V)

    hAx = ancestor(hParent, 'axes');
    nextplot = get(hAx, 'NextPlot');
    
    %P and V are cell arrays of patch parameter/values
    xc = xc(:); yc = yc(:);     %Circle centers
    r = r(:);                   %Radii
    n = length(r);              
    
    %Independent parameter
    dt = 0.05;
    t = 0:dt:2*pi;

    %Origin centered circle coordinates
    X = r*cos(t);
    Y = r*sin(t);
    
    hCirc = zeros(1,n);
    c = {'r', 'g', 'b'};                        %default colors
    fa = {0.6, 0.6, 0.6};                         %default face alpha
    tag = {'Circle1', 'Circle2', 'Circle3'}; 	%default tag
    
    for i = 1:n
        xx = X(i,:)+xc(i);  
        yy = Y(i,:)+yc(i);
        hCirc(i) = patch (xx, yy, c{i}, 'FaceAlpha', fa{i}, 'Parent', hParent, 'Tag', tag{i});
        if i==1
            set(hAx, 'NextPlot', 'add');
        end
    end
    set(hAx, 'NextPlot', nextplot);

    %Custom patch parameter values
    if ~isempty(P)

        c = cellfun(@iscell, V);

        %Scalar parameter values -- apply to all circles
        if any(~c)
            set(hCirc, {P{~c}}, {V{~c}});
        end

        %Parameters values with one value per circle
        if any(c)
            %Make sure all vals are column cell arrays
            V = cellfun(@(val) (val(:)), V(c), 'UniformOutput', false);
            set(hCirc, {P{c}}, [V{:}])
        end
    end
    
end %plotCircles

 
function A = areaIntersect2Circ (r1, r2, d)
    %Area of Intersection of 2 Circles
    %Taken from [2]
    
    alpha = 2*acos( (d.^2 + r1.^2 - r2.^2)./(2*r1.*d) );
    beta  = 2*acos( (d.^2 + r2.^2 - r1.^2)./(2*r2.*d) );
    
    A =    0.5 * r1.^2 .* (alpha - sin(alpha)) ...  
         + 0.5 * r2.^2 .* (beta - sin(beta));
    
end

function [A, x, y, c, trngArea] = areaIntersect3Circ (r, d)
    %Area of common intersection of three circles
    %This algorithm is taken from [3]. 
    %   Symbol    Meaning
    %     T         theta
    %     p         prime
    %     pp        double prime
        
    %[r1 r2 r3] = deal(r(1), r(2), r(3));
    %[d12 d13 d23] = deal(d(1), d(2), d(3));

    %Intersection points
    [x,y,sinTp,cosTp] = intersect3C (r,d);
    
    if any(isnan(x)) || any(isnan(y))
        A = 0;
        %No three circle intersection
        return
    end
    
    %Step 6. Use the coordinates of the intersection points to calculate the chord lengths c1,
    %c2, c3:
    i1 = [1 1 2];
    i2 = [2 3 3];
    c = sqrt((x(i1)-x(i2)).^2 + (y(i1)-y(i2)).^2)';

    %Step 7: Check whether more than half of circle 3 is included in the circular triangle, so
    %as to choose the correct expression for the area
    lhs = d(2) * sinTp;
    rhs = y(2) + (y(3) - y(2))/(x(3) - x(2))*(d(2)*cosTp - x(2));
    if lhs < rhs
        sign = [-1 -1 1];
    else
        sign = [-1 -1 -1];
    end
    
    %Calculate the area of the three circular segments.
    ca = r.^2.*asin(c/2./r) + sign.*c/4.*sqrt(4*r.^2 - c.^2);

    trngArea = 1/4 * sqrt( (c(1)+c(2)+c(3))*(c(2)+c(3)-c(1))*(c(1)+c(3)-c(2))*(c(1)+c(2)-c(3)) );
    A = trngArea + sum(ca);
    
end

function [x, y, sinTp, cosTp] = intersect3C (r, d)
    %Calculate the points of intersection of three circles
    %Adapted from Ref. [3]
    
    %d = [d12 d13 d23]
    %x = [x12; x13; x23]
    %y = [y12; y13; y23]

    %   Symbol    Meaning
    %     T         theta
    %     p         prime
    %     pp        double prime
    
    x = zeros(3,1);
    y = zeros(3,1);
     
    %Step 1. Check whether circles 1 and 2 intersect by testing d(1)
    if ~( ((r(1)-r(2))<d(1)) && (d(1)<(r(1)+r(2))) )
        %x = NaN; y = NaN;
        %bigfix: no returned values for sinTp, cosTp
        [x, y, sinTp, cosTp] = deal(NaN);
        return
    end

    %Step 2. Calculate the coordinates of the relevant intersection point of circles 1 and 2:
    x(1) = (r(1)^2 - r(2)^2 + d(1)^2)/(2*d(1));
    y(1) = 0.5/d(1) * sqrt( 2*d(1)^2*(r(1)^2 + r(2)^2) - (r(1)^2 - r(2)^2)^2 - d(1)^4 );

    %Step 3. Calculate the values of the sines and cosines of the angles tp and tpp:
    cosTp  =  (d(1)^2 + d(2)^2 - d(3)^2) / (2 * d(1) * d(2));
    cosTpp = -(d(1)^2 + d(3)^2 - d(2)^2) / (2 * d(1) * d(3));
    sinTp  =  (sqrt(1 - cosTp^2));
    sinTpp =  (sqrt(1 - cosTpp^2));

    %Step 4. Check that circle 3 is placed so as to form a circular triangle.
    cond1 = (x(1) - d(2)*cosTp)^2 + (y(1) - d(2)*sinTp)^2 < r(3)^2;
    cond2 = (x(1) - d(2)*cosTp)^2 + (y(1) + d(2)*sinTp)^2 > r(3)^2;
    if  ~(cond1 && cond2)
        x = NaN; y = NaN;
        return
    end

    %Step 5: Calculate the values of the coordinates of the relevant intersection points involving
    %circle 3
    xp13  =  (r(1)^2 - r(3)^2 + d(2)^2) / (2 * d(2));
    %yp13  = -0.5 / d(2) * sqrt( 2 * d(2)^2 * (r(2)^2 + r(3)^2) - (r(1)^2 - r(3)^2)^2 - d(2)^4 );
    yp13  = -0.5 / d(2) * sqrt( 2 * d(2)^2 * (r(1)^2 + r(3)^2) - (r(1)^2 - r(3)^2)^2 - d(2)^4 );

    x(2)   =  xp13*cosTp - yp13*sinTp;
    y(2)   =  xp13*sinTp + yp13*cosTp;

    xpp23 =  (r(2)^2 - r(3)^2 + d(3)^2) / (2 * d(3));
    ypp23 =  0.5 / d(3) * sqrt( 2 * d(3)^2 * (r(2)^2 + r(3)^2) - (r(2)^2 - r(3)^2)^2 - d(3)^4 );

    x(3) = xpp23*cosTpp - ypp23*sinTpp + d(1);
    y(3) = xpp23*sinTpp + ypp23*cosTpp;

end



function z = calcZoneAreas(nCircles, a, i)
    
    %Uses simple set addition and subtraction to calculate the zone areas
    %with circle areas a and intersection areas i

    if nCircles==2
        %a = [A1 A2]
        %i = I12
        %z = [A1-I12, A2-I12, I12]
        z = [a(1)-i, a(2)-i, i];
    elseif nCircles==3
        %a = [A1  A2  A3]
        %i = [I12 I13 I23 I123]
        %z = [A1-I12-I13+I123, A2-I12-I23+I123, A3-I13-I23+I123, ...
        %     I12-I123, I13-I123, I23-I123, I123];
        z = [a(1)-i(1)-i(2)+i(4), a(2)-i(1)-i(3)+i(4), a(3)-i(2)-i(3)+i(4), ...
                i(1)-i(4), i(2)-i(4), i(3)-i(4), i(4)];
    else
        error('')
        %This error gets caught earlier in the stack w. better error msgs
    end
end

function [Cx, Cy, aiz] = centroid2CI (x, y, r)

    %Finds the centroid of the area of intersection of two circles.
    %Vectorized to find centroids for multiple circle pairs
    %x, y, and r are nCirclePairs*2 arrays
    %Cx and Cy are nCirclePairs*1 vectors

    %Centroid of the area of intersection of two circles
    n = size(x,1);
    xic = zeros(n,2);
    az = zeros(n,2);
    
    dx = x(:,2)-x(:,1);
    dy = y(:,2)-y(:,1);
    d = sqrt(dx.^2 + dy.^2);
    
    %Translate the circles so the first is at (0,0) and the second is at (0,d)
    %By symmetry, all centroids are located on the x-axis.
    %The two circles intersect at (xp, yp) and (xp, -yp)
    xp = 0.5*(r(:,1).^2 - r(:,2).^2 + d.^2)./d;

    %Split the inner zone in two
    %Right side (Area enclosed by circle 1 and the line (xp,yp) (xp,-yp)
    %Angle (xp,yp) (X1,Y1) (xp,-yp)
    alpha = 2*acos(xp./r(:,1));
    %Area and centroid of the right side of the inner zone
    [xic(:,1) az(:,1)] = circleChordVals (r(:,1), alpha);
    %Angle (xp,yp) (X2,Y2) (xp,-yp)
    alpha = 2*acos((d-xp)./r(:,2));
    %Area and centroid of the left side of the inner zone
    [xic(:,2) az(:,2)] = circleChordVals (r(:,2), alpha);
    xic(:,2) = d - xic(:,2);

    %Thus the overall centroid  & area of the inner zone
    aiz = sum(az,2);
    Cx = sum(az.*xic,2)./aiz;
    
    %Now translate the centroid back based on the original positions of the
    %circles
    theta = atan2(dy, dx);
    Cy = Cx.*sin(theta) + y(:,1);
    Cx = Cx.*cos(theta) + x(:,1);
    
end

function centroidPos = zoneCentroids2 (d, r, Z)
    
    centroidPos = zeros(3,2);
    
    %Find the centroids of the three zones in a 2-circle venn diagram
    %By symmetry, all centroids are located on the x-axis.
    %First, find the x-location of the middle (intersection) zone centroid
    
    %Centroid of the inner zone
    centroidPos(3,1) = centroid2CI([0 d], [0 0], r);
    
    %Now, the centroid of the left-most zone is equal to the centroid of
    %the first circle (0,0) minus the centroid of the inner zone
    centroidPos(1,1) = -centroidPos(3,1)*Z(3)/Z(1);
    
    %Similarly for the right-most zone; the second circle has centroid at x=d
    centroidPos(2,1) = (d*(Z(2)+Z(3)) - centroidPos(3,1)*Z(3))/Z(2);
    
end

function centroidPos = zoneCentroids3 (x0, y0, d, r, Z)

    Z = Z(:);
        
    %Get area, points of intersection, and chord lengths
    [act, xi, yi, c, atr] = areaIntersect3Circ (r, d);
    atr = atr(:);
    r = r(:);
    
    %Area and centroid of the triangle within the circular triangle is
    xtr = sum(xi/3); 
    ytr = sum(yi/3);
        
    %Now find the centroids of the three segments surrounding the triangle
    i = [1 2; 1 3; 2 3]; 
    xi = xi(i); yi = yi(i);
    [xcs, ycs, acs] = circSegProps (r(:), x0(:), y0(:), xi, yi, c(:));
    
    %Overall centroid of the circular triangle
    xct = (xtr*atr + sum(xcs.*acs))/act;
    yct = (ytr*atr + sum(ycs.*acs))/act;
    
    %Now calculate the centroids of the three two-pair intersection zones
    %(Zones 12 13 23)
    %Entire zone centroid/areas

    %x, y, and r are nCirclePairs*2 arrays
    %Cx and Cy are nCirclePairs*1 vectors
    i = [1 2; 1 3; 2 3];
    [x2c, y2c, a2c] = centroid2CI (x0(i), y0(i), r(i));
    
    %Minus the three-circle intersection zone
    xZI2C = (x2c.*a2c - xct*act)./(a2c-act);
    yZI2C = (y2c.*a2c - yct*act)./(a2c-act);
    
    x0 = x0(:);
    y0 = y0(:);
    
    %Finally, the centroids of the three circles minus the intersection
    %areas
    i1 = [4 4 5]; i2 = [5 6 6];
    j1 = [1 1 2]; j2 = [2 3 3];
    x1C = (x0*pi.*r.^2 - xZI2C(j1).*Z(i1) - xZI2C(j2).*Z(i2) - xct*act)./Z(1:3);
    y1C = (y0*pi.*r.^2 - yZI2C(j1).*Z(i1) - yZI2C(j2).*Z(i2) - yct*act)./Z(1:3);
    
    %Combine and return
    centroidPos = [x1C y1C; xZI2C yZI2C; xct yct];
end


function [x, a] = circleChordVals (r, alpha)
    %For a circle centered at (0,0), with angle alpha from the x-axis to the 
    %intersection of the circle to a vertical chord, find the x-centroid and
    %area of the region enclosed between the chord and the edge of the circle
    %adapted from http://mathworld.wolfram.com/CircularSegment.html
    a = r.^2/2.*(alpha-sin(alpha));                         %Area
    x = 4.*r/3 .* sin(alpha/2).^3 ./ (alpha-sin(alpha));    %Centroid
end

function [xc, yc, area] = circSegProps (r, x0, y0, x, y, c)

    %Translate circle to (0,0)
    x = x-[x0 x0];
    y = y-[y0 y0];

    %Angle subtended by chord
    alpha = 2*asin(0.5*c./r);
       
    %adapted from http://mathworld.wolfram.com/CircularSegment.html
    area = r.^2/2.*(alpha-sin(alpha));                         %Area
    d   = 4.*r/3 .* sin(alpha/2).^3 ./ (alpha-sin(alpha));    %Centroid
   
    %Perpindicular bisector of the chord
    m = -(x(:,2)-x(:,1))./(y(:,2)-y(:,1));
    
    %angle of bisector
    theta = atan(m);
    
    %centroids
    xc = d.*cos(theta);
    yc = d.*sin(theta);
    
    %Make sure we're on the correct side
    %Point of intersection of the perp. bisector and the circle perimeter
    xb = (x(:,1)+x(:,2))/2;
    xc(xb<0) = xc(xb<0)*-1;
    yc(xb<0) = yc(xb<0)*-1;
    
    %Translate back
    xc = xc + x0;
    yc = yc + y0;
end


function [A0, I0, Z0, nCircles, fminOpts, vennOpts, patchOpts] = parseArgsIn (args)

    [A0, I0, Z0] = deal([]);
    nIn = length(args);
    badArgs = false;
    
    %Get the easy cases out of the way
    if nIn == 0
        badArgs = true;
    elseif nIn == 1
        %venn(Z)
        Z0 = args{1};
        nIn = 0;
    elseif nIn == 2
        if isnumeric(args{2})
            %venn (A,I)
            [A0, I0] = deal(args{1:2});
            nIn = 0;
        else
            %venn (Z, F)
            Z0 = args{1};
            args = args(2);
            nIn = 1;
        end
    else
        %Find the first non-numeric input arg
        i = find(~cellfun(@isnumeric, args), 1);
        if i == 2
            %venn(Z, ....)
            Z0 = args{1};
        elseif i == 3
            %venn(A, I, ...)
            [A0, I0] = deal(args{1:2});
        else
            badArgs = true;
        end
        nIn = nIn - i + 1;
        args = args(i:end);
    end
    
    if badArgs
        error('venn:parseInputArgs:unrecognizedSyntax', 'Unrecogized input syntax')
    end
    try
        [A0, I0, Z0] = parseInputAreas (A0, I0, Z0);
    catch
        error('venn:parseArgsIn:parseInputAreas', 'Incorrect size(s) for area vector(s)')
    end
    nCircles = length(A0);
    nZones = length(Z0);
             
    %Any arguments left?
    if nIn > 0 
        
        if isstruct(args{1})
            %FMIN search options
            f = args{1};
           
            nIn = nIn - 1;
            if nIn>0, args = args(2:end); end

            if length(f) == 1
                %Just double up
                fminOpts = [f f];
            elseif length(f) == 2
                %ok
                fminOpts = f;
            else
                error('venn:parseArgsIn', 'FMINOPTS must be a 1 or 2 element structure array.')
            end
        else
            %Use defaults
            fminOpts = [optimset('fminbnd'), optimset('fminsearch')];
        end
    else
        %Use defaults
        fminOpts = [optimset('fminbnd'), optimset('fminsearch')];
    end

    %If there's an even number of args in remaining
    if nIn>0 
        if mod(nIn, 2)==0
            %Parameter/Value pairs
            p = args(1:2:end);
            v = args(2:2:end);
            [vennOpts, patchOpts] = parsePVPairs (p, v, nZones);
        else
            error('venn:parseArgsIn', 'Parameter/Value options must come in pairs')
        end
    else
        vennOpts = defaultVennOptions;
        patchOpts = struct('Parameters', [], 'Values', []);
    end

end %parseArgsIn

function [vennOpts, patchOpts] = parsePVPairs (p, v, nZones)

    p = lower(p);

    %Break up P/V list into Venn parameters and patch parameters
    vennParamNames = {'plot', 'errminmode', 'parent'};
    [isVennParam, idx] = ismember(p, vennParamNames);
    idx = idx(isVennParam);
    %vennParams = p(isVennParam);
    vennVals = v(isVennParam);
    
    %First do Patch options
    patchOpts.Parameters = p(~isVennParam);
    patchOpts.Values = v(~isVennParam);
        
    %Now do Venn options
    vennOpts = defaultVennOptions;
        
    %PLOT
    i = find(idx==1, 1);
    if i
        plot = lower(vennVals{i});
        if islogical(plot)
            vennOpts.Plot = plot;
        else
            if ischar(plot) && any(strcmp(plot, {'on', 'off'}))
                vennOpts.Plot = strcmp(plot, 'on');
            else
                error('venn:parsePVPairs', 'Plot must be ''on'', ''off'', or a logical value.')
            end
        end
    end
    
    %ERRMINMODE
    i = find(idx==2, 1);
    if i
        mode = lower(vennVals{i});
        okModes = {'None', 'TotalError', 'ChowRodgers'};
        [isOkMode, modeIdx] = ismember(mode, lower(okModes));
        if isOkMode                
            vennOpts.ErrMinMode = okModes{modeIdx};
        else
            error('venn:parsePVPairs', 'ErrMinMode must be None, TotalError, or ChowRodgers')
        end
    end

    %PARENT
    i = find(idx==5, 1);
    if i
        h = v{i};
        if length(h)==1 && ishandle(h) 
            vennOpts.Parent = h;
        else
            error('venn:parsePVPairs', 'Parent must be a valid scalar handle')
        end
    end
    
       
end %parsePVPairs

function [A0, I0, Z0] = parseInputAreas (A0, I0, Z0)

    %Switch to row vectors
    A0 = A0(:)';
    I0 = I0(:)';
    Z0 = Z0(:)';

    if isempty(Z0)
        %A0 and I0 supplied
        
        Z0 = calcZoneAreas (length(A0), A0, I0);
    else
        %Z0 supplied
        switch length(Z0)
            case 3
                A0 = Z0(1:2)+Z0(3);
                I0 = Z0(3);
            case 7
                A0 = Z0(1:3)+Z0([4 4 5])+Z0([5 6 6])+Z0(7);
                I0 = [Z0(4:6)+Z0(7) Z0(7)];
            otherwise
                error('')
        end
    end
end

function vennOpts = defaultVennOptions 
    
    vennOpts = struct(...
        'Plot'          ,true               ,...
        'Labels'        ,[]                 ,...
        'PopLabels'     ,false              ,...
        'DrawLabels'    ,false              ,...
        'Parent'        ,[]                 ,...
        'Offset'        ,[0 0]              ,...
        'ErrMinMode'    ,'TotalError'       );
    
end

function [d, x, y, A, I, Z] = preallocVectors (nCirc)

    %Initialize position vectors
    x = zeros(1, nCirc);
    y = zeros(1, nCirc);

    if nCirc==2
        d = 0;
        I = 0;    
        A = zeros(1,2);
        Z = zeros(1,3);

    else %nCirc==3
        d = zeros(1,3);
        I = zeros(1,4);
        A = zeros(1,3);
        Z = zeros(1,7);
    end
end

    
    
        

