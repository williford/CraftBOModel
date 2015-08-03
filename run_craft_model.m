function [mod, B, G] = run_craft_model()
% RUN_CRAFT_MODEL Example script that sets up and runs the Craft model.

close all;

mod = CraftBOModel();
mod.set_input_square(1);

sol = mod.run([0 40]);

[B, G] = mod.unpack(sol.y(:,end));

mod.display_B(B);
mod.display_G(G);