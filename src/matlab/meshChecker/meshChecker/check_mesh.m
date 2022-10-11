function [is_correct, msg] = check_mesh(faces,vertices,verbose)
% MESH_CHECKER Check mesh for correct connectivity and face/vertex
% uniqueness.
%   faces: faces of the mesh
%   vertices: vertices of the mesh
%   verbose: flag to display runtime messages
%OUTPUTS
%   is_correct: returns True if passes all tests
%   msg: contains information about failed tests, if any.

if nargin < 3
    verbose = false;
end

is_correct = true;
msg = "";

if verbose
    disp('Checking that all faces have 3 unique indices');
end
[ind] = checkFaceDuplicates(faces);
if(ind ~= 0)
    msg = strcat(msg, num2str(ind), " faces with duplicate vertices.\n");
    is_correct = false;
end

if verbose
    disp("Checking that all vertices unique");
end
[N] = checkVertexDuplicates(vertices);
if(N ~= 0)
    msg = strcat(msg, num2str(N), " duplicate vertices.\n");
    is_correct = false;
end

if verbose
    disp('Checking mesh orientation')
end
hedges=getHalfEdges(faces);
fedges=getFullEdges(hedges);
su= fedges(:,4)~=0; 
iedges=fedges(su,:);
badedges=checkMeshOrientation(faces,iedges);  %determine if any internal edge is oriented inconsistently
if numel(badedges)~=0
    msg = strcat(msg, num2str(numel(badedges)), " incorrectly oriented edges.\n");
    is_correct = false;
end

if is_correct
    msg = "Mesh passed basic correctness tests successfully.";
end