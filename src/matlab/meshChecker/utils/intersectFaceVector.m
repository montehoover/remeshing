function [ei, fnext, y2i] = intersectFaceVector(faceIndex, edgeIndex, u_surfacegrad, yi)
% Return which surrounding edge of edgeIndex u_surfacegrad intersects
% https://stackoverflow.com/questions/563198/how-do-you-detect-where-two-line-segments-intersect/565282#565282

    global fedges
    global vertices
    global faces
    
    % Use only xy coords
    q=yi(1:2); s=u_surfacegrad(1:2);
    
    % establish 4 edges
    v1 = fedges(edgeIndex, 1); v2=fedges(edgeIndex, 2);
    fa = fedges(edgeIndex, 3); fb = fedges(edgeIndex, 4);
    v3 = setdiff(faces(fa, :), [v1, v2]); v4 = setdiff(faces(fb, :), [v1, v2]);
    
    edgeVs = [v1, v3, fa; v2, v3, fa; v1, v4, fb; v2, v4, fb];
    
    % e1 = findEdge2(p1, p3); e2 = findEdge2(p2, p3);
    % e3 = findEdge2(p1, p4); e4 = findEdge2(p2, p4);
    
    % edgeVs = [fedges(e1, 1:2); fedges(e2, 1:2); fedges(e3, 1:2); fedges(e4, 1:2)];
    
    for i=1:4
        vx1 = edgeVs(i, 1); vx2 = edgeVs(i, 2);
        VX1 = vertices(vx1, 1:2); VX2 = vertices(vx2, 1:2);
        r = VX2 - VX1; a1 = q-VX1; rs = (r(1)*s(2) - r(2)*s(1));
        qvxs = (a1(1)*s(2) - a1(2)*s(1));
        qvxr = (a1(1)*r(2) - a1(2)*r(1)); 
        t = qvxs / rs;
        u = qvxr/ rs;
        
        if(rs == 0 && qvxr ~= 0)
            % Collinear and overlapping
        elseif(rs == 0 && qvxr ~= 0)
            % Parallel
            
        elseif(rs ~= 0 && (t>=0 && t <=1) && (u>=0 && u<=1))
            % intersection found
            ei = findEdge2(vx1, vx2);
            fintersect = edgeVs(i, 3);
            fnext = setdiff(fedges(ei, 3:4), fintersect);
            % 3D
            y2i = yi+u*u_surfacegrad;
            break;
        end
    end
end


