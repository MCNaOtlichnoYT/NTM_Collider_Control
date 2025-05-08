component = require('component')
transposer = component.transposer
print('Configurating your Hadron Collider')
print('Make sure your transposer is connected to particle source and two storage blocks with different types (e.g. hopper and iron crate')
print('Press ENTER to start configuration')
io.read()
print('Checking...')
for side = 0, 5 do
invname = transposer.getInventoryName(side)
print('Side: ', side, ' Found: ', invname)
if invname == 'tile.pa_source' then
  inv_source = side
  print('Particle source found!')
elseif invname ~= nil then
  print('Found inventory!\nIs it input(enter 1) or dump(enter 2) or not related to program(enter anything else)?')
  n = tonumber(io.read())
  if n == 1 then inv_input = side elseif n == 2 then inv_dump = side end
end
end
c = inv_source * 100 + inv_input * 10 + inv_dump
file = io.open('hadronconfig.txt', 'w')
file:write(tostring(c))
file:close()
print('Configuration file saved!')