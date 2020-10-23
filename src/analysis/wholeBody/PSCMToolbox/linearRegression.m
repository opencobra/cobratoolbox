function [a0,a1,Rsqr,Residuals] = linearRegression(x,y)
% This function calculates the linear regression in the form of y = a0 + a1*x
% 
% function [a0,a1,Rsqr,Residuals] = linearRegression(x,y)
%
% INPUT
% x             Values for the explanatory variable x in y = a0 + a1*x
% y             Values for the dependent variable y in y = a0 + a1*x
%
% OUTPUT
% a0            Intercept
% a1            Slope of the line
% Rsqr          Square of the correlation coefficient
% Residuals     Regression residuals, provides an objective measure of the
%               goodness of fit of the linear regression equation
% 
% Ines Thiele 2018


% 
x = [ones(length(x),1) x];
b = x\y;
yCalc2 = x*b;
% R2
Rsqr = 1 - sum((y - yCalc2).^2)/sum((y - mean(y)).^2);
a0 = b(1);
a1 = b(2);
Residuals = (y - yCalc2);