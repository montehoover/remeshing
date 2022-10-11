function dif = checkVertexDuplicates(vertices)
    % Check for duplicate vertices 
    V1 = unique(vertices, 'rows');
    dif = size(vertices, 1)-size(V1, 1);
end
