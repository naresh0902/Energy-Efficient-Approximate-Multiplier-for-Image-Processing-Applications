function [Sum, Carry] = compressor_edavoor(X1, X2, X3, X4)
% COMPRESSOR_EDAVOOR - P.J. Edavoor et al. (Reference [3])
% "Approximate Multiplier Design Using Novel Dual-Stage 4:2 Compressors"
% IEEE Access, 2020.
%
% Dual-stage design for balanced accuracy/hardware tradeoff.
% Error rate: 88.03%

    xor12 = xor(X1, X2);
    Sum   = xor(xor12, X4);
    Carry = (X1 & X2) | (xor12 & X3);
end
