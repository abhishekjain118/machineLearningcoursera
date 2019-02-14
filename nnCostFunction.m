function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));


% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
y_pred = zeros(size(X, 1), num_labels); %5000x10
X = [ones(m, 1) X];
y = eye(num_labels)(y, :); % 5000x10 
z2 = zeros(size(X, 1), hidden_layer_size); % m x hidden_layer_size
a2 = ones(size(X, 1), hidden_layer_size+1); % m x hidden_layer_size+1
z3 = ones(size(X, 1), num_labels); % m x num_labels
for i = 1:m,
  z2(i,:) = X(i,:)*Theta1'; %(1x401*401x25)
  a2(i,:) = [a2(i,1) sigmoid(z2(i,:))]; %(1x26)
  %a2 = [1 a2]; %(1x26)
  
  z3(i,:) = a2(i,:)*Theta2'; %(1x26*26x10)
  y_pred(i,:) = sigmoid(z3(i,:)); %(1x10)
    
  J = J + (-1/m)*(y(i,:)*log(y_pred(i,:)') + (1-y)(i,:)*log(1-y_pred(i,:)'));
endfor

% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%

Theta1_1 = Theta1(:,2:end);
Theta2_1 = Theta2(:,2:end);

regularized_cost = 0;
for j = 1:hidden_layer_size,
  for k = 1:input_layer_size,
    regularized_cost = regularized_cost + Theta1_1(j,k)^2;
  endfor
endfor
for j = 1:num_labels,
  for k = 1:hidden_layer_size,
    regularized_cost = regularized_cost + Theta2_1(j,k)^2;
  endfor
endfor

%lambda/(2*m);
J = J + lambda*regularized_cost/(2*m);

% step 2 of backpropagation
d3 = y_pred - y; % m x num_labels
% step 3 of backpropagation
% step 4 of backpropagation
d2 = d3*Theta2_1; % (m x num_labels) * (num_labels x hidden_layer_size)  
d2 = d2.*sigmoidGradient(z2); % element wise multiplication
% step 5 of backpropagation
Delta1 = d2'*X; %(hidden_layer_size x m) * (m x n i.e. 5000x401)
% step 6 of backpropagation
Delta2 = d3'*a2; %(num_labels x m) * (m x hidden_layer_size+1)  

Theta1_grad = (1/m).*Delta1; %(25 x 401)
Theta2_grad = (1/m).*Delta2; %(10 x 26)


% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%
Theta1(:, 1) = 0; %(25 x 401)
Theta2(:, 1) = 0; %(10 x 26)

Theta1 = Theta1.*(lambda/m);
Theta2 = Theta2.*(lambda/m);
Theta1_grad = Theta1_grad + Theta1 ;
Theta2_grad = Theta2_grad + Theta2 ;
% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
