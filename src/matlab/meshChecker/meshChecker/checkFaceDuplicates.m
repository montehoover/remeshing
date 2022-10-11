function [N] = checkFaceDuplicates(faces)
% Checks whether all faces have 3 unique vertexIDs
    S=sum(diff(sort(faces,2),1,2)~=0,2)+1;
    S1 = 3*ones(size(S));
    N = 0;
    if(norm(S-S1) ~=0)
        % Return indices of faces with duplicate values
        E = find(S-S1); N = numel(E);
    end
end
