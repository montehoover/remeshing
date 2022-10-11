function [area] = triangleArea(v1, v2, v3)
    % Triangle area given 3 vertices
    
    global vertices
    
    V1 = vertices(v1, :); 
    V2 = vertices(v2, :);
    V3 = vertices(v3, :);
    
    V12 = V2 - V1; V13 = V3 - V1;
    
    area = 0.5*norm(cross(V12, V13));
end

