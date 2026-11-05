{
    if(NR > 1) { 
	# Print a segment header with the Z-value of the starting point (from the previous line)
	print "> -Z" prev_z
	# Print the previous point coordinates
	print prev_x, prev_y
	# Print the current point coordinates
	print $1, $2
    }
    # Save current coordinates for the next iteration
    prev_x = $1; prev_y = $2; prev_z = $3 
}
