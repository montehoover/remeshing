function res = aboutEqualsScalar(a, b, tol)
    % Whether two scalars are about equals wrt to some tolerance
    res = abs(a-b) < tol;
end
