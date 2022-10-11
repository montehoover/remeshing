function fig = plotSurfaceNormals(faces, vertices)
    
    fig=figure;
    trisurf(faces, vertices(:, 1), vertices(:, 2), vertices(:,3),... 
        'FaceColor','cyan','FaceAlpha',0.8); axis equal; hold on;
    [normals,centers,~] = getnormalscenters(faces, vertices);
    
    quiver3(centers(:, 1), centers(:, 2), centers(:, 3), ...
        normals(:, 1), normals(:, 2), normals(:, 3), 2, 'color', 'r');
end
