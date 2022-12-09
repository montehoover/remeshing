function [faces, vertices] = decrease_quality(faces, vertices, perturbation, coverage)
% Decrease the element quality of a triangle mesh by doing a midpoint
% subdivision of each edge and shifting these midpoints by some amount.
% The use case is to run this twice on a given mesh in order to experiment
% with apples-to-apples quality perturbation. If perturbation is 0 then the
% new mesh will have perfect midpoint splits and result in the exact same
% quality characteristics but with 4x elements. Then run a second time with
% some perturbation and you have two meshes with the exact same number of
% elements, the exact same geometry, but different qualities.
%
% If you want to decrease quality by just adding a few narrow angle edges,
% see decrease_quality_stochastic. The disadvantage of that method is you
% are not keeping element count constant.
% input: faces
%        vertices
%        perturbation: value from 0 to 1 indicating how much of the way 
%            toward the end of the edge to move the midpoint split. 1 indicates
%            "move it all the way", resulting in the worst quality possible. 0
%            is a perfect midpoint split.
%        coverage: value from 0 to 1 indicating how many faces to perturb.
%            Faces that are left unperturbed get perfect midpoint splits.
%            If you want to decrease quality without doing midpoint splits
%            and thus keeping the element count closer to the original,
%            consider "decrease_quality_stochastic.m"
%written by Monte Hoover on Dec 6, 2022

if nargin < 3
    perturbation = 0.5;
end
if nargin < 4
    coverage = 1;
end

% 100% perturbation results in degenerate triangles, so decrease slightly
if perturbation == 1
    perturbation = 0.9999;
end
if perturbation > 1 || perturbation < 0
    disp("Expected perturbation to be a percent value from 0 to 1.");
    disp("Setting perturbation to 0 for perfect midpoint splits.")
    perturbation = 0;
end

edges=getRibs(faces,vertices);

% Create list of edges belonging to each face so we can easily iterate over
% faces
face_edges = get_face_edges(faces, edges);
% We are adding one new vertex per edge in the mesh; create a collection to
% store the coordinates of the new vertexes for each edge
new_vertex_indices = zeros(length(edges), 1);
new_faces = [];
count = 0;
for i = 1:length(faces)
    new_vertices_for_this_face = zeros(1, 3);
    % For each edge of the triangle face
    for j = [1 2 3]
%         edge = face_edges(i, j);
%         start_vertex = edges(edge, 1);
%         end_vertex = edges(edge, 2);
        start_vertex = faces(i, j);
        switch j
            case 1
                end_i = 2;
            case 2
                end_i = 3;
            case 3
                end_i = 1;
        end
        end_vertex = faces(i, end_i);

        edge = 0;
        for e = face_edges(i, :)
            if ismember(start_vertex, edges(e, 1:2)) && ismember(end_vertex, edges(e, 1:2))
                edge = e;
            end
        end
        if edge == 0
            disp("Something went wrong: couldn't find edge.")
        end
        
        % Check if we already created a vertex on this edge when
        % processing an adjacent triangle; if not, create a new one. We
        % can access already created vertices by the edge index.
        if new_vertex_indices(edge) ~= 0
            new_vertex_index = new_vertex_indices(edge);
        else
            % Only perturb some percent of faces as specified by coverage;
            % perturbation_factor of 1 produces a midpoint split, which
            % maintains exact element quality
            [num, denom] = rat(coverage);
            % num, denom might be something like 1 and 4 or 5 and 6
            if count < num
                perturb = true;
            else
                perturb = false;
                if count == denom
                    perturb = true;
                    count = 0;
                end
            end
            count = count +1;

            if perturb
                perturbation_factor = 1 - perturbation;
            else
                perturbation_factor = 1;
            end
            edge_vector = vertices(end_vertex, :) - vertices(start_vertex, :);
            new_vertex = vertices(start_vertex, :) + 0.5 * edge_vector * perturbation_factor;
            % Add the new vertex to the vertices list
            new_vertex_index = length(vertices) + 1;
            new_vertex_indices(edge) = new_vertex_index;
            vertices(new_vertex_index, :) = new_vertex;
        end

        new_vertices_for_this_face(j) = new_vertex_index;
    end
    % We just created three new vertices on the edges of a single face.
    % Now create four new faces out of the original face
    orig_v1 = faces(i, 1);
    orig_v2 = faces(i, 2);
    orig_v3 = faces(i, 3);
    new_v1 = new_vertices_for_this_face(1);
    new_v2 = new_vertices_for_this_face(2);
    new_v3 = new_vertices_for_this_face(3);
    new_face1 = [orig_v1, new_v1, new_v3];
    new_face2 = [orig_v2, new_v2, new_v1];
    new_face3 = [orig_v3, new_v3, new_v2];
    new_face4 = [new_v1, new_v2, new_v3];
    new_faces = [new_faces; new_face1; new_face2; new_face3; new_face4];
end

faces = new_faces;
