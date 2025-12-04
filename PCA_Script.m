%% PCA on Flight Performance Data
% This script performs PCA on a 10x5 dataset representing test flight 
% metrics.
clc, clear, close all

% Flight Test Dataset
load flight_test_data.mat

%% PART A: Labeled Raw Data Plot (Pairwise)
figure;
[H,AX,BigAx] = plotmatrix(X);

% Label each small axis with variable names
for i = 1:length(varNames)
    AX(i,1).YLabel.String = varNames(i);
    AX(end,i).XLabel.String = varNames(i);
end

title(BigAx, 'Raw UAV Flight Data (Pairwise Variable Relationships)');

%% PART B: PCA Using SVD
Xc = X - mean(X,1);   % center data
[U,S,V] = svd(Xc,'econ');
Y = U*S;              % PCA scores

% Interpret PC loadings
PC1 = V(:,1);
PC2 = V(:,2);

disp('PC1 Loadings (Aerodynamic Loading Axis):');
disp(PC1);
disp('PC2 Loadings (Stability Error Axis):');
disp(PC2);

%% PART C: PCA Plot With Trend Line 
figure;
scatter(Y(:,1), Y(:,2), 80, 'filled'); hold on;
text(Y(:,1)+0.35, Y(:,2), string(1:10));

%  Least squares fit 
p_raw = polyfit(Y(:,1), Y(:,2), 1);
y_pred_raw = polyval(p_raw, Y(:,1));

% Compute residuals and identify outliers
res = Y(:,2) - y_pred_raw;
MAD = median(abs(res - median(res)));

% Define outlier threshold at 3 standard deviations
thresh = 3 * MAD;
inliers = abs(res - median(res)) < thresh;

% Refit trend line using inliers
x_in = Y(inliers,1);
y_in = Y(inliers,2);

p_final = polyfit(x_in, y_in, 1); 
xline = linspace(min(Y(:,1)), max(Y(:,1)), 200);
yline = polyval(p_final, xline);

% Final trend line plot
plot(xline, yline, 'r-', 'LineWidth', 2);

xlabel('PC1: Aerodynamic Loading / Propulsion Demand');
ylabel('PC2: Stability and Yaw Control Error');
title('Flight Data in PCA Space');
grid on;

% Mark removed outliers
outliers = ~inliers;
plot(Y(outliers,1), Y(outliers,2), 'ko', 'MarkerSize', 10, 'LineWidth', ...
    1.5, 'Color', 'Yellow');

legend('Flight Data','Trend Line (No Outliers)','Outliers','Location', ...
    'best');
