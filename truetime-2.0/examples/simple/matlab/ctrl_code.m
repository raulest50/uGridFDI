function [exectime, data] = ctrl_code(segment, data)

switch segment
 case 1
  var1 = ttAnalogIn(1);
  var2 = ttAnalogIn(2);
  var3 = ttAnalogIn(3);
  data.u1 = var1;
  data.u2 = var2;
  data.u3 = var3;
  exectime = data.exectime;
 case 2
  ttAnalogOut(1, data.u1)
  ttAnalogOut(2, data.u2)
  ttAnalogOut(3, data.u3)
  exectime = -1;
end
