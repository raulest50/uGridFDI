function simple_init(arg)

ttInitKernel('prioFP')

data.exectime = 50e-6;   % control task execution time
starttime = 0.0;       % control task start time
period = 100e-6;          % control task period

ttCreatePeriodicTask('ctrl_task', starttime, period, 'ctrl_code', data)
