function xdot = nform_transcrit(x, r)
	%{
	Normal form of a transcritical bifurcation. 


	%}

	x_dot = r.*x - x.*x;
end