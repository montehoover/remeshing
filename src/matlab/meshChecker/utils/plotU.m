function fig = plotU(faces, vertices, u)
    fig = figure;
    p = patch('Vertices',vertices,'Faces', faces,'FaceColor','white');
    title("Plot U values (plotU.m)");
    xlabel('x'); ylabel('y'); zlabel('z');
    
    vertexLabels = faces';
    extraLabelVertex = dataTipTextRow('vertex ID', vertexLabels);
    ULabel = dataTipTextRow('U', u(vertexLabels));
    
    DT=datatip(p);
    dtt = p.get('DataTipTemplate');
    dtt.DataTipRows(end+1) = extraLabelVertex;
    dtt.DataTipRows(end+1) = ULabel;
    delete(DT);
end