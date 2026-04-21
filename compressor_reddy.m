function [Sum, Carry] = compressor_reddy(X1, X2, X3, X4)
% COMPRESSOR_REDDY - K. Manikantta Reddy et al. (Reference [5])
% "Design and Analysis of Multiplier using Approximate 4-2 Compressor"
% AEU - International Journal of Electronics and Communications, 2019.
%
% Error rate: 69.97%

    xor12 = xor(X1, X2);
    Sum   = xor12 & ~X3;
    Carry = (X1 & X2) | X3;
end
