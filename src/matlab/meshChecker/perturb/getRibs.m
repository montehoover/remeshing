function Ribs=getRibs(Elements,Vertices)
nel=length(Elements);
nvert=length(Vertices);
nribs1=3*nel;
Ribs1=zeros(nribs1,3);
IndxRibs1=zeros(nribs1,1);

j=0;
for i=1:nel
    n1=Elements(i,1);
    n2=Elements(i,2);
    n3=Elements(i,3);
    j=j+1;
    m1=min(n1,n2);
    m2=max(n1,n2);
    Ribs1(j,3)=i;
    Ribs1(j,1)=m1;
    Ribs1(j,2)=m2;
    Ribs1(j,3)=i;
    IndxRibs1(j)=(m1-1)*nvert+m2;
    j=j+1;
    m1=min(n1,n3);
    m2=max(n1,n3);
    Ribs1(j,3)=i;
    Ribs1(j,1)=m1;
    Ribs1(j,2)=m2;
    Ribs1(j,3)=i;
    IndxRibs1(j)=(m1-1)*nvert+m2;
    j=j+1;
    m1=min(n2,n3);
    m2=max(n2,n3);
    Ribs1(j,3)=i;
    Ribs1(j,1)=m1;
    Ribs1(j,2)=m2;
    Ribs1(j,3)=i;
    IndxRibs1(j)=(m1-1)*nvert+m2;
end;  

[IndxRibsSorted,PermIndx]=sort(IndxRibs1);

nribs=nribs1/2;
Ribs=zeros(nribs,4);

j=0;
for i=1:nribs
    j=j+1;
    jsort1=PermIndx(j);
    j=j+1;
    jsort2=PermIndx(j);
    Ribs(i,1:2)=Ribs1(jsort1,1:2);
    r1=Ribs1(jsort1,3);
    r2=Ribs1(jsort2,3);
    Ribs(i,3)=min(r1,r2);
    Ribs(i,4)=max(r1,r2);
end;
    
