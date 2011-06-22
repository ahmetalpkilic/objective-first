function [A, b, reinsert] = em_physics1(field_or_struct, omega, template, init_val)


    %
    % Helper functions for building matrices.
    %

global S_ DIMS_ D_
N = prod(DIMS_); 

% Define the curl operators as applied to E and H, respectively.
Ecurl = [   -(S_(0,1)-S_(0,0)),  (S_(1,0)-S_(0,0))];  
Hcurl = [   (S_(0,0)-S_(0,-1)); -(S_(0,0)-S_(-1,0))]; 

A_spread = 0.5 * [S_(0,0)+S_(1,0); S_(0,0)+S_(0,1)];

switch field_or_struct
    case 'field'
        A0 = @(p) [Ecurl, -i*omega*speye(N); i*omega*D_(A_spread*p), Hcurl];
        b0 = @(p) 0;
        M = 3*N;
    case 'struct'
        A0 = @(x) i * omega * D_(x(1:2*N)) * A_spread; 
        b0 = @(x) -Hcurl * x(2*N+1:3*N);
        M = N;
end

ind = find(template(:) > 0);
n = length(ind);
S = sparse(ind, 1:n, ones(n,1), M, n);

A = @(v) A0(v) * S;
b = @(v) b0(v) - A0(v) * init_val;
reinsert = @(v) S * v + init_val;
