function [Sum, Carry] = compressor_momeni(X1, X2, X3, X4)
% COMPRESSOR_MOMENI - Momeni et al. Design 2 (Reference [10])
% "Design and Analysis of Approximate Compressors for Multiplication"
% IEEE Transactions on Computers, 2014.
%
% Highly aggressive approximation - very high error rate (99.226%).
% Sum = X1 XOR X2, Carry = X3 AND X4

    Sum   = xor(X1, X2);
    Carry = X3 & X4;
end
