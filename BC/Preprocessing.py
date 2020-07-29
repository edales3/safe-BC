import numpy as np
import pandas as pd
from scipy.io import loadmat

def yield_ID(row,merging,data_x):
    """
    :param row: row with data of merging car
    :param merging: list of all merging cars
    :param data_x: dataset with info about all cars
    :return: row with data of merging car augmented with info about back and front car
    """
    if ((row['Vehicle_ID'] in (merging)) and (row['Local_X'] > 57.15) and (row['Local_Y'] > 200) and (row['Local_Y'] < 1400)):

        # select merging cars in the area of interest and identify back and front car
        # to augment features of merging car with info about front and back one
        v_yield = data_x.loc[(data_x.Frame_ID == row.Frame_ID) & (data_x.Local_Y < row.Local_Y) & (data_x.Local_X < 59) & (data_x.Local_X > 50) & (data_x.Vehicle_ID != row.Vehicle_ID)]
        v_front = data_x.loc[(data_x.Frame_ID == row.Frame_ID) & (data_x.Local_Y > row.Local_Y) & (data_x.Local_X < 59) & (data_x.Local_X > 50) & (data_x.Vehicle_ID != row.Vehicle_ID)]

        # generate artificial data about back and front car to cover cases at the beginning and end of recordings
        if v_yield.empty:
            back = row-row
            back.Local_X = 55
            back.Local_Y = 200
            back.v_Vel = 40
            back.v_Acc = 0
        else:
            back = v_yield.loc[v_yield.Local_Y.idxmax()]

        if v_front.empty:
            front = row-row
            front.Local_X = 55
            front.Local_Y = 1400
            front.v_Vel = 40
            front.v_Acc = 0
            front.v_Length = 17
        else:
            front = v_front.loc[v_front.Local_Y.idxmin()]

        row['yielding_pos_X'] = back.Local_X
        row['yielding_pos_Y'] = back.Local_Y
        row['yielding_vel'] = back.v_Vel
        row['yielding_acc'] = back.v_Acc
        row['front_pos_X'] = front['Local_X']
        row['front_pos_Y'] = front['Local_Y'] - front['v_Length']
        row['front_vel'] = front['v_Vel']
        row['front_acc'] = front['v_Acc']
        row['front_gap'] = front['Local_Y'] - back['Local_Y'] - front['v_Length']

    return row

# LOADING DATA
data1 = pd.read_csv("trajectories-0750am-0805am.csv")
data2 = pd.read_csv("trajectories-0805am-0820am.csv")
data3 = pd.read_csv("trajectories-0820am-0835am.csv")
d1 = len(data1)
d2 = len(data2)
d3 = len(data3)
merging1 = loadmat("merging_0750.mat")
merging2 = loadmat("merging_0805.mat")
merging3 = loadmat("merging_0820.mat")
data = pd.concat([data1, data2, data3])
merging = np.concatenate((merging1['merging'], merging2['merging'], merging3['merging']),axis=1)
print(data.head())


# PRE-PROCESSING DATA: ADDING NEW FEATURES
data['yielding_pos_X'] = 0
data['yielding_pos_Y'] = 0
data['yielding_vel'] = 0
data['yielding_acc'] = 0
data['front_pos_X'] = 0
data['front_pos_Y'] = 0
data['front_vel'] = 0
data['front_acc'] = 0
data['front_gap'] = 0
df1 = data.iloc[0:d1, :].apply(yield_ID, args=(merging1['merging'],data1), axis='columns')
df2 = data.iloc[d1:d1+d2, :].apply(yield_ID, args=(merging2['merging'],data2), axis='columns')
df3 = data.iloc[d1+d2:d1+d2+d3, :].apply(yield_ID, args=(merging3['merging'],data3), axis='columns')
# keep only the merging cars
df1_merg = df1.loc[df1.front_gap != 0, :]
df2_merg = df2.loc[df2.front_gap != 0, :]
df3_merg = df3.loc[df3.front_gap != 0, :]
df1_merg.to_csv('df1.csv')
df2_merg.to_csv('df2.csv')
df3_merg.to_csv('df3.csv')


# GENERATE Y (correct outputs)
data = pd.concat([df1_merg, df2_merg, df3_merg])

# insert a reference in the dataset to identify where
# data about the previous car finish and
# data about the next car start
ids = np.array(data.Vehicle_ID)
for i in range(len(ids)-1):
    ids[i] = ids[i] - ids[i+1]
ids[-1] = -1
data.Vehicle_ID = ids

next_x = list(data.Local_X)
next_y = list(data.Local_Y)
next_x.pop(0)
next_x.append(0)
next_y.pop(0)
next_y.append(0)
data['step_x'] = next_x - data.Local_X
data['step_y'] = next_y - data.Local_Y
data_print = data.loc[data.Vehicle_ID == 0, :]
data_print.to_csv('data.csv')
