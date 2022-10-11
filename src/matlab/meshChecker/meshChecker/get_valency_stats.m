function  [min_valency, max_valency, imin_valency, imax_valency]=get_valency_stats(faces)
% Get min and max valency of vertices in mesh along with corresponding
% vertices having those valencies
%
% Input:
%   faces    # List of integers indicating the three vertex
%            # indices for each triangle face in the mesh
%            # Array dimensions: |F| x 3

% Output:
%   min_valency
%   max_valency
%   imin_valency
%   imax_valency

half_edges=getHalfEdges(faces);
full_edges=getFullEdges(half_edges);
[all_valencies, min_valency, max_valency, imin_valency, imax_valency]=valency2(full_edges);


