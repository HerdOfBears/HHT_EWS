#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 20 16:41:47 2018

@author: Thomas Bury

Code to simulate the RM model and compute EWS

"""

# import python libraries
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
# import seaborn as sns
import os

# import EWS function
import sys


#---------------------
# Directory for data output
#–----------------------

# Name of directory within data_export
dir_name = 'fold_ews_temp'

# if not os.path.exists('data_export/'+dir_name):
    # os.makedirs('data_export/'+dir_name)


#--------------------------------
# Global parameters
#–-----------------------------


# Simulation parameters
dt = 0.01
t0 = 0
tmax = 500
tburn = 100 # burn-in period
numSims = 1
seed = 2 # random number generation seed

# EWS parameters
dt2 = 1 # spacing between time-series for EWS computation
rw = 0.4 # rolling window
bw = 0.1 # bandwidth
lags = [1,2,3] # autocorrelation lag times
ews = ['var','ac','sd','cv','skew','kurt','smax','aic','cf'] # EWS to compute
ham_length = 40 # number of data points in Hamming window
ham_offset = 0.5 # proportion of Hamming window to offset by upon each iteration
pspec_roll_offset = 20 # offset for rolling window when doing spectrum metrics


#----------------------------------
# Simulate many (transient) realisations
#----------------------------------

# Model (bound system by using a piecewise definition)
def de_fun(x,u):
    output = -u - x**2 if x > -1.5 else 0
    return output
    
# Model parameters
sigma = 0.1 # noise intensity
bl = -1 # control parameter initial value
bh = 0.2 # control parameter final value
bcrit = 0 # bifurcation point (computed in Mathematica)
x0 = np.sqrt(-bl) # intial condition (equilibrium value)


# Initialise arrays to store single time-series data
t = np.arange(t0,tmax,dt)
x = np.zeros(len(t))
y = np.zeros(len(t))

# Set up bifurcation parameter b, that increases linearly in time from bl to bh
b = pd.Series(np.linspace(bl,bh,len(t)),index=t)
# Time at which bifurcation occurs
tbif = b[b > bcrit].index[1]


## Implement Euler Maryuyama for stocahstic simulation

# Set seed
np.random.seed(seed)

# Initialise a list to collect trajectories
list_traj_append = []

# loop over simulations
print('\nBegin simulations \n')
for j in range(numSims):
    
    
    # Create brownian increments (s.d. sqrt(dt))
    dW_x_burn = np.random.normal(loc=0, scale=sigma*np.sqrt(dt), size = int(tburn/dt))
    dW_x = np.random.normal(loc=0, scale=sigma*np.sqrt(dt), size = len(t))
        
    # Run burn-in period on x0
    for i in range(int(tburn/dt)):
        x0 = x0 + de_fun(x0,bl)*dt + dW_x_burn[i]
        
    # Initial condition post burn-in period
    x[0]=x0
    
    # Run simulation
    for i in range(len(t)-1):
        x[i+1] = x[i] + de_fun(x[i],b.iloc[i])*dt + dW_x[i]
            
    # Store series data in a temporary DataFrame
    data = {'Realisation number': (j+1)*np.ones(len(t)),
                'Time': t,
                'x': x}
    df_temp = pd.DataFrame(data)
    # Append to list
    list_traj_append.append(df_temp)
    
    print('Simulation '+str(j+1)+' complete')

#  Concatenate DataFrame from each realisation
df_traj = pd.concat(list_traj_append)
df_traj.set_index(['Realisation number','Time'], inplace=True)

# df_traj.to_csv("/home/jmenard/HHT_EWS/traj_data.csv")