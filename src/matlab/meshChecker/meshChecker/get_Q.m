function Q = get_Q(faces, vertices, AR)
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
    %   AR       # Optional. Provide already computed AR for faster
    %            # calculation.
    % Output:
    %   Q        # Q value of entire mesh.
   
    if nargin < 3
        AR = get_AR(faces, vertices);
    end
    max_AR = max(AR);
    
    [min_sizeS, max_sizeS, ~, ~]=get_area_stats(faces,vertices);
    max_sizeS=sqrt(max_sizeS)*2/sqrt(sqrt(3));
    min_sizeS=sqrt(min_sizeS)*2/sqrt(sqrt(3));
    
    Q=2*min_sizeS/(max_AR*max_sizeS);