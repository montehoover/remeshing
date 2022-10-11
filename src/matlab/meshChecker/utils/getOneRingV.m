function [vns] = getOneRingV(vindx)
    % Returns set of neighbors of vertex vindx
    % Output: neighbors of vindx

    global vneis
    global neibkmrk
    
    b1 = neibkmrk(vindx); b2 = neibkmrk(vindx+1)-1;
    vns = zeros([b2-b1+1, 1]);
    
    j = 1;
    for i = b1:b2
        vns(j)=vneis(i);
        j=j+1;
    end
end
