%Generowanie faktorów
I = [10 20 30]; % liczby elementów w poszczególnych modach
J = 5; % rząd faktoryzacji
U{1} = max(0, rand(I(1), J));
U{2} = max(0, rand(I(2), J));
U{3} = max(0, rand(I(3), J));

%Generowanie syntetycznych obserwacji
%ones(J, 1) - wektor kolumnowy wag (wszystkie takie same i równe 1)
Y=ktensor(ones(J, 1), U);

function U_est = CP(Y, P, J, iterations)
   % N - liczba modów
   I = size(Y)
   
   % losowa inicjalizacja faktorów
   U{1} = max(0, rand(I(1), J));
   U{2} = max(0, rand(I(2), J));
   U{3} = max(0, rand(I(3), J));
   
   % przemiatanie po wszystkich (N) modach tensora obserwacji Y
   N = size(Y.u, 1); % liczba modów
   Y_arr = double(Y); % konwersja tensora na tablicę wielowymiarową
   for i = 1:iterations
       for n = 1:N
           % Matrycyzacja względem n-tego modu
           Yn = unfold(Y_arr, n);
           
           % Estymacja n-tego faktora za pomocą m. najmniejszych kwadratów
           % Macież iloczynów Khatri-Rao pomiędzy faktorami (poza n-tym) 
           
           % TODO: U_kr_n = fold(@kr, [U{n}, n]);
           % TODO: U{n} = argmin(n) 0.5||Y-
           
           % TODO: Skalowanie n-tego faktora
       end
   end
end

