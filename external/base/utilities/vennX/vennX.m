function error = vennX( data, resolution )
%
% function error = vennX( data, resolution )
%
% vennX - draws an area proportional venn diagram
%
% Draws a venn diagram (either two or three set) using
% circles, where the area of each region is proportional
% to the input values.
%
% INPUT:
%      data - a vector of counts for each set partition
%            
%          For a two circle diagram:
%            data is a three element vector of:
%              |A|  
%              |A and B|  
%              |B| 
%        
%          For a three circle diagram:
%            data is a seven element vector of:
%               |A|
%               |A and B|
%               |B|
%               |B and C|
%               |C|
%               |C and A|
%               |A and B and C|
%
%       resolution - A measure of accuracy on the image,
%            typical values are within 1/100 to 1/1000 of
%            the maximum partition count.  Note that smaller
%            resolutions take longer compute time.
%
% OUTPUT:
%     error - the difference in area of each partition 
%             between the actual area and the input vector
%
% EXAMPLES:
%
%     vennX( [ 106 26 257 ], .05 )
%
%     vennX( [ 75 143 210 ], .1 )
%
%     vennX( [ 16 3 10 6 19 8 3 ], .05 )
%
%
% COMMENTS: 
% 
%     The implementation is trivial, for the two circle case, two circles
%       are drawn to scale and moved closer and closer together until the 
%       overlap is 'near' to the desired intersection. For the three
%       circle case, it is repeated three times, once for each pair of
%       circles.  Hence the two circle case is almost exact, whereas the
%       three circle case has much more error since the area |A and B and C|  
%       is derived.  This means that large variations from random, especially 
%       close to zero, will have larger errors, for example
%
%           vennX( [ 20 10 20 10 20 10 0], .1 )
%
%       as opposed to 
%
%           vennX( [ 20 10 20 10 20 10 10], .1 )
%
% ENHANCEMENTS
%
%     The implementation could be sped up tremendously using a MRA
%     (multi-resolutional analysis) type algorithm.  e.g. start with a
%     resolution of .5 and find the distance between the circles, then use
%     that as a seed for a resolution of .1, then .05, .01, etc.
%
%     The error vector could be used as a measure to 'perturb' the position
%     of the third circle as to minimize the error.  This could be done
%     with a simple gradient descent method.  This would help the
%     exceptions described above where the distribution deviates from
%     random.
%
%     When small mishapen areas are drawn, the text does not match up, e.g.
%        vennX( [ 15 143 210 ], .1 )
%
%
%  Original implementation and method by Jeremy Heil, for the Order of 
%  the Red Monkey, and the Tengu
%
%  Oct. 2004
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

   figure;
   
   if length( data ) == 3
      dist = venn2( data(1), data(2), data(3), resolution );
      error = plot_venn2( data(1), data(2), data(3), resolution, dist );
      error = data - error';
   elseif length( data ) == 7 
       %get the pairwise distance of each circle center from each other
       dist_A_B = venn2( data(1)+data(6), data(2)+data(7), data(3)+data(4), resolution );
       dist_B_C = venn2( data(3)+data(2), data(4)+data(7), data(5)+data(6), resolution );
       dist_A_C = venn2( data(1)+data(2), data(6)+data(7), data(4)+data(5), resolution );

       error = plot_venn3( data(1), data(2), data(3), data(4), data(5), data(6), data(7), ...
           resolution, dist_A_B, dist_B_C, dist_A_C );
       error = data - error';
   else
       'vennX error, data vector must be of length 3 or 7'
   end
    
    %change the colormap so that the background is white    
    k = colormap;
    k = [ 1 1 1; k ];
    colormap(k)
    axis off   
   
