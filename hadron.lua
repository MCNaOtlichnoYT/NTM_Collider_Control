keyitem = 'minecraft:paper' -- item used to define recipes
times = {2, 4, 4, 12} -- operating time (in seconds) when 1, 2, 3, 4 coil types are used
-- power = 1 if can be crafted with gold coil, 2 if needs NbTi coil, 3 if needs BSCCO coil, 4 if needs chlorophyte coil
recipes = {
  Dgmm = {left = 'hbm:item.particle_higgs', right = 'hbm:item.particle_sparkticle', power = 4},
  Dark = {left = 'hbm:item.particle_aschrab', right = 'hbm:item.particle_aschrab', power = 3},
  Strg = {left = 'hbm:item.particle_dark', right = 'hbm:item.particle_muon', power = 3},
  Sprk = {left = 'hbm:item.powder_magic', right = 'hbm:item.particle_strange', power = 3},
  Ngts = {left = 'minecraft:chicken', right = 'minecraft:chicken', power = 1},
  Asch = {left = 'hbm:item.particle_amat', right = 'hbm:item.particle_amat', power = 1},
  Amat = {left = 'hbm:item.particle_copper', right = 'hbm:item.particle_hydrogen', power = 1},
  Tchn = {left = 'hbm:item.particle_higgs', right = 'hbm:item.particle_muon', power = 2},
  Hggs = {left = 'hbm:item.particle_lead', right = 'hbm:item.particle_hydrogen', power = 2},
  Muon = {left = 'hbm:item.particle_amat', right = 'hbm:item.particle_hydrogen', power = 2}
}
-- basic setup
pa_source_left = 2
pa_source_right = 3
component = require('component')
transposer = component.transposer
redstone = component.redstone
-- downloading config file
file = io.open('hadronconfig.txt', 'r')
c = tonumber(file:read('*a'))
file:close()
inv_source = math.floor(c / 100)
inv_input = math.floor(c % 100 / 10)
inv_dump = math.floor(c % 10)
-- operating hadron
while true do
  print('Checking items in input')
  -- check inputs
  items = {}
  queue = {}
  os.sleep(0.5)
  for slot = 1, transposer.getInventorySize(inv_input) do
    itemstack = transposer.getStackInSlot(inv_input, slot)
    if itemstack ~= nil then
      name = itemstack['name']
      size = itemstack['size']
      print('Found ', size, ' ', itemstack['label'], name)
      label = itemstack['label']
      if name == keyitem then
        queue[slot] = label
      else
        items[slot] = {id = name, count = size}
      end
    end
  end
  for rslot, recipe in pairs(queue) do 
    item_left = recipes[recipe]['left']
    item_right = recipes[recipe]['right']
    set_power = recipes[recipe]['power']
    print('Checking ability to craft ', recipe)
    print(item_left, ' ', item_right, ' ', set_power)
    fail = false
    -- search items for this recipe
    if item_left == item_right then
      -- two same items, like in recipe for antischrabidium
      for islot, idata in pairs(items) do
        f = false
        iname = idata['id']
        icount = idata['count']
        -- taking from same slot and craft
        if iname == item_left and icount >= 2 then
          print('Crafting ', recipe)
          redstone.setOutput(1, set_power)
          transposer.transferItem(inv_input, inv_source, 1, islot, pa_source_left)
          transposer.transferItem(inv_input, inv_source, 1, islot, pa_source_right)
          transposer.transferItem(inv_input, inv_dump, 1, rslot)
          os.sleep(times[set_power])
          break
        else
          -- need item from other slot
          for i2slot, i2data in pairs(items) do
            if i2slot ~= islot and i2data['id'] == item_left then
              redstone.setOutput(1, set_power)
              print('Crafting ', recipe)
              transposer.transferItem(inv_input, inv_source, 1, islot, pa_source_left)
              transposer.transferItem(inv_input, inv_source, 1, i2slot, pa_source_right)
              transposer.transferItem(inv_input, inv_dump, 1, rslot)
              os.sleep(times[set_power])
              f = true
              break
            end
          end
        end
        if f then break end
      end
    else 
      -- two different items
      sleft = -1
      sright = -1
      for islot, idata in pairs(items) do
        iname = idata['id']
        if iname == item_left then
          sleft = islot
        elseif iname == item_right then
          sright = islot
        end
        -- if we found both items no need to run this cycle
        if sleft ~= -1 and sright ~= -1 then break end
      end
      -- if we can't craft this now skip it
      if sleft == -1 or sright == -1 then
        fail = true
      else
        -- craft
        print('Crafting ', recipe)
        redstone.setOutput(1, set_power)
        transposer.transferItem(inv_input, inv_source, 1, sleft, pa_source_left)
        transposer.transferItem(inv_input, inv_source, 1, sright, pa_source_right)
        transposer.transferItem(inv_input, inv_dump, 1, rslot)
        os.sleep(times[set_power])
      end
    end
  end
end