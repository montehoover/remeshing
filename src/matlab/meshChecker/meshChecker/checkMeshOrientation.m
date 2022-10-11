function badribs=checkMeshOrientation(faces,ribs)
[nribs,dum]=size(ribs);
badribs=[]; j=0;

IND = [];
for n=1:nribs
    va=ribs(n,1); vb=ribs(n,2); f1=ribs(n,3); f2=ribs(n,4);
    f1v=faces(f1,:); f2v=faces(f2,:);
    i1a=find(f1v==va); i1b=find(f1v==vb); i2a=find(f2v==va); i2b=find(f2v==vb);
    ind=abs(i1b-i1a+i2b-i2a);
    if ind==1 | ind==2 | ind==4
        j=j+1;
        badribs(j)=n;
    end;
end;
