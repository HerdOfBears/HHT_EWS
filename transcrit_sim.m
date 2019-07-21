
# Model parameters
sigma = 0.1; # noise intensity
bl = -1; # control parameter initial value
bh = 0.2; # control parameter final value
bcrit = 0; # bifurcation point (computed in Mathematica)
x0 = 0.0; # intial condition (equilibrium value)


# Initialise arrays to store single time-series data
t = t0:dt:tmax;
x = np.zeros(len(t))
y = np.zeros(len(t))

# Set up bifurcation parameter b, that increases linearly in time from bl to bh
mb = (bh - bl)./tmax;
intercept_b = bl;
b = mb.*t + intercept_b;

# Time at which bifurcation occurs
tbif = (-bl.*tmax)./(bh - bl);

## Implement Euler Maryuyama for stocahstic simulation

# Set seed
rng(101)

# Initialise a list to collect trajectories
list_traj_append = []
print(len(t))
t_0 = time.time()


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