# Source after launching behavioral simulation; matches the handout's forces.
restart
add_wave /light/x1 /light/x2 /light/f
add_force /light/x1 {0 0ns} {1 50ns} -repeat_every 100ns
add_force /light/x2 {0 0ns} {1 100ns} -repeat_every 200ns
run 200 ns