function error = plot_venn3( a, b, c, d, e, f, g, resolution, dist_A_B, dist_B_C, dist_A_C )
    
    r1 = sqrt( (a+b+f+g)/pi );
    r2 = sqrt( (b+c+d+g)/pi );
    r3 = sqrt( (d+e+f+g)/pi );
    
    %
    % Using a little geometry, think of the three circle's centers
    % as vertecies of a triangle.
    %
    y = ( dist_A_C^2 - dist_B_C^2 + dist_A_B^2 ) / 2 / dist_A_B;
    
    size_x = max( r1 + dist_A_B + r2, 2*r3 );
    size_y = max( r1, r2 ) + sqrt( dist_A_C^2 - y^2 ) + r3;

    %find the circle centers
    center1_x = r1;
    center1_y = max( r1, r2 );
    center2_x = r1 + dist_A_B;
    center2_y = center1_y;    
    center3_x = r1 + y;
    center3_y = center1_y + sqrt( dist_A_C^2 - y^2 );
        
    [X,Y] = meshgrid( 0:resolution:size_x, 0:resolution:size_y );

    %draw the circles
    img = zeros( size(Y,1), size(Y,2) );
    
    img = img + 2 .* ( (X - center1_x).^2 + (Y - center1_y).^2 < r1^2 );
    img = img + 4 .* ( (X - center2_x).^2 + (Y - center2_y).^2 < r2^2 );
    img = img + 6 .* ( (X - center3_x).^2 + (Y - center3_y).^2 < r3^2 );
    
    clf
    imagesc(img)
    hold on
    
    
    %add the numbers and compute the error for each partition
    error = [];
    
    tmp = and( and( ...
           (X - center1_x).^2 + (Y - center1_y).^2 < r1^2, ...
           (X - center2_x).^2 + (Y - center2_y).^2 > r2^2 ), ...
           (X - center3_x).^2 + (Y - center3_y).^2 > r3^2 );
    [ i,j ] = find( tmp > 0 );   
    error = [ error; sum(sum(tmp)) * resolution^2 ];
    text_x = mean(j);
    text_y = mean(i);
    h = text( text_x, text_y, num2str( a ) );
    set( h, 'FontWeight', 'bold' )
    
    tmp = and( and( ...
           (X - center1_x).^2 + (Y - center1_y).^2 < r1^2, ...
           (X - center2_x).^2 + (Y - center2_y).^2 < r2^2 ), ...
           (X - center3_x).^2 + (Y - center3_y).^2 > r3^2 );
    [ i,j ] = find( tmp > 0 );   
    error = [ error; sum(sum(tmp)) * resolution^2 ];
    text_x = mean(j);
    text_y = mean(i);
    h = text( text_x, text_y, num2str( b ) );
    set( h, 'FontWeight', 'bold' )
    
    tmp = and( and( ...
           (X - center1_x).^2 + (Y - center1_y).^2 > r1^2, ...
           (X - center2_x).^2 + (Y - center2_y).^2 < r2^2 ), ...
           (X - center3_x).^2 + (Y - center3_y).^2 > r3^2 );
    [ i,j ] = find( tmp > 0 );   
    error = [ error; sum(sum(tmp)) * resolution^2 ];
    text_x = mean(j);
    text_y = mean(i);
    h = text( text_x, text_y, num2str( c ) );
    set( h, 'FontWeight', 'bold' )
    
    tmp = and( and( ...
           (X - center1_x).^2 + (Y - center1_y).^2 > r1^2, ...
           (X - center2_x).^2 + (Y - center2_y).^2 < r2^2 ), ...
           (X - center3_x).^2 + (Y - center3_y).^2 < r3^2 );
    [ i,j ] = find( tmp > 0 );   
    error = [ error; sum(sum(tmp)) * resolution^2 ];
    text_x = mean(j);
    text_y = mean(i);
    h = text( text_x, text_y, num2str( d ) );
    set( h, 'FontWeight', 'bold' )
    
    tmp = and( and( ...
           (X - center1_x).^2 + (Y - center1_y).^2 > r1^2, ...
           (X - center2_x).^2 + (Y - center2_y).^2 > r2^2 ), ...
           (X - center3_x).^2 + (Y - center3_y).^2 < r3^2 );
    [ i,j ] = find( tmp > 0 );   
    error = [ error; sum(sum(tmp)) * resolution^2 ];
    text_x = mean(j);
    text_y = mean(i);
    h = text( text_x, text_y, num2str( e ) );
    set( h, 'FontWeight', 'bold' )
    
    tmp = and( and( ...
           (X - center1_x).^2 + (Y - center1_y).^2 < r1^2, ...
           (X - center2_x).^2 + (Y - center2_y).^2 > r2^2 ), ...
           (X - center3_x).^2 + (Y - center3_y).^2 < r3^2 );
    [ i,j ] = find( tmp > 0 );   
    error = [ error; sum(sum(tmp)) * resolution^2 ];
    text_x = mean(j);
    text_y = mean(i);
    h = text( text_x, text_y, num2str( f ) );
    set( h, 'FontWeight', 'bold' )
    
    tmp = and( and( ...
           (X - center1_x).^2 + (Y - center1_y).^2 < r1^2, ...
           (X - center2_x).^2 + (Y - center2_y).^2 < r2^2 ), ...
           (X - center3_x).^2 + (Y - center3_y).^2 < r3^2 );
    [ i,j ] = find( tmp > 0 );   
    error = [ error; sum(sum(tmp)) * resolution^2 ];
    text_x = mean(j);
    text_y = mean(i);
    h = text( text_x, text_y, num2str( g ) );
    set( h, 'FontWeight', 'bold' )
    
