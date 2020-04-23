function Y_unfolded = unfold(Y, mode)
    % Przeprowadza matrycyzację tensora Y względem modu mode
    % Y - tensor 3-modalny do poddania matrycyzacji
    % mode - mod, względem którego ma być przeprowadzona matrycyzacja 
    switch mode
        case 1
            permutation = [1 2 3];
        case 2
            permutation = [2 1 3];
        case 3
            permutation = [3 1 2];
        otherwise
            err("Mode number exeeded maximum allowed value (3)");
    end
    Y_permuted = permute(Y, permutation);
    dim1 = size(Y, permutation(1));
    dim2 = size(Y, permutation(2)) * size(Y, permutation(3));
    Y_unfolded = reshape(Y_permuted, [dim1 dim2]);
end