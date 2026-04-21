function [Sum, Carry] = compressor_ha_lee(X1, X2, X3, X4)
% COMPRESSOR_HA_LEE - Ha and Lee et al. (Reference [12])
% "Multipliers with Approximate 4-2 Compressors and Error Recovery Modules"
% IEEE Embedded Systems Letters, 2017.
%
% Includes partial error recovery logic.
% Error rate: 82.91%

    xor12 = xor(X1, X2);
    Sum   = xor(xor12, X3);
    Carry = (X1 & X2) | (xor12 & X3);
    % Cin ignored, Cout not used
end
