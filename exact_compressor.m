function [Sum, Carry, Cout] = exact_compressor(X1, X2, X3, X4, Cin)
% EXACT_COMPRESSOR - Exact 4:2 compressor (two cascaded full adders)
%
% Implements equations (1), (2), (3) from the paper (Section 3).
% Takes 5 inputs and produces 3 outputs: Sum, Carry, Cout.
%
% Inputs:
%   X1, X2, X3, X4 - Four data input bits
%   Cin             - Carry-in from previous compressor in chain
%
% Outputs:
%   Sum   - Sum output bit
%   Carry - Carry output bit (passed to next stage)
%   Cout  - Carry-out (passed to next compressor as Cin)
%
% Boolean expressions:
%   Sum   = X1 XOR X2 XOR X3 XOR X4 XOR Cin
%   Cout  = (X1 XOR X2).X3 + NOT(X1 XOR X2).X1
%   Carry = (X1 XOR X2 XOR X3 XOR X4).Cin + NOT(X1 XOR X2 XOR X3 XOR X4).X4

    % Cast to logical so that ~ gives correct boolean NOT (not bitwise NOT)
    X1 = logical(X1); X2 = logical(X2);
    X3 = logical(X3); X4 = logical(X4);
    Cin = logical(Cin);

    xor12   = xor(X1, X2);
    xor1234 = xor(xor(xor12, X3), X4);

    Sum   = double(xor(xor1234, Cin));
    Cout  = double((xor12 & X3)    | (~xor12   & X1));
    Carry = double((xor1234 & Cin) | (~xor1234 & X4));
end
