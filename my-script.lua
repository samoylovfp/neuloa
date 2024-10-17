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
  local left = dir == "left"
  local right = dir == "right"
  
  neulo_dlg = Dialog("Knitting order")
    :button {
      id = "left",
      text = left and "[<-]" or " <- ",
      focus = left,
      onclick = function()
        calculate_order("left")
      end
    }
    :button {
      id = "right",
      text = right and"[->]" or " -> ",
      focus = right,
      onclick = function()
        calculate_order("right")
      end
    }
  return neulo_dlg
end

function calculate_order(dir)
  dlg = dlg_base(dir)
  local sel = app.sprite.selection
  -- first check if only one row is selected
  if sel.bounds.height ~= 1 then
    dlg:label{text="Select a single row"}
  else
    local b = sel.bounds
    local ranges = {
      left  = {b.x + b.width - 1, b.x,               -1},
      right = {b.x,               b.x + b.width - 1, 1}
    }
    local range = ranges[dir]
    local first, last, offset = table.unpack(range)

    local last_color = nil
    local pix_count = 0

    for x=first, last, offset do
      local col = app.image:getPixel(
        x - app.cel.position.x,
        b.y - app.cel.position.y
      )

      if last_color ~= col then
        if pix_count > 0 then
          -- print(x .." adding old color " .. last_color)
          dlg:shades {
            label=pix_count, colors = {last_color}
          }
        end
        last_color = col
        pix_count = 1
      else
        -- print(x .. " continuing color " .. col)
        pix_count = pix_count + 1
      end
    end

    if pix_count > 0 then
      -- print("all passed, adding last color")
      dlg:shades{
        label=pix_count, colors = {last_color}
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
