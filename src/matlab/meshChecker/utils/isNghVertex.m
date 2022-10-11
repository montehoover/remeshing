function res = isNghVertex(v1, v2)
% Returns whether vertex v1 is a neighbor of vertex vi
% Output: true/false

global vneis
global neibkmrk
res = false;

b1 = neibkmrk(v1); b2 = neibkmrk(v1+1)-1;

for i = b1:b2
    if(vneis(i) == v2)
        res = true;
        return;
    end
end

end
