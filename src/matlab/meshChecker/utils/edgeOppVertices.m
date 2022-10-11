function [x3, x4] = edgeOppVertices(ei)
    % Given edge index ei, get two opposite vertices
    global fedges
    global faces 
    
    f1 = fedges(ei, 3); f2 = fedges(ei, 4);
    v1 = fedges(ei, 1); v2 = fedges(ei, 2);
    x3 = setdiff(faces(f1, :), [v1, v2]); x4 = setdiff(faces(f2, :), [v1, v2]);
    
end

