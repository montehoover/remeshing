function fedges=getFullEdges(hedges)
%full-edge data structure
%written by Nail Gumerov on 02/19/2018
v1=hedges(:,1); v2=hedges(:,2); f=hedges(:,3);
nv=max(v1); nv=max(nv,max(v2));
s=[min(v1,v2) max(v1,v2)];
IndxEdges1=(s(:,1)-1)*nv+s(:,2);

[sIndxEdges1,PermIndx]=sort(IndxEdges1);
sv1=s(PermIndx,1); sv2=s(PermIndx,2); sf=f(PermIndx);
[~,ia1] = unique(sIndxEdges1,'first','legacy');
[~,ia2] = unique(sIndxEdges1,'last','legacy');

nfedges=numel(ia1);
fedges=zeros(nfedges,4);
fedges(:,1)=sv1(ia1); fedges(:,2)=sv2(ia1); 
fedges(:,3)=sf(ia1); fedges(:,4)=sf(ia2);
su= fedges(:,3)==fedges(:,4);
fedges(su,4)=0;
