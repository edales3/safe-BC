function g = sigmoid(z)
%SIGMOID Compute sigmoid function
%   g = SIGMOID(z) computes the sigmoid of z.

% You need to return the following variables correctly 
g = zeros(size(z));

% ====================== YOUR CODE HERE ======================
% Instructions: Compute the sigmoid of each value of z (z can be a matrix,
%               vector or scalar).

%g = ones(size(z)) ./ (1 + exp(-z));
for i =1:length(z)
    if z(i)<0
        g(i) = 1.0*(exp(z(i)) - 1);
    else 
        g(i) = z(i);
    end
end



% =============================================================

end
