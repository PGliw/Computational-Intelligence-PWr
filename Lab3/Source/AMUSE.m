function [ A, S ] = AMUSE( X, N, przes )
    T = size(X,2);
    %Centralizacja
    Xcent = bsxfun(@minus, X, mean(X,2));
    %Korelacja
    Cx = (1/T)* (Xcent * Xcent');
    %EVD
    [V, VAL] = eig(Cx);
    %Wybielanie
    Vbar = V(:, 1:N);
    VALbar = diag(diag(VAL(:,1:N)));
    Z = (VALbar^-(1/2))*Vbar'*Xcent;
    %Autokorelacja
    Z1 = Z(:,1:T-przes);
    Z2 = Z(:, 1+przes:T);
    R = (1/(T-przes))*Z1*Z2';
    %Symetryzacja
    Rbar = (R+R')/2;
    %EVD
    [Vz, VALz] = eig(Rbar);
    %Estymatory
    S = Vz' * Z;
    A = Vbar*(VALbar^(1/2))*Vz;
    
end