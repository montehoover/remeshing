function edge = findEdge2(v1, v2)
    % Find edge connecting v1->v2 in fedges
    % findEdge2(v1, v2)
    
    global vedges
    global fedges
    global neibkmrk
    
    b1 = neibkmrk(v1); b2 = neibkmrk(v1+1)-1;
    
    e1 = -1;
    for ij = b1:b2
       e1 = vedges(ij);
       isRightEdge = (fedges(e1, 1) == v1 && fedges(e1, 2) == v2) || (fedges(e1,1) == v2 && fedges(e1,2) == v1);
       if(isRightEdge)
           break;
       end
    end
    if(~isRightEdge)
       error("Edge not found"); 
    end
    
    edge = e1;
end
