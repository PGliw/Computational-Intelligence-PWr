function [ A, S ] = AMUSE( X )
    M = 3;
    T = size(X,2);
    disp(T);
    Xcent = X - (T^-1*X*eye(1));
%     TODO find out what h means
    Cx = (1/T)*Xcent*3; 
    Cx = eig(Cx);
    disp(Cx);
    
end