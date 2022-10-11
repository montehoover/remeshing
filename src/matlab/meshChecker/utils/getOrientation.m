function or = getOrientation(v1, v2, v3)
% TODO: Function that returns orientation ccw or cw of triangle face
    global vertices
    global faces
    
    V1 = vertices(v1, :);
    V2 = vertices(v2, :);
    V3 = vertices(v3, :);
    
    % Line between V1 and V3 as one axis
    L1=V3-V1;
    
    % orthogonal line as other axis
    
    
end


