local neulo_dlg = nil
local last_pos = nil
local neulo_data = {}

function show_neulo()
  neulo_dlg:show {
    wait = false,
    autoscrollbars = true,
    bounds = rect
  }
  if last_pos ~= nil then
    neulo_dlg.bounds = Rectangle{
      x=last_pos.x,
      y=last_pos.y,
      width=neulo_dlg.bounds.width,
      height=neulo_dlg.bounds.height
    }
    last_pos = nil
  end
end

function dlg_base(dir)
  if neulo_dlg ~= nil then
    last_pos = neulo_dlg.bounds
    neulo_dlg:close()
  end
  
  neulo_dlg = Dialog("Knitting order")
    :button {
      id = "left",
      text = " <- ",
      onclick = function()
        calculate_order("left")
      end
    }
    :button {
      id = "right",
      text = " -> ",
      onclick = function()
        calculate_order("right")
      end
    }
  return neulo_dlg
end

function calculate_order(dir)
  dlg = dlg_base(dir)
  -- first check if only one row is selected
  if app.sprite.selection.bounds.height ~= 1 then
    dlg:label{text="Select a single row"}
  else
    local b = app.sprite.selection.bounds
    local ranges = {
      left = {b.x+b.width, b.x, -1},
      right = {b.x, b.x+b.width, 1}
    }
    local range = ranges[dir]
    local first, last, offset = table.unpack(range)
    print(first, last, offset)
    local last_color = nil
    local pix_count = 0

    for x=first,last,offset do
      dlg:shades{
        label=x
      }
    end
  end
  
  show_neulo()
end

function init(plugin)
  dlg_base()
  show_neulo()

  plugin:newCommand {
    id = "neulo",
    title = "Show knitting order",
    group = "select_simple",
    onclick = function()
      dlg_base()
      show_neulo()
    end
  }
end

function count(sel)
  local count = 0
  local bounds = sel.bounds
  for x = bounds.x, bounds.x + bounds.width do
    for y = bounds.y, bounds.y + bounds.height do
      if sel:contains(x, y) then
        count = count + 1
      end
    end
  end
  return count
end

function exit(plugin)
  neulo_dlg:close()
end
