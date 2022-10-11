function AR = get_AR(faces, vertices, c1, c2, c3)
    % Aspect Ratio (penalizes both small and obtuse angles)
    % of all triangles
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
    %   AR_max    
    %   AR_avg

    % TODO: In the future consider adding percent of angles under 30 degrees or over 120 degrees (or 90?)
    % and the percentof vertices with valence > 7. Maybe even add something about area ratios of adjacent
    % triangles. All of these things only matter if they impact downstream tasks. Are all downstream tasks
    % captured in the condition matrix of the mesh?

    if nargin < 3
        [c1, c2, c3] = get_cosines(faces, vertices);
    end

    % Get Aspect Ratio (AR) of every triangle
    % Report in "twice incircle over circumcircle" ratio (ranges from 0 to 1, with 1 being ideal).
    AR = 2 * (c1+c2+c3-1);
    
    % Replace all Inf values with largest possible single precision float
    % AR(AR == Inf) = realmax("single");
