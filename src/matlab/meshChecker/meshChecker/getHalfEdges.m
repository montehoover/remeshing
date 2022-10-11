function hedges=getHalfEdges(faces)
%half-edge data structure
%written by Nail Gumerov on 02/19/2018
nf=size(faces,1); nf3=3*nf;
hedges=zeros(nf3,3);
v1=faces(:,1); v2=faces(:,2); v3=faces(:,3);
hedges(1:3:nf3,1)=v1; hedges(1:3:nf3,2)=v2; hedges(1:3:nf3,3)=(1:nf)';
hedges(2:3:nf3,1)=v2; hedges(2:3:nf3,2)=v3; hedges(2:3:nf3,3)=(1:nf)';
hedges(3:3:nf3,1)=v3; hedges(3:3:nf3,2)=v1; hedges(3:3:nf3,3)=(1:nf)';
