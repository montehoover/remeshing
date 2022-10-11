function res = isNghEdge(ei, vi)
% Returns whether edge ei is an outgoing neighbor of vertex vi
% Output: true/false

global vedges
global neibkmrk
res = false;

b1 = neibkmrk(vi); b2 = neibkmrk(vi+1)-1;

for i = b1:b2
    if(vedges(i) == ei)
        res = true;
    end
end

end

