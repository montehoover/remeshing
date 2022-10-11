function [] = clearMesh()
    global fedges;
    global edgesR;
    global vneis;
    global neibkmrk;
    global vedges;
    global faces;
    global vertices;
    
    vars = {'fedges', 'edgesR', 'vneis', 'neibkmrk', 'vedges', 'faces', 'vertices'};
    clear(vars{:});
end
