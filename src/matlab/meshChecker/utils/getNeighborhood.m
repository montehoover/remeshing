function [nghs] = getNeighborhood(v, n)
    % Get n-ring neighborhood of vertex v    
    nghs = dfsFind(n, v, -1, []);
    nghs = unique(setdiff(nghs, v));
end
