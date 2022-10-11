% A) Triangle lies on yz, xy, xz plane
a1=[0,0,0]; a2=[0,0,2]; a3=[0,2,0];
M1=getTransformMat(a1,a2,a3);

a1 = [2, 0, 0]; a2=[0,2,0]; a3=[0,0,0];
M2=getTransformMat(a1,a2,a3);

a1 = [2, 0, 0]; a2=[0,0,0]; a3=[0,0,2];
M3=getTransformMat(a1,a2,a3);

% B) Length preserving (lengths: 1, sqrt(2), sqrt(3))
b1=[0,0,0]; b2=[1,1,0]; b3=[0,0,1];
M=getTransformMat(b1,b2,b3);
bb1=b1*M; bb2=b2*M; bb3=b3*M;

assert(norm(bb1 - bb2) == sqrt(2));
assert(norm(bb1 - bb3) == 1);
assert(aboutEqualsScalar(norm(bb3 - bb2), sqrt(3), 1e-8));

% C) omega larger than 90 deg.
c1=[0,0,0]; c2=[1,1,-0.5]; c3=[0,0,1];
Mc=getTransformMat(c1, c2, c3);
cc1=c1*Mc; cc2=c2*Mc; cc3=c3*Mc;
CC=[cc1; cc2; cc3];
figure; plot(CC(:,1), CC(:,2), 's', 'MarkerSize', 14, 'MarkerFaceColor','#ff1a1a');

% D) Test angle preserving

% E) Vector
e1=[0,0,0]; e2=[1,1,0]; e3=[0,0,1];
Me = getTransformMat(e1, e2, e3); Ve=[2, 2, 2];
ee1=e1*Me; ee2=e2*Me; ee3=e3*Me; vee1=Ve*Me;
EE=[ee1; ee2; ee3];
figure; plot(EE(:,1), EE(:,2), 's', 'MarkerSize', 14, 'MarkerFaceColor','#ff1a1a'); hold on;
quiver(ee1(1), ee1(2), vee1(1), vee1(2), 'color', 'b', 'LineWidth', 2, 'ShowArrowHead', 'on');

% F) Vector 2
% face 2: 3896
VF2=[-48.3889,-47.3827,1525.48;-48.2193,-47.2827,1525.71;-48.1428,-46.9827,1525.51];
% face 1: 3895
VF1=[-48.41,-47.0827,1525.21;-48.3889,-47.3827,1525.48;-48.1428,-46.9827,1525.510];
sgrad=[0.639269462716698,0.213129513575316,0.738857472372753];
Ya = [-48.37, -47.36, 1525.2];

M3895 = getTransformMat(VF1(1,:), VF1(2,:), VF1(3,:));
VF1a = VF1(1,:)*M3895; VF1b = VF1(2,:)*M3895; VF1c = VF1(3,:)*M3895;
sgrad1 = sgrad*M3895; Ya1=Ya*M3895;
VFB = [VF1a; VF1b; VF1c];

VF2a = VF2(1,:)*M3895; VF2b = VF2(2,:)*M3895; VF2c = VF2(3,:)*M3895;
VFC = [VF2a; VF2b; VF2c];

figure; plot(VFB(:,1), VFB(:,2), 's', 'MarkerSize', 14, 'MarkerFaceColor','#ff1a1a'); hold on;
quiver(Ya1(1), Ya1(2), sgrad1(1), sgrad1(2), 'color', 'b', 'LineWidth', 2, 'ShowArrowHead', 'on');
figure; plot(VFC(:,1), VFC(:,2), 'o', 'MarkerSize', 14, 'MarkerFaceColor','blue'); hold on;
quiver(Ya1(1), Ya1(2), sgrad1(1), sgrad1(2), 'color', 'b', 'LineWidth', 2, 'ShowArrowHead', 'on');

% F) Test orientation 





