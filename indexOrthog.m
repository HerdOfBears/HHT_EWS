function io_ = indexOrthog(signal, imf1, imf2)
	%{
		Computes the index of orthogonality between two imfs
		The index of orthogonality is defined to be
		IO = \sum_{time} (c_i c_j)/(signal ^2)
	%}

	io = sum( (imf1.*imf2)./(signal.*signal) );

end