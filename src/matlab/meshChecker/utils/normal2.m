function normal = normal2(v1, v2)
% Return unit normal to v1 v2 edge
    global vertices
    
    V1 = vertices(v1, :); V2 = vertices(v2, :);
    
    midpt = (V2 + V1)/2;
    
    dx = V2(1) - V1(1);
    dy = V2(2) - V1(2);
    
    normal = [dx, -dy]/norm([dx, -dy]); % could be plus or minus ...
end

