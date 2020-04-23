%Generowanie faktorów
I = [10 20 30]; % liczby elementów w poszczególnych modach
J = 5; % rząd faktoryzacji
U{1} = max(0, rand(I(1), J));
U{2} = max(0, rand(I(2), J));
U{3} = max(0, rand(I(3), J));

%Generowanie syntetycznych obserwacji
%ones(J, 1) - wektor kolumnowy wag (wszystkie takie same i równe 1)
Y=ktensor(ones(J, 1), U);
U_est = CP(Y, 5, J, 10);

function U = CP(Y, P, J, iterations)
   % N - liczba modów
   I = size(Y);
   
   % losowa inicjalizacja faktorów
   for i=1:size(I, 2)
       U{i} = max(0, rand(I(i), J));
   end
   
   N = size(Y.u, 1); % liczba modów
   Y_arr = double(Y); % konwersja tensora na tablicę wielowymiarową
   
   % wyznaczanie faktorów powtórzone iterations razy
   for i = 1:iterations
       
       % przemiatanie po wszystkich (N) modach tensora obserwacji Y
       for n = 1:N
           % Matrycyzacja względem n-tego modu
           Yn = unfold(Y_arr, n);
           
           % Estymacja n-tego faktora za pomocą m. najmniejszych kwadratów
           % Wszystkie faktory poza n-tym
           indexes_without_n = copy_without_element(1:N, n);
           U_without_n = cell(1, N-1);
           U_without_n_array_squared = zeros(N-1, J, J);
           for j = 1:(N-1)
               cell_index = indexes_without_n(j);  
               U_without_n{j} = U{cell_index};
               U_without_n_array_squared(j, :, :) = (U{cell_index})' * U{cell_index};
           end
           % Iloczyn Hadamarda między poszczególnymi Ui'*Ui
           B = fold(@(ui, uj) ui * uj, U_without_n_array_squared);
           
           % Wyznaczenie faktora U{n}
           U{n} = (Yn*U_without_n) / B;
           
           if n ~= N
              % Skalowanie n-tego faktora
              
           end
       end
   end
end

function [C] = hadamard_product(A, B)
    C = (A' * A) .* (B' * B);
end




