function [val] = getValences(vertices, neibkmrk)
    nvert = numel(vertices)/3;
    val = zeros([nvert, 1]);
    for i = 1:nvert
        val(i) = neibkmrk(i+1)-neibkmrk(i);
    end
    
end