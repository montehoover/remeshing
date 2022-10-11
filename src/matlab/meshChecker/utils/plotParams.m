function [] = plotParams(u, v, theta, phi, save, save_path)
    if nargin < 5
        save = true;
    end
    if nargin < 6
        save_path = pwd();
    end
    
    % Plot u, v, theta, phi
    f1 = figure; 
    plot(u, v, 'ro');
    xlabel('u', 'FontSize', 18); ylabel('v', 'FontSize', 18);
    title("Base Parameters", 'FontSize', 18);
    
    f2 = figure;
    plot(sort(u), 'bo'); hold on;
    plot(sort(theta), 'rs');
    xlabel('i', 'FontSize', 18);
    ylabel('p(i)', 'FontSize', 18);
    title("\theta vs. u", 'FontSize', 18);
    legend('u', '\theta', 'FontSize', 12); 
    
    f3 = figure;
    plot(theta, phi, 'ro');
    xlabel('\theta', 'FontSize', 18); ylabel('\phi', 'FontSize', 18);
    title("Processed Parameters", 'FontSize', 18);
    
    if save
        saveas(f1, save_path + "/uv", "png");
        saveas(f2, save_path + "/theta_u", "png");
        saveas(f3, save_path + "/thetaphi", "png");
    end
end
