function output = sensor_fault(input)

time = input(1);
fault_amplitude = input(2);
fault_time = input(3);

if time > fault_time
    output = fault_amplitude;
else
    output = 0;
end