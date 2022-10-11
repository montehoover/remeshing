function [val,minval,maxval,iminval,imaxval]=valency2(edges)

nvert=max(edges(:,2));
nedge=numel(edges)/4;

edgesR=zeros(2*nedge,2);
edgesR(1:nedge,:)=edges(:,1:2);
edgesR(nedge+1:2*nedge,1)=edges(:,2);
edgesR(nedge+1:2*nedge,2)=edges(:,1);

a=sort(edgesR(:,1));
[~,ia,~]=unique(a,'first','legacy');
neibkmrk=zeros(nvert+1,1);
neibkmrk(1:nvert)=ia;
neibkmrk(nvert+1)=2*nedge+1;               %vertex neighbor bookmark

val=neibkmrk(2:nvert+1)-neibkmrk(1:nvert);
[minval,iminval]=min(val);
[maxval,imaxval]=max(val);