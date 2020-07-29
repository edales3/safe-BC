from tensorflow import keras
from tensorflow.keras import layers
import pandas as pd
from scipy.io import savemat
import tensorflow as tf
import matplotlib.pyplot as plt
from sklearn.utils import shuffle

# LOADING DATA
data = pd.read_csv("data.csv")
#data.Local_X = data.Local_X - data.yielding_pos_X
#data.Local_Y = data.Local_Y - data.yielding_pos_Y
#data.step_x = -data.step_x

# Eliminate outliers
data = data.loc[data.step_y < 12]
data = data.loc[data.step_x < 0.09]

# extract data and divide between training and test datasets
data = shuffle(data)
#x = data.loc[:,['Local_X','Local_Y','v_Vel','v_Acc','yielding_pos_X','yielding_pos_Y','yielding_vel','yielding_acc',
#                'front_pos_X','front_pos_Y','front_vel','front_acc','front_gap']]
x = data.loc[:,['Local_X','Local_Y','v_Vel','v_Acc','yielding_pos_X','yielding_pos_Y','yielding_acc', 'front_pos_X', 'front_pos_Y','front_gap']]
y = data.iloc[:,-2:]
x_train = x.iloc[int(len(x)*0.2):]
y_train = y[:][int(len(y)*0.2):]
x_test = x[:][:int(len(x)*0.2):]
y_test = y[:][:int(len(y)*0.2):]

# Define the model
model = keras.Sequential([
    layers.Dense(64, activation='elu', input_shape=(10,)),
    layers.Dense(64, activation='elu'),
    layers.Dense(64, activation='elu'),
    layers.Dense(64, activation='elu'),
    layers.Dense(2)
  ])

optimizer = tf.keras.optimizers.Adam(learning_rate=0.001)

# Compile the model
model.compile(loss='mse',
              optimizer=optimizer,
              metrics=['mae', 'mse'])

# Train the model
history = model.fit(
  x_train, y_train,
  epochs=85, validation_split=0.2, verbose=0)

#plotter = tfdocs.plots.HistoryPlotter(smoothing_std=2)
#plotter.plot({'Basic': history}, metric = "mae")
#plt.ylim([0, 10])
#plt.ylabel('MAE [MPG]')
#plt.show()

# Evaluation of weights performance
loss, mae, mse = model.evaluate(x_test, y_test, verbose=2)
print("Testing set Mean Abs Error: {:5.2f} MPG".format(mae))
test_predictions = model.predict(x_test)
plt.plot(history.history['loss'], label='loss')
plt.plot(history.history['mae'], label='mae')
plt.plot(history.history['mse'], label='mse')
#plt.plot(history.history['val_mae'], label='val_mae')
#plt.plot(history.history['val_mse'], label='val_mse')
plt.legend()
plt.show()
a = plt.axes(aspect='equal')
plt.scatter(y_test, test_predictions)
plt.xlabel('True Values [MPG]')
plt.ylabel('Predictions [MPG]')
plt.show()
print(test_predictions)
print(y_test)

# Save final weights
mdic1 = {'W1': model.layers[0].get_weights()[0]}
mdic2 = {'W2': model.layers[1].get_weights()[0]}
mdic3 = {'W3': model.layers[2].get_weights()[0]}
dic1 = {'b1': model.layers[0].get_weights()[1]}
dic2 = {'b2': model.layers[1].get_weights()[1]}
dic3 = {'b3': model.layers[2].get_weights()[1]}
savemat('W1.mat', mdic1)
savemat('W2.mat', mdic2)
savemat('W3.mat', mdic3)
savemat('b1.mat', dic1)
savemat('b2.mat', dic2)
savemat('b3.mat', dic3)
mdic4 = {'W4': model.layers[3].get_weights()[0]}
mdic5 = {'W5': model.layers[4].get_weights()[0]}
dic4 = {'b4': model.layers[3].get_weights()[1]}
dic5 = {'b5': model.layers[4].get_weights()[1]}
savemat('W4.mat', mdic4)
savemat('W5.mat', mdic5)
savemat('b4.mat', dic4)
savemat('b5.mat', dic5)


