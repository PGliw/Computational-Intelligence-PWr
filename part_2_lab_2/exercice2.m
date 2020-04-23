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
           
           % Iloczyn Hadamana faktorów poza n-tym
           indexes_without_n = copy_without_element(1:N, n);
           B = ones(J, J);
           for j = indexes_without_n
              B = B .* (U{j}' * U{j});
           end
           
           % Iloczyn Khatri-Rao faktorów poza n-tym
           kr_indexes = flip(indexes_without_n);
           for j = 1:size(kr_indexes, 2)-1               
               current_index = kr_indexes(j);
               next_index = kr_indexes(j+1);
               U_kr = kr(U{current_index}, U{next_index});
           end
           
           % Estymacja U{n}
           U{n} = (Yn * U_kr) / B; 
           
           % Skalowanie n-tego faktora
           if n ~= N
               
           end
       end
   end
end

function [C] = hadamard_product(A, B)
    C = (A' * A) .* (B' * B);
end




