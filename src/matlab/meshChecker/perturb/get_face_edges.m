% Scan list of edges and get indexes for the three edges that belong to
% each face.

function face_edges = get_face_edges(faces, edges)
face_edges = cell(length(faces), 1);
for i = 1:length(edges)
    f1 = edges(i, 3);
    f2 = edges(i, 4);
    % Append edge index to entry for given face
    face_edges{f1} = [face_edges{f1} i];
    face_edges{f2} = [face_edges{f2} i];
end
face_edges = cell2mat(face_edges);
