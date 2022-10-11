function val = getValence(vindx, neibkmrk)
    val = neibkmrk(vindx+1) - neibkmrk(vindx);
end
