function [min_sizeS, max_sizeS, imin_sizeS, imax_sizeS]=get_area_stats(faces,vertices)
% Get the smallest and largest triangles in the mesh.
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

% Separate all vertices into arrays that correspond to points 1, 2, and 3 of each triangle face
% Each array is dimension |F| x 3 (each point is in xyz coords)
x1=vertices(faces(:,1),:);
x2=vertices(faces(:,2),:);
x3=vertices(faces(:,3),:);

% Get min and max area (smallest and largest triangle)
v=cross(x3-x1,x2-x1);
S=.5*sqrt(dot(v',v'));
[max_sizeS, imax_sizeS]=max(S);
[min_sizeS, imin_sizeS]=min(S);

