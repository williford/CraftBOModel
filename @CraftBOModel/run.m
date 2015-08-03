function sol = run( obj, timespans )

Y_0 = obj.pack(obj.B, obj.G);

sol = dde23(@obj.dde_fun, ...
   obj.conduction_delay, ...
   Y_0, ... values at t=0
   timespans );
