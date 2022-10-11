function [max_sizeS,min_sizeS,imax_sizeS,imin_sizeS,...
          min_length,max_length,imin_length,imax_length,...
          min_angle,max_angle,imin_angle,imax_angle,...
          min_q,max_q,imin_q,imax_q,Q]=get_maxminF2q(faces,vertices)

x1=vertices(faces(:,1),:);
x2=vertices(faces(:,2),:);
x3=vertices(faces(:,3),:);
v=cross(x3-x1,x2-x1);
S=.5*sqrt(dot(v',v'));
[max_sizeS,imax_sizeS]=max(S);
[min_sizeS,imin_sizeS]=min(S);
max_sizeS=sqrt(max_sizeS)*2/sqrt(sqrt(3));
min_sizeS=sqrt(min_sizeS)*2/sqrt(sqrt(3));

x1=x1'; x2=x2'; x3=x3';
x31=dot(x3-x1,x3-x1); x32=dot(x3-x2,x3-x2); x12=dot(x1-x2,x1-x2);

[min_length31,i31]=min(x31); [min_length32,i32]=min(x32); [min_length12,i12]=min(x12);
minl=[min_length31 min_length32 min_length12];
iminl=[i31 i32 i12];
[min_length,imin_length]=min(minl);
min_length=sqrt(min_length);
imin_length=iminl(imin_length);

[max_length31,i31]=max(x31); [max_length32,i32]=max(x32); [max_length12,i12]=max(x12);
maxl=[max_length31 max_length32 max_length12];
imaxl=[i31 i32 i12];
[max_length,imax_length]=max(maxl);
max_length=sqrt(max_length);
imax_length=imaxl(imax_length);

c1=dot(x3-x1,x2-x1)./sqrt(x31.*x12); [minc1,mic1]=min(c1); [maxc1,mac1]=max(c1);
c2=dot(x3-x2,x1-x2)./sqrt(x32.*x12); [minc2,mic2]=min(c2); [maxc2,mac2]=max(c2);
c3=dot(x1-x3,x2-x3)./sqrt(x31.*x32); [minc3,mic3]=min(c3); [maxc3,mac3]=max(c3);
q=1./(c1+c2+c3-1);
minset=[minc1 minc2 minc3]; iminset=[mic1 mic2 mic3];
maxset=[maxc1 maxc2 maxc3]; imaxset=[mac1 mac2 mac3];
[mins,imins]=min(minset); imax_angle=iminset(imins);
[maxs,imaxs]=max(maxset); imin_angle=imaxset(imaxs);
[min_q,imin_q]=min(q); [max_q,imax_q]=max(q);
min_angle=180/pi*acos(maxs);
max_angle=180/pi*acos(mins);
Q=2*min_sizeS/(max_q*max_sizeS);

