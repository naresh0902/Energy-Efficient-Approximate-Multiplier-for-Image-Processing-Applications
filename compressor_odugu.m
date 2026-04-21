function [Sum, Carry] = compressor_odugu(X1, X2, X3, X4)
% COMPRESSOR_ODUGU - Odugu et al. (Reference [9])
% "An efficient VLSI architecture of 2-D FIR filter using
%  enhanced approximate compressor circuits"
% Int. J. Circuit Theory and Applications, 2021.
%
% Uses mixed logic to reduce transistor count.
% Error rate: 94.54%

    Sum   = xor(xor(X1, X2), X3);
    Carry = X4;
end
