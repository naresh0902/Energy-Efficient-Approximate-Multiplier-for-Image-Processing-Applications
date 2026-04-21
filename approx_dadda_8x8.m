function result = approx_dadda_8x8(A, B, compressor_type)
% APPROX_DADDA_8X8 - 8x8 Approximate Dadda Multiplier
%
% Implements the 8x8 Dadda multiplier from Fig. 5 of the paper.
% Architecture:
%   - Columns 1-8  (LSBs, rightmost): Approximate compressor
%   - Columns 9-16 (MSBs, leftmost) : Exact 4:2 compressor
%   - Dadda reduction sequence: 8->6->4->3->2 rows
%   - Stage 3 final addition: ripple carry adder
%
% Inputs:
%   A              - 8-bit integer (0-255)
%   B              - 8-bit integer (0-255)
%   compressor_type- 'proposed1','proposed2','momeni','ha_lee','odugu',
%                    'fang','gorantla','krishna','rafiee','edavoor',
%                    'reddy','exact'
% Output:
%   result - integer product (approximate or exact)

    A = double(uint8(A));
    B = double(int8(B));

    % -----------------------------------------------------------
    % Step 1: Build partial product columns
    % Column c (1-indexed, 1=LSB) holds bits of weight 2^(c-1).
    % 8x8 partial products span columns 1..15 (weights 2^0..2^14).
    % We use 16 columns (extra for carries).
    % Each column is stored as a cell array of bits.
    % -----------------------------------------------------------
    NUM_COLS = 16;
    cols = cell(1, NUM_COLS);
    for c = 1:NUM_COLS
        cols{c} = [];
    end

    for i = 1:8
        for j = 1:8
            bit = bitget(uint8(A), i) & bitget(uint8(B), j);
            col_idx = i + j - 1;          % weight column (1=LSB)
            cols{col_idx}(end+1) = bit;
        end
    end

    % -----------------------------------------------------------
    % Step 2: Dadda reduction
    % Target heights sequence: 6, 4, 3, 2
    % -----------------------------------------------------------
    for target = [6, 4, 3, 2]
        cols = reduce_columns(cols, target, compressor_type, NUM_COLS);
    end

    % -----------------------------------------------------------
    % Step 3: Final ripple-carry addition of the 2 remaining rows
    % -----------------------------------------------------------
    result = 0;
    for c = 1:NUM_COLS
        bits = cols{c};
        for k = 1:length(bits)
            if bits(k)
                result = result + 2^(c-1);
            end
        end
    end
end


% ===========================================================
function cols = reduce_columns(cols, target, compressor_type, NUM_COLS)
% REDUCE_COLUMNS
% For each column left-to-right, reduce bit count to <= target
% by applying half adders, full adders, and 4:2 compressors.
% Carries propagate to the next (higher-weight) column.

    for c = 1:NUM_COLS
        while length(cols{c}) > target
            n = length(cols{c});

            if n >= 4
                % Pick 4 bits from this column
                b1 = cols{c}(1); b2 = cols{c}(2);
                b3 = cols{c}(3); b4 = cols{c}(4);
                cols{c}(1:4) = [];          % consume 4 bits

                use_approx = (c <= 8) && ~strcmpi(compressor_type, 'exact');

                if use_approx
                    % Approximate 4:2: 4 bits -> Sum (stays) + Carry (goes up)
                    [s, carry] = apply_compressor(b1, b2, b3, b4, compressor_type);
                    cols{c}(end+1) = s;
                    if c < NUM_COLS
                        cols{c+1}(end+1) = carry;
                    end
                else
                    % For exact mode everywhere (and MSB cols): use two cascaded
                    % full adders which correctly reduces 4 bits to 2 with
                    % no ambiguous Cin chaining.
                    % FA1: (b1, b2, b3) -> s1, c1
                    s1 = double(xor(xor(logical(b1),logical(b2)),logical(b3)));
                    c1 = double((logical(b1)&logical(b2)) | ...
                                (logical(b1)&logical(b3)) | ...
                                (logical(b2)&logical(b3)));
                    % FA2: (s1, b4, 0) -> s2, c2  [treats c1 as carry-out]
                    s2 = double(xor(logical(s1), logical(b4)));
                    c2 = double(logical(s1) & logical(b4));
                    % s2 stays in this column; c1 and c2 both go to col+1
                    cols{c}(end+1) = s2;
                    if c < NUM_COLS
                        cols{c+1}(end+1) = c1;
                        cols{c+1}(end+1) = c2;
                    end
                end

            elseif n == 3
                % Full adder: 3 bits -> sum (stays) + carry (goes up)
                b1 = cols{c}(1); b2 = cols{c}(2); b3 = cols{c}(3);
                cols{c}(1:3) = [];
                s = xor(xor(logical(b1), logical(b2)), logical(b3));
                carry = (logical(b1)&logical(b2)) | ...
                        (logical(b1)&logical(b3)) | ...
                        (logical(b2)&logical(b3));
                cols{c}(end+1)   = double(s);
                if c < NUM_COLS
                    cols{c+1}(end+1) = double(carry);
                end

            elseif n == 2
                % Half adder: 2 bits -> sum (stays) + carry (goes up)
                b1 = cols{c}(1); b2 = cols{c}(2);
                cols{c}(1:2) = [];
                s     = xor(logical(b1), logical(b2));
                carry = logical(b1) & logical(b2);
                cols{c}(end+1)   = double(s);
                if c < NUM_COLS
                    cols{c+1}(end+1) = double(carry);
                end

            else
                break;  % 0 or 1 bit — nothing to reduce
            end
        end
    end
end


% ===========================================================
function [Sum, Carry] = apply_compressor(X1, X2, X3, X4, compressor_type)
% APPLY_COMPRESSOR - Routes to the correct compressor function

    switch lower(compressor_type)
        case 'proposed1'
            [Sum, Carry] = compressor_proposed1(X1, X2, X3, X4);
        case 'proposed2'
            [Sum, Carry] = compressor_proposed2(X1, X2, X3, X4);
        case 'momeni'
            [Sum, Carry] = compressor_momeni(X1, X2, X3, X4);
        case 'ha_lee'
            [Sum, Carry] = compressor_ha_lee(X1, X2, X3, X4);
        case 'odugu'
            [Sum, Carry] = compressor_odugu(X1, X2, X3, X4);
        case 'fang'
            [Sum, Carry] = compressor_fang(X1, X2, X3, X4);
        case 'gorantla'
            [Sum, Carry] = compressor_gorantla(X1, X2, X3, X4);
        case 'krishna'
            [Sum, Carry] = compressor_krishna(X1, X2, X3, X4);
        case 'rafiee'
            [Sum, Carry] = compressor_rafiee(X1, X2, X3, X4);
        case 'edavoor'
            [Sum, Carry] = compressor_edavoor(X1, X2, X3, X4);
        case 'reddy'
            [Sum, Carry] = compressor_reddy(X1, X2, X3, X4);
        case 'exact'
            [Sum, Carry, ~] = exact_compressor(X1, X2, X3, X4, 0);
        otherwise
            error('Unknown compressor type: %s', compressor_type);
    end
end
