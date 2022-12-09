function [faces, vertices] = decrease_quality(faces, vertices, splits, stochastic, coverage, split_size)

if nargin < 6
    split_size = 10;  % denominator
end
if nargin < 5
    coverage = 0.5;
end
if nargin < 4
    stochastic = true;
end
if nargin < 3
    splits = 1;
end

edges=getRibs(faces,vertices);

% Create array to track edges available for splitting. Also create list of
% edges belonging to each face to use for marking off edges as unavailable
available = ones(length(edges), 1);
face_edges = get_face_edges(faces, edges);
faces_modified = zeros(length(faces), 1);
new_faces = [];
for i = 1:length(edges)
    if available(i) && rand() < coverage
        va = edges(i,1); 
        vb = edges(i,2); 
        f1 = edges(i,3); 
        f2 = edges(i,4);
        
        % Get value of third vertex in f1/f2; whatever is not va and vb must be vc
        f1v = faces(f1, :);
        f1vc = f1v(f1v ~= va & f1v ~= vb);
        f2v = faces(f2, :);
        f2vc = f2v(f2v ~= va & f2v ~= vb);
        
        % Determine orientation of face so new faces follow the same orientation
        i1a = find(f1v == va);
        i1b = find(f1v == vb);
        i1c = find(f1v == f1vc);
        i2a = find(f2v == va);
        i2b = find(f2v == vb);
        i2c = find(f2v == f2vc);
        
        % Let n equal number of new faces to split into; 10 faces requires 9
        % new vertices. We make splits to the two faces either side of a given
        % edge.
        n = splits;
        % Not the clearest here, but split size is the denominator in the
        % fraction below. The intention is to choose arbitrarily skinny
        % splits. If split_size is 10 and splits is 1, then we add 1 new
        % vertex at 1/10th of the way along an edge. We can choose to add 2
        % or more of these slices, but it doesn't make sense to add more
        % than 10 of them. In most cases I use 1 split and vary the
        % coverage and split size to get the quality decrease I want.
        if n > split_size
            n = split_size;
        end
        m = 3;
        num_vertices = length(vertices);
        edge_vector = vertices(vb, :) - vertices(va, :);
        prev_v = va;
        new_vertex_index = 0;
        for j = 1:n-1
            % Skip adding vertices randomly if called with stochastic
            % setting
%             if stochastic && rand() > coverage
%                 continue;
%             end
            new_vertex = vertices(va, :) + (j/split_size) * edge_vector;
            num_vertices = num_vertices + 1;
            new_vertex_index = num_vertices;
            vertices(new_vertex_index, :) = new_vertex;
            % Make sure to follow same orientation as previous face
            new_face1([i1a i1b i1c]) = [prev_v new_vertex_index f1vc];
            new_face2([i2a i2b i2c]) = [prev_v new_vertex_index f2vc];
            new_faces = [new_faces; new_face1; new_face2];
            prev_v = new_vertex_index;
        end
        % Add the nth (last) new face
        if new_vertex_index
            new_face1([i1a i1b i1c]) = [new_vertex_index vb f1vc];
            new_face2([i2a i2b i2c]) = [new_vertex_index vb f2vc];
            new_faces = [new_faces; new_face1; new_face2];
            % Mark all edges of both of the original two faces as unavailable for
            % splitting
            available(face_edges(f1, :)) = 0;
            available(face_edges(f2, :)) = 0;
            faces_modified(f1) = 1;
            faces_modified(f2) = 1;
        end
    end
end

% Keep the original faces that were not mod
for i = 1:length(faces)
    if faces_modified(i) == 0
        new_faces = [new_faces; faces(i, :)];
    end
end
faces = new_faces;
