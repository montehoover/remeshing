function dmin=get_minrib(faces,vertices)
x1=vertices(faces(:,1),:); 
x2=vertices(faces(:,2),:); 
x3=vertices(faces(:,3),:);
d1=x1-x2; d2=x2-x3; d3=x3-x1;
d1=dot(d1,d1,2); d2=dot(d2,d2,2); d3=dot(d3,d3,2);
dmin=min(d1); dmin=min(dmin,min(d2)); dmin=min(dmin,min(d3));
dmin=sqrt(dmin);