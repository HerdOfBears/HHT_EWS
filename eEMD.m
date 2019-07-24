function imfs = eEMD( signal, sigma, N, numIMFs, interpolation_type)

	%{
	Ensemble Empirical Mode Decomposition
		Takes a signal and decomposes it into so-called
		Intrinsic Mode Functions (IMFs)

	The ensembling is to help mitigate mode-mixing of IMFs.  

	interpolation_type = {'spline', 'pchip'}

	%}
	rng(10);
	if interpolation_type == "Spline"
		interpolation_type = 'spline';
	end
	if interpolation_type == "Pchip"
		interpolation_type = "pchip";
	end

	[m,n] = size(signal);

	avg_imf = [];
	for i_ = 1:1:N
		noise_ = sigma.*randn(m,n);
		[imf_,res__, info__] = emd(signal + noise_, 'Interpolation', interpolation_type, 'Display', 0);
		% res__ and info__ are not used.

		if i_ == 1
			avg_imf = imf_(:, 1:numIMFs);
		end
		if i_ > 1
			avg_imf = avg_imf(:,1:numIMFs) + imf_(:, 1:numIMFs);
		end
	end

	imf_eemd = avg_imf./N;
	imfs = imf_eemd;
end