function [c1, c2, c3]=get_cosines(faces,vertices)
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
    % Output:
    % 

    % TODO: In the future consider adding percent of angles under 30 degrees or over 120 degrees (or 90?)
    % and the percentof vertices with valence > 7. Maybe even add something about area ratios of adjacent
    % triangles. All of these things only matter if they impact downstream tasks. Are all downstream tasks
    % captured in the condition matrix of the mesh?

    % Separate all vertices into arrays that correspond to points 1, 2, and 3 of each triangle face
    % Each array is dimension |F| x 3 (each point is in xyz coords)
    x1=vertices(faces(:,1),:);
    x2=vertices(faces(:,2),:);
    x3=vertices(faces(:,3),:);
    % Transpose the arrays. Now dimension 3 x |F|
    x1=x1'; x2=x2'; x3=x3';
    % Get lengths of all three sides of each triangle (will take sqrt a couple lines later)
    l1=sqrt(dot(x1-x2,x1-x2));
    l2=sqrt(dot(x3-x2,x3-x2)); 
    l3=sqrt(dot(x3-x1,x3-x1)); 

    % Get cosines
    c1=dot(x3-x1,x2-x1)./(l3.*l1); % Do element-wise divison and multiplication with ./ and .*
    c2=dot(x3-x2,x1-x2)./(l2.*l1); 
    c3=dot(x1-x3,x2-x3)./(l3.*l2);