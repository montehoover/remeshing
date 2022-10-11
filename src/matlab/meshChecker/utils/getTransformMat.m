function M = getTransformMat(a, b, c)
    % Given 3 indices of triangle in xyz space, 
    % find 3x2 transform matrix to project to 2D local coordinates
    % preserving lengths and angles
    % global vertices;
    
    % A = vertices(a, :); B = vertices(b, :); C = vertices(c, :); 
    A=a; B=b; C=c;
    
    % Special cases causing singular L: 
    % any points close to origin
    % parallel to xy, yz, xz planes 
    
    eps = 1e-4;
    
    if(aboutEqualsScalar(A(1), 0, eps) && aboutEqualsScalar(B(1), 0, eps) && aboutEqualsScalar(C(1), 0, eps))
        M=[0,0; 1,0; 0,1];
        return;
    elseif(aboutEqualsScalar(A(2), 0, eps) && aboutEqualsScalar(B(2), 0, eps) && aboutEqualsScalar(C(2), 0, eps))
        M=[1,0; 0,0; 0,1];
        return;
    elseif(aboutEqualsScalar(A(3), 0, eps) && aboutEqualsScalar(B(3), 0, eps) && aboutEqualsScalar(C(3), 0, eps))
        M=[1,0; 0,1; 0,0];
        return;
    elseif(norm(A) < eps || norm(B) < eps || norm(C) < eps)
        A(1)=A(1)+1; B(1) = B(1)+1; C(1) = C(1) + 1;
    end
    
    L = [A; B; C]; BA = B-A; NBA = norm(BA); CA=C-A; NCA = norm(CA);
    l1 = NBA; l2 = NCA;
    dn = dot(BA, CA)/(NBA * NCA);
    assert(abs(dn) <= 1);
    omega = acos(dn);
    if(omega < pi/2 && omega > 0)
        x1=sin(omega)*l1;
        y1=sqrt(l2^2 - x1^2);
    elseif(omega > pi/2)
        omega1 = pi-omega;
        x1=sin(omega1)*l2;
        y1=-sqrt(l2^2 - x1^2);
    else
        x1=l2;
        y1=0;
    end

    rhs = [0,0 ; 0, l1; x1, y1];
    M = L\rhs;
end
