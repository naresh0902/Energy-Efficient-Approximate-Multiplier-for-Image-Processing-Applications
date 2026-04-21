function [Sum, Carry] = compressor_rafiee(X1, X2, X3, X4)
% COMPRESSOR_RAFIEE - Mahmood Rafiee et al.
% High error rate design optimized for low hardware cost.
% Error rate: 96.23%

    Sum   = X1 & X2;
    Carry = X3 | X4;
end
