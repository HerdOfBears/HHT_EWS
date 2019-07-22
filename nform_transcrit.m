function xdot = nform_transcrit(x, r)
	%{
	Normal form of a transcritical bifurcation. 


	%}

	xdot = r.*x - x.*x;
end