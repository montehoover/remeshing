function [res] = inNeighborhood(edgeIndex, v, n)
    % Return whether either vertex on edge edgeIndex 
    % is in the n-ring neighborhood of vertex v2
    
    global fedges;
    
    v1 = fedges(edgeIndex, 1); v2 = fedges(edgeIndex, 2);
    
    % Get n ring neighborhood of v2
    nghs = getNeighborhood(v, n);
    res = (ismember(v1, nghs) || ismember(v2, nghs));
end
