function finResults = transcrit_sim(t0, dt, tmax, numSims)
	% Model parameters
	sigma = 0.1; % noise intensity
	bl = -1;	 % control parameter initial value
	bh = 0.2; 	 % control parameter final value
	bcrit = 0; 	 % bifurcation point
	x0 = 0.0; 	 % intial condition (equilibrium value)


	% Initialise arrays to store single time-series data
	t = t0:dt:tmax;
	t = t'; % make column
	tburn = 100; % burn-in period

	x = [];%np.zeros(len(t))
	y = [];%np.zeros(len(t))

	% Set up bifurcation parameter b, that increases linearly in time from bl to bh
	mb = (bh - bl)./tmax;
	intercept_b = bl;
	b = mb.*t + intercept_b;

	% Time at which bifurcation occurs
	tbif = (-bl.*tmax)./(bh - bl);

	%% Implement Euler Maryuyama for stocahstic simulation

	% Set seed
	rng(25)

	% Initialise a list to collect trajectories
	disp(length(t));
	list_traj_append = struct();

	% loop over simulations
	disp('\nBegin simulations \n')
	for j = 1:1:numSims
		
		% Create brownian increments (s.d. sqrt(dt))
		dW_x_burn = sigma.*sqrt(dt).*randn(fix(tburn/dt),1);
		dW_x = sigma.*sqrt(dt).*randn(length(t),1);
			
		% Run burn-in period on x0
		for i = 1:1:(fix(tburn./dt))
			x0 = x0 + nform_transcrit(x0,bl).*dt + dW_x_burn(i,1);
		end	
		% Initial condition post burn-in period
		x(1,1)=x0;
		
		% Run simulation
		for i =1:1:(length(t)-1)
			x(i+1,1) = x(i,1) + nform_transcrit( x(i,1), b(i,1) ).*dt + dW_x(i,1);
		end

		
		% Append to list
		list_traj_append.( strcat('sim_', num2str(j)) ) = [t, x, b];

		disp( strcat('Simulation ',num2str(j),' complete') )
	end
	finResults = list_traj_append;
end
