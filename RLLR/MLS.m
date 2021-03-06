% function [Ai,bi] = RMLS( theta, W, Xu, Xl, Yl, lamda)
function flag = MLS( theta,  Xu, Xl, Yl, lamda, Ai,bi)
%RMLS Summary of this function goes here
%   Detailed explanation goes here

[dim, num_l] = size(Xl);
[dim, num_u] = size(Xu);

% compute y_bar, x_bar
S_x = Xl * theta'; 
S_y = Yl * theta';
S_theta = sum( theta );

x_bar =(1/S_theta) * S_x; 
y_bar = (1/S_theta) * S_y;

A_x = zeros(dim, dim);
A_y = zeros(1,1);
for j = 1: num_l
    X_diff =  Xl(:, j) - x_bar;
    Y_diff =  Yl(:, j) - y_bar;
    A_x = A_x + theta(1, j) * X_diff * X_diff';
    A_y = A_y + theta(1, j) * Y_diff * X_diff';
end
sigma = inv ( A_x );
if (isinf(sigma))
    flag = 0;   
end
if (isfinite(sigma))
Ai = A_y * sigma; 
bi = y_bar - Ai * x_bar;
flag = 1;
end

end
