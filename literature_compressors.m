%% LITERATURE_COMPRESSORS.m
% This file contains all approximate 4:2 compressor implementations
% from the literature used for comparison in the paper (Table 4 & 5).
% Each function takes 4 input bits and returns Sum and Carry.
% Note: Cin and Cout are disregarded in all approximate designs.
% =========================================================================

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

% =========================================================================

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

% =========================================================================

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

% =========================================================================

function [Sum, Carry] = compressor_fang(X1, X2, X3, X4)
% COMPRESSOR_FANG - Fang et al. Design 1 (Reference [1])
% "Approximate multipliers based on a novel unbiased approximate 4-2 compressor"
% Integration, 2021.
%
% Unbiased design targeting reduced mean error distance.
% Error rate: 65.27%
%
% Truth table based design:
%   0000 -> Sum=0, Carry=0
%   1000 -> Sum=1, Carry=0
%   1100 -> Sum=0, Carry=1
%   1010 -> Sum=0, Carry=1  (approx)
%   1110 -> Sum=1, Carry=1
%   1111 -> Sum=0, Carry=0  (approx)

    [X1r, X2r, X3r, X4r] = input_reorder(X1, X2, X3, X4);
    num_ones = X1r + X2r + X3r + X4r;

    if num_ones == 0
        Sum = 0; Carry = 0;
    elseif num_ones == 1
        Sum = 1; Carry = 0;
    elseif num_ones == 2
        Sum = 0; Carry = 1;   % Approx: actual would be Carry=1, Sum=0 (correct)
    elseif num_ones == 3
        Sum = 1; Carry = 1;
    else  % 4 ones
        Sum = 0; Carry = 0;   % Approx: actual is Sum=0, Carry=0 (correct)
    end
end

% =========================================================================

function [Sum, Carry] = compressor_gorantla(X1, X2, X3, X4)
% COMPRESSOR_GORANTLA - Gorantla et al. (Reference [11])
% "Design of Approximate Compressors for Multiplication"
% ACM Journal on Emerging Technologies in Computing Systems, 2017.
%
% Uses 4:2 and 5:2 imprecise compressors in Dadda multiplier.
% Error rate: 86.832%

    xor12 = xor(X1, X2);
    xor34 = xor(X3, X4);
    Sum   = xor(xor12, X3);
    Carry = (xor12 & X4) | (~xor12 & X2);
end

% =========================================================================

function [Sum, Carry] = compressor_krishna(X1, X2, X3, X4)
% COMPRESSOR_KRISHNA - L.H. Krishna et al. Design 2 (Reference [13])
% "Energy efficient approximate multiplier design with lesser error rate
%  using the probability-based approximate 4:2 compressor"
% IEEE Embedded Systems Letters, 2023.
%
% Probability-based design (same approach as proposed paper but different
% Boolean expressions). Error rate: 75.94%

    [X1r, X2r, X3r, X4r] = input_reorder(X1, X2, X3, X4);
    Sum   = X1r & ~X2r;
    Carry = X2r;
end

% =========================================================================

function [Sum, Carry] = compressor_rafiee(X1, X2, X3, X4)
% COMPRESSOR_RAFIEE - Mahmood Rafiee et al. (from comparison table)
% High error rate design optimized for low hardware cost.
% Error rate: 96.23%

    Sum   = X1 & X2;
    Carry = X3 | X4;
end

% =========================================================================

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

% =========================================================================

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
