function [lst] = dfsFind(k, vindx, parent, lst)
    global vneis
    global neibkmrk
    
    if(k <= 0)
        return
    end
    
    b1 = neibkmrk(vindx); b2 = neibkmrk(vindx+1)-1;
    
    for i=b1:b2
        vngh = vneis(i);
        if(vngh ~= parent)
            % fprintf("Adding vertex %d\n", vngh);
            lst = [lst; vngh];
            lst1 = dfsFind(k-1, vngh, vindx, lst);
            ab = setdiff(lst1, lst);
            lst = [lst; ab];
        end
    end
    
end


