function [Q, AR_avg, min_angle, AR] = get_mesh_quality(faces, vertices)
    % Get quality stats of mesh. 
    %
    % Input:
    %   faces    # List of integers indicating the three vertex
    %            # indices for each triangle face in the mesh
    %            # Array dimensions: |F| x 3
    %   vertices # List of floats representing the xyz coordinates
    %            # of each vertex in the mesh.
    %            # Array dimensions: |V| x 3
    % Output:
    %   Q        # Q value of entire mesh.
    %   AR_avg
    %   min_angle
   
    [c1, c2, c3] = get_cosines(faces, vertices);
    [min_angle, ~, ~, ~] = get_angle_stats(faces, vertices, c1, c2, c3);
    
    % AR is in 2-to-Inf range
    AR = get_AR(faces, vertices, c1, c2, c3);
    % Convert AR to 0-to-1 range
    % AR = 2 * (1 ./ AR);
    AR_avg = mean(AR, 'omitnan');

    Q = get_Q(faces, vertices, AR);
    