function [] = plotMesh(faces, vertices, save, file_name, save_path)
    if nargin < 3
        save = false;
    end
    if nargin < 4
        file_name = "mesh";
    end
    if nargin < 5
        save_path = pwd();
    end
    
    f1 = figure;            
    trisurf(faces,vertices(:,1),vertices(:,2),vertices(:,3)); axis equal;
    xlabel('x'); ylabel('y'); zlabel('z');
    
    if save
        saveas(f1, save_path + "/" + file_name, "png");
    end
end
