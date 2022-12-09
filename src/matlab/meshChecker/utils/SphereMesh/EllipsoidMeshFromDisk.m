function [faces,vertices]=EllipsoidMeshFromDisk(nS,a,b,c,show)
%writen by Nail Gumerov on 08/02/2018; 
%modified by Nail Gumerov on 10/30/2018 for ellipsoid
%nS-frequency of the mesh; a,b,c - ellipsoid semiaxes
%if show~=0 also plots the elipsoid
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
vertices(:,1)=vertices(:,1)*a;
vertices(:,2)=vertices(:,2)*b;
vertices(:,3)=vertices(:,3)*c;
if show~=0
    figure;
    trisurf(faces,vertices(:,1),vertices(:,2),vertices(:,3)); 
    axis equal; xlabel('x'); ylabel('y'), zlabel('z');
    title(['Ellipsoid with semiaxes a = ' num2str(a) ', b = ' num2str(b) ', c = ' num2str(c)]); 
end