function error = plot_venn2( a, b, c, resolution, dist )

    r1 = sqrt( (a+b)/pi );
    r2 = sqrt( (b+c)/pi );
    
    size_x = r1 + dist + r2;
    size_y = max( 2*r1, 2*r2 );
    
    center1_x = r1;
    center1_y = size_y/2;
    center2_x = r1 + dist;
    center2_y = size_y/2;;
    
    [X,Y] = meshgrid( 0:resolution:size_x, 0:resolution:size_y );
    
    %draw the two circles and the overlap region
    img = zeros( size(Y,1), size(Y,2) );
    
    img = img + 2 .* ( (X - center1_x).^2 + (Y - center1_y).^2 < r1^2 );
    img = img + 4 .* ( (X - center2_x).^2 + (Y - center2_y).^2 < r2^2 );
    
    imagesc(img)
    hold on
    
    %
    % We want to draw the numbers at the center of mass
    % do this by computing the average x and y coordinates of
    % the center of each partition piece.
    %
    % Compute the error for each partition as the difference
    % between the area we meant to draw and the actual area
    % that was drawn
    %
    error = [];
    tmp = and( ...
           (X - center1_x).^2 + (Y - center1_y).^2 < r1^2, ...
           (X - center2_x).^2 + (Y - center2_y).^2 > r2^2 );
    [ i,j ] = find( tmp > 0 );   
    error = [ error; sum(sum(tmp)) * resolution^2 ];
    text_x = mean(j);
    text_y = mean(i);
    h = text( text_x, text_y, num2str( a ) );
    set( h, 'FontWeight', 'bold' )
    
    tmp = and( ...
           (X - center1_x).^2 + (Y - center1_y).^2 < r1^2, ...
           (X - center2_x).^2 + (Y - center2_y).^2 < r2^2 );
    [ i,j ] = find( tmp > 0 );   
    error = [ error; sum(sum(tmp)) * resolution^2 ];
    text_x = mean(j);
    text_y = mean(i);
    h = text( text_x, text_y, num2str( b ) );
    set( h, 'FontWeight', 'bold' )

    tmp = and( ...
           (X - center1_x).^2 + (Y - center1_y).^2 > r1^2, ...
           (X - center2_x).^2 + (Y - center2_y).^2 < r2^2 );
    [ i,j ] = find( tmp > 0 );   
    error = [ error; sum(sum(tmp)) * resolution^2 ];
    text_x = mean(j);
    text_y = mean(i);
    h = text( text_x, text_y, num2str( c ) );
    set( h, 'FontWeight', 'bold' )

    
function dist = venn2( a, b, c, resolution )
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %VENN2
    %  dist = venn2( a, b, c, resolution )
    %
    % Computes the distance between the centers of 
    % the two venn diagram circles.
    %
    % a          - values of A
    % b          - value of A and B
    % c          - value of B
    % resolution - measure of error 
    %
    % dist       - the distance between the two centers
    %
    %  Does this by plotting the two circles in an
    % image with the specified resolution and
    % moving the centers towards each other until
    % the area of intersection is nearest the value
    % of b
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    r1 = sqrt( (a+b)/pi );
    r2 = sqrt( (b+c)/pi );
    
    size_x = 2*r1+2*r2;
    size_y = max( 2*r1, 2*r2 );
    
    center1_x = r1;
    center1_y = size_y/2;
    center2_x = 2*r1 + r2;
    center2_y = size_y/2;;
    
    [X,Y] = meshgrid( 0:resolution:size_x, 0:resolution:size_y );
    
    for new_center = (2*r1 + r2):-resolution:r1
    
        img = zeros( size(Y,1), size(Y,2) );
        img = and( (X - center1_x).^2 + (Y - center1_y).^2 < r1^2, ...
            (X - new_center).^2 + (Y - center2_y).^2 < r2^2 );
    
        if sum(sum(img)) * resolution^2 > b
            break
        end
    end
    
    dist = new_center - center1_x;