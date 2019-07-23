function io_ = indexOrthog(signal, imf1, imf2)
	%{
		Computes the index of orthogonality between two imfs
		The index of orthogonality is defined to be
		IO = \sum_{time} (c_i c_j)/(signal ^2)
	%}

	% io_ = sum( (imf1.*imf2)./(signal.*signal) );
	io_ = 2.*sum( (imf1.*imf2)./(imf1.*imf1 + imf2.*imf2) );

end