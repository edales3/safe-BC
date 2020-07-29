function g = elu(z)
%ELU Compute Exponential Linear Unit function

g = zeros(size(z));

for i =1:length(z)
    if z(i)<0
        g(i) = 1.0*(exp(z(i)) - 1);
    else 
        g(i) = z(i);
    end
end



% =============================================================

end
