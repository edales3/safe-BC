function inc = get_disp(ego,back,front)


% Load data in meaningful variables
x_back = back(5);
y_back = back(6);
x_front = front(5);
y_front = front(6);
x_ego = ego(5);
y_ego = ego(6);
len_front = front(9);
len_ego = ego(9);
w_back = back(10);
w_front = front(10);
w_ego = ego(10);
v_back = back(12);
v_front = front(12);
load W1.mat
load W2.mat
load W3.mat
load W4.mat
load W5.mat
load b1.mat
load b2.mat
load b3.mat
load b4.mat
load b5.mat

% Adjust position with car's geometry
x_ego = x_ego - w_ego/2;
x_back = x_back + w_back/2;
x_front = x_front + w_front/2;
y_front = y_front - len_front;

% Calculate relevant distances from back and front cars
d_front = sqrt((x_front - x_ego)^2 + (y_front - y_ego)^2);
d_front_f = sqrt((x_ego + w_ego/2 - x_front + w_front/2)^2 + (y_front - y_ego)^2);
d_back = sqrt((x_back - x_ego)^2 + (y_ego - y_back - len_ego)^2);
d_back_f = sqrt((x_back - x_ego)^2 + (y_ego - y_back - len_ego/2)^2);

% Construct NN input
x = [ego([5,6,12,13]), back([5,6,13]), front(5), front(6)-len_front , front(6)-back(6)-len_front];

% Get NN output
inc = elu(elu(elu(elu(x*W1+b1)*W2+b2)*W3+b3)*W4+b4)*W5+b5;

return

%Comment the return for activating the safety filter
% Calculate control action for safe merging
%inc = safety_filter(inc,ego,front,back,min(d_front,d_front_f),min(d_back,d_back_f));

end