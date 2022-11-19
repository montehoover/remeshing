addpath(genpath('src/matlab/meshChecker'));
addpath(genpath('src/matlab/gptoolbox'));

mesh = "data/demo_head.ply"
% mesh = "data/terrain/granite_city.ply";\
% mesh = "data/lion/lion-head_cgal.ply"
[V, F] = readPLY(mesh);

% Test terrain mesh format
% mesh = "data/terrain/gta_building.obj";
% [V, F] = readOBJ(mesh);
% V = [V(:,1) V(:,3) V(:,2)];

% Test plotMesh()
plotMesh(F, V);

% Test get_AR()
% x = get_AR(F, V);
% x(1:5)

% Test get_mesh_quality()
[Q, AR_avg, min_angle, AR] = get_mesh_quality(F, V);
% AR(1:5)
% AR_avg
% max_valence

% Test mesh_checker2q()
mesh_checker2q(F, V);

% % Test decrease_quality()
% disp("Running decrease_quality(). Takes ~5 minutes per 100k faces with these settings...")
% [F, V] = decrease_quality(F, V, 10, true, 0.0145);
% plotMesh(F, V);
% prefix = "C:\Users\monte\code\remeshing\data\BEM\demo_head_only2";
% writePLY(prefix + "_bad.ply", V, F, "ascii");
% mesh_checker2q(F, V);

[F, V] = EllipsoidMeshFromDisk(10,1,1,1,1);
writePLY("data\sphere.ply", V, F);

disp("Tests complete.")
