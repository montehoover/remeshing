function [min_angle, max_angle, imin_angle, imax_angle] = get_angle_stats(faces, vertices, c1, c2, c3)
    % Get quality value Q of mesh that takes both
    % Aspect Ratio (penalizes both small and obtuse angles)
    % of all triangles and also the ratio of the smallest to
    % largest triangles in the mesh.
    %
    % Input:
    %   faces    # List of integers indicating the three vertex
    %            # indices for each triangle face in the mesh
    %            # Array dimensions: |F| x 3
    %   vertices # List of floats representing the xyz coordinates
    %            # of each vertex in the mesh.
    %            # Array dimensions: |V| x 3
    %   c1, c2, c3  # Optional. Provide already computed cosines for faster
    %               # calculation.
    % Output:
    %
    
    if nargin < 3
        [c1, c2, c3] = get_cosines(faces, vertices);
    end
    
    % Get min and max angle in mesh in degrees
    [minc1,mic1]=min(c1); 
    [maxc1,mac1]=max(c1);
    [minc2,mic2]=min(c2); 
    [maxc2,mac2]=max(c2);
    [minc3,mic3]=min(c3); 
    [maxc3,mac3]=max(c3);
    minset=[minc1 minc2 minc3]; 
    iminset=[mic1 mic2 mic3];
    maxset=[maxc1 maxc2 maxc3]; 
    imaxset=[mac1 mac2 mac3];
    [mins,imins]=min(minset); 
    [maxs,imaxs]=max(maxset); 
    imin_angle=imaxset(imaxs);
    imax_angle=iminset(imins);
    min_angle=180/pi*acos(maxs);
    max_angle=180/pi*acos(mins);




