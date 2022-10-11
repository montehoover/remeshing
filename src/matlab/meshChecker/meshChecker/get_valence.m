function [minval,maxval,iminval,imaxval] = get_valence(faces, vertices)
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
    %   valence stats
  
    hedges=getHalfEdges(faces);
    fedges=getFullEdges(hedges);
    [val,minval,maxval,iminval,imaxval]=valency2(fedges);