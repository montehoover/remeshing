function da = getDupVerts(vertices)
    % Get indices of vertices which have duplicates
    [~, ia, ~] = unique(vertices, 'rows');
    duplicate_ind = setdiff(1:size(vertices, 1), ia)';
    
    da = find(ismember(vertices, vertices(duplicate_ind, :), 'rows'));
end
