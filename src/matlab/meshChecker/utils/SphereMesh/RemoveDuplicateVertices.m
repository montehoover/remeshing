function [faces,vertices]=RemoveDuplicateVertices(faces1,vertices1,tol)
%merges vertices with tolerance tol (for discrepancy <tol<1 in each coordinate) from the mesh
%faces(Nf,3); vertices(Nv,3)
%written by Nail Gumerov on 02/11/2016

rdigits=ceil(abs(log10(tol)));
vert=Round(vertices1,rdigits); %round(vertices1,rdigits);
[~,ia,ic]=unique(vert,'rows');
vertices=vertices1(ia,:);
faces=ic(faces1(:));
faces=reshape(faces,numel(faces)/3,3);



