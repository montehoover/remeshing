function [faces,vertices,nvertedge]=DiskMeshI(n)
%mesh generator for a circular disk of integer radius n
%with vertices located at the center and on the circles of integer radius
%nvertedge is the number of vertices on the disk edge
%written by Nail Gumerov on February 10, 2016

r=linspace(0,n,n+1);
NR=floor(2*pi*r);
nvertedge=NR(n+1);
Nr=sum(NR);
xs=zeros(1,Nr+1); 
ys=zeros(1,Nr+1);
j2=0;
for i=1:n+1
    j1=j2+1;
    t=linspace(0,2*pi,NR(i)+1); t=t(1:NR(i));
    j2=j2+NR(i);
    xs(j1:j2)=r(i)*cos(t); ys(j1:j2)=r(i)*sin(t);
end; 
vertices=zeros(Nr+1,3);
vertices(:,1)=xs';
vertices(:,2)=ys';
faces=delaunay(xs,ys);
