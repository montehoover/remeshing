function edge = findEdge(v1, v2, vedges, fedges, b1, b2)
    % Find edge connecting v1->v2
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
