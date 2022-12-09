addpath(genpath('src/matlab/meshChecker'));
addpath(genpath('src/matlab/gptoolbox'));

mesh = "C:\Users\monte\code\remeshing_orig\data\BEM\arl_experiment\demo_head_only_10k.ply";
prefix = "C:\Users\monte\code\remeshing_orig\data\BEM\arl_experiment\demo_head_only_10k";

% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0);
% writePLY(prefix + "_bad0.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.1);
% writePLY(prefix + "_bad1.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.2);
% writePLY(prefix + "_bad2.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.3);
% writePLY(prefix + "_bad3.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.4);
% writePLY(prefix + "_bad4.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.5);
% writePLY(prefix + "_bad5.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.6);
% writePLY(prefix + "_bad6.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.7);
% writePLY(prefix + "_bad7.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.8);
% writePLY(prefix + "_bad8.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.6, 0.02);
% writePLY(prefix + "_bad9.ply", V, F, "ascii")
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.65, 0.02);
% writePLY(prefix + "_bad10.ply", V, F, "ascii")
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.7, 0.02);
% writePLY(prefix + "_bad11.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.75, 0.02);
% writePLY(prefix + "_bad12.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.8, 0.02);
% writePLY(prefix + "_bad13.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.85, 0.02);
% writePLY(prefix + "_bad14.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.9, 0.02);
% writePLY(prefix + "_bad15.ply", V, F, "ascii");

% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.985, 0.02);
% writePLY(prefix + "_bad16.ply", V, F, "ascii");

% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.999, 0.02);
% writePLY(prefix + "_bad17.ply", V, F, "ascii");

% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.975, 0.02);
% writePLY(prefix + "_bad18.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.98, 0.02);
% writePLY(prefix + "_bad19.ply", V, F, "ascii");
% 
% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.985, 0.02);
% writePLY(prefix + "_bad20.ply", V, F, "ascii");

[V, F] = readPLY(mesh);
[F, V] = decrease_quality(F, V, 0.85, 1);
writePLY(prefix + "_bad81.ply", V, F, "ascii");

% [V, F] = readPLY(mesh);
% [F, V] = decrease_quality(F, V, 0.999, 1);
% writePLY(prefix + "_bad000.ply", V, F, "ascii");

disp("Tests complete.")
