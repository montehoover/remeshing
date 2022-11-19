function [faces,vertices]=UnitSphereMeshFromDisk(nS)
%writen by Nail Gumerov on 08/02/2018
[faces1,vertices1]=HemisphereAndDiskMeshI(nS,nS,1);
vertices1=vertices1/nS;
nf=length(faces1); nv=length(vertices1);
faces2=zeros(2*nf,3); faces2(1:nf,:)=faces1;
vertices2=zeros(2*nv,3); vertices2(1:nv,:)=vertices1;
vertices2(nv+1:2*nv,1:2)=vertices1(:,1:2);
vertices2(nv+1:2*nv,3)=-vertices1(:,3);
faces2(nf+1:2*nf,1)=faces1(:,1)+nv;
faces2(nf+1:2*nf,2)=faces1(:,3)+nv;
faces2(nf+1:2*nf,3)=faces1(:,2)+nv;
dmin=get_minrib(faces1,vertices1);
[faces,vertices]=RemoveDuplicateVertices(faces2,vertices2,0.1*dmin);