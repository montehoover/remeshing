function badedges = mesh_checker2q(faces,vertices)
% figure;            % show mesh
% trisurf(faces,vertices(:,1),vertices(:,2),vertices(:,3)); axis equal;
% xlabel('x'); ylabel('y'); zlabel('z');

fprintf('\n #faces = %i  #vertices = %i \n',size(faces,1),size(vertices,1));

fprintf('\n');

disp('Checking that all faces have 3 unique indices');
[ind] = checkFaceDuplicates(faces);

if(ind ~= 0)
    msg = strcat(num2str(ind), " faces with duplicate vertices.\n");
    fprintf(msg);
else
    fprintf("Face uniqueness OK\n");
end

disp("Checking that all vertices unique");

[N] = checkVertexDuplicates(vertices);

if(N ~= 0)
    msg = strcat(num2str(N), " duplicate vertices.\n");
    fprintf(msg);
else
    fprintf("Vertex uniqueness OK\n");
end

disp('checking min and max values...')
[max_sizeS,min_sizeS,imax_sizeS,imin_sizeS,...
          min_length,max_length,imin_length,imax_length,...
          min_angle,max_angle,imin_angle,imax_angle,...
          min_q,max_q,imin_q,imax_q,meshQ]=get_maxminF2q(faces,vertices);
fprintf('(corresponding face indices are in the parentheses) \n')
fprintf(' max = %5.2e (%7i)   min = %5.2e (%7i)   ratio = %5.2e   | area based sizes \n',max_sizeS,imax_sizeS,min_sizeS,imin_sizeS,max_sizeS/min_sizeS); 
fprintf(' max = %5.2e (%7i)   min = %5.2e (%7i)   ratio = %5.2e   | edge lengths \n',max_length,imax_length,min_length,imin_length,max_length/min_length); 
fprintf(' max = %8.4f (%7i)   min = %8.4f (%7i)   ratio = %5.2e   | angles (degrees) \n', max_angle,imax_angle,min_angle,imin_angle,max_angle/min_angle); 
fprintf(' max = %5.2e (%7i)   min = %5.2e (%7i)                      | ratio of circum and in radii \n',max_q,imax_q,min_q,imin_q);

fprintf('\n');
fprintf('overall mesh quality: %5.2e (1 is perfect) \n',meshQ);

[~,~,areas]=getnormalscenters(faces,vertices);
averagearea=sum(areas)/size(faces,1);
averagelength=sqrt(4*averagearea/sqrt(3));

fprintf('\n')
fprintf('area = %5.2e  length = %5.2e   (area based averages) \n', averagearea,averagelength);

fprintf('\n');
disp('checking mesh orientation...')
hedges=getHalfEdges(faces);
fedges=getFullEdges(hedges);
su= fedges(:,4)~=0; iedges=fedges(su,:);
badedges=checkMeshOrientation(faces,iedges);  %determine if any internal edge is oriented inconsistently
if numel(badedges)==0
    disp('mesh is oriented consistently');
else
    disp('mesh is not oriented consistently')
    fprintf('there are %i wrong oriented edges \n',numel(badedges));
end
fprintf('\n');

disp('checking vertex valency...')
[val,minval,maxval,iminval,imaxval]=valency2(fedges);
fprintf('max valency is %i (vertex #%i) min valency is %i (vertex #%i) \n',maxval,imaxval,minval,iminval);