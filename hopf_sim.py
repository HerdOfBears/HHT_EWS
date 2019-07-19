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
# sys.path.append('../../early_warnings')
# from ews_compute import ews_compute


#---------------------
# Directory for data output
#–----------------------

# Name of directory within data_export
dir_name = 'hopf_ews_temp'

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
numSims = 2
seed = 10 # random number generation seed

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

# Model

def de_fun_x(x,y,u,w):
    return u*x-w*y-x*(x**2+y**2)

def de_fun_y(x,y,u,w):
    return w*x+u*y-y*(x**2+y**2)
    
# Model parameters
sigma_x = 0.05 # noise intensity
sigma_y = 0.05
w = 2 # intrinsic frequency at Hopf bifurcation
bl = -1 # control parameter initial value
bh = 0.2 # control parameter final value
bcrit = 0 # bifurcation point (computed in Mathematica)
x0 = 0 # intial condition (equilibrium value)
y0 = 0



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
    dW_x_burn = np.random.normal(loc=0, scale=sigma_x*np.sqrt(dt), size = int(tburn/dt))
    dW_x = np.random.normal(loc=0, scale=sigma_x*np.sqrt(dt), size = len(t))
    
    dW_y_burn = np.random.normal(loc=0, scale=sigma_y*np.sqrt(dt), size = int(tburn/dt))
    dW_y = np.random.normal(loc=0, scale=sigma_y*np.sqrt(dt), size = len(t))
    
    # Run burn-in period on x0
    for i in range(int(tburn/dt)):
        x0 = x0 + de_fun_x(x0,y0,bl,w)*dt + dW_x_burn[i]
        y0 = y0 + de_fun_y(x0,y0,bl,w)*dt + dW_y_burn[i]
        
    # Initial condition post burn-in period
    x[0]=x0
    y[0]=y0
    
    # Run simulation
    for i in range(len(t)-1):
        x[i+1] = x[i] + de_fun_x(x[i],y[i],b.iloc[i],w)*dt + dW_x[i]
        y[i+1] = y[i] + de_fun_y(x[i],y[i],b.iloc[i],w)*dt + dW_y[i]
            
    # Store series data in a temporary DataFrame
    data = {'Realisation number': (j+1)*np.ones(len(t)),
                'Time': t,
                'x': x,
                'y': y}
    df_temp = pd.DataFrame(data)
    # Append to list
    list_traj_append.append(df_temp)
    
    print('Simulation '+str(j+1)+' complete')

#  Concatenate DataFrame from each realisation
df_traj = pd.concat(list_traj_append)
df_traj.set_index(['Realisation number','Time'], inplace=True)

df_traj.to_csv("/home/jmenard/HHT_EWS/traj_data_hopf.csv")