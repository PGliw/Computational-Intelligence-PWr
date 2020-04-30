function Y_3D = fold3_3(Y_2D, I)
    %FOLD3 Cofa operacje matrycyzacji tensora 3-modalnego względem 3-modu
    % param Y_2D - macierz 2-wymiarowa będąca wynikiem matrycyzacji pewnego
    % tensora 3-modalnego względem 3-modu
    % param I - 3-elementowy wektor wymiarów tensora wynikowego   
    % Y_3D - odtworzony tensor (tablica 3D) sprzed matrycyzacji
    Y_3D = zeros(I);
    for i=1:I(3)
        Y_3D(:, :, i) = reshape(Y_2D(i, :), [I(1),  I(2)]);
    end
end

