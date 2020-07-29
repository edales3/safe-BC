# safe-BC
This repository contains the code for the experiment in the thesis "Imitation Learning for autonomous highway merging with safety guarantees" by Eleonora D'Alessandro

# Organization
The Python code for Behavioral Cloning is in the folder "BC". It contains: 
- Preprocessing.py -> To preprocess data from NGSIM dataset
- BC.py -> To train the NN and get the weights that perform BC
- Final weights
- Dataset

The MATLAB code for the Simulator is in the folder "Simulator". It contains:
- Dataset
- Simulator.m -> Visualization tool for NGSIM dataset
- Simulator_and_controller.m -> Visualization tool for contolled trajectories
- Final weights

# Requirements
Requirements for Python code are the following:
- pandas >= 1.0.5
- tensorflow >= 2.2.0
- matplotlib >= 3.1.3
- scipy >= 1.4.1
- scikit-learn >= 0.23.1
- numpy >= 1.19.0
