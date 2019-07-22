function xdot = nform_fold(x, r)
	%{
	Normal form of a transcritical bifurcation. 


	%}

	 if x > -1.5
		xdot = -r - x.*x;
	end
	if x<= -1.5
		xdot = 0;
	end
end