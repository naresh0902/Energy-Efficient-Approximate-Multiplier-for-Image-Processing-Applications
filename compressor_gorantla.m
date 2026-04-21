function [Sum, Carry] = compressor_gorantla(X1, X2, X3, X4)
% COMPRESSOR_GORANTLA - Gorantla et al. (Reference [11])
% "Design of Approximate Compressors for Multiplication"
% ACM Journal on Emerging Technologies in Computing Systems, 2017.
%
% Uses 4:2 and 5:2 imprecise compressors in Dadda multiplier.
% Error rate: 86.832%

    xor12 = xor(X1, X2);
    Sum   = xor(xor12, X3);
    Carry = (xor12 & X4) | (~xor12 & X2);
end
