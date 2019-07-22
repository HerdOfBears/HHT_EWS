function imf_eemd = find_most_orthog(signal, sigma, N, numIMFs, interpolation_type, sigma_l, sigma_h, steps)

	%{

	Iterates across noise amplitude to try to find the best way
	of separating modes. Computes orthogonality between every two imfs.

	Index of Orthogonality : IO
	IO = \sum_{time} (c_i c_j)/(signal.*signal)

	%}



end