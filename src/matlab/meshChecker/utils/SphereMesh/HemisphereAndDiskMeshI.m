function [faces,vertices,indfS,indfD]=HemisphereAndDiskMeshI(nS,nD,plusminus)
%integer radius hemisphere (nS) and surrounding integer radius disk (nD)
%for positive or negatve elevation, setermined by the sign of plusminus

[faces,vertices]=DiskMeshI(nD);
nv=numel(vertices)/3; nf=numel(faces)/3;
r2=dot(vertices,vertices,2);
suvs=find(r2<(nS-0.1)*(nS-0.1)); nvs=numel(suvs);
theta=pi/2*sqrt(r2(suvs))/nS;
phi=atan2(vertices(suvs,2),vertices(suvs,1));
vertices(suvs,1)=nS*sin(theta).*cos(phi);
vertices(suvs,2)=nS*sin(theta).*sin(phi);
vertices(suvs,3)=sign(plusminus)*nS*cos(theta);
ff=(1:nf)';
i1=ismember(faces(:,1),suvs); 
i2=ismember(faces(:,2),suvs); i2=i1|i2;
i3=ismember(faces(:,3),suvs); i3=i3|i2;
sufs=ff(i3);
indfS=sufs';
indfD=setdiff((1:nf)',indfS);