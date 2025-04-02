local neulo_dlg = nil
local last_pos = nil
local neulo_data = {}
local is_total = 0
local g_per_stitch = 0.1

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
  neulo_data = {rows={}}
  local left = dir == "left"
  local right = dir == "right"

  neulo_dlg = Dialog("Neuloa")
  neulo_dlg
    :button{
      id = "total",
      text = "total",
      onclick = function()
        is_total = 1
        dlg_base()
        show_neulo()
      end
    }
    :button{
      id = "order",
      text = "order",
      onclick = function()
        is_total = 0
        dlg_base()
        show_neulo()
      end
    }
    :separator{id="sep"}
  if (is_total == 1) then
    neulo_dlg
      :entry{id = "g_per_stitch", label="g per stitch", text=tostring(g_per_stitch)}
      :button{
        id = "count",
        text = "count",
        onclick = function() 
          g_per_stitch = neulo_dlg.data.g_per_stitch
          dlg_base()
          show_neulo()
        end
      }
    calc_colors()
  else
    neulo_dlg:button {
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
  end
  return neulo_dlg
end

function add_color(col, i, count)
  neulo_dlg:shades {
    id = "col"..i,
    label="    "..count,
    colors = {col},
    onclick = function()
      for k, v in pairs(neulo_data.rows) do
        if k <= i then
          neulo_dlg:modify {
            id="col"..k,
            label="[x] "..v
          }
        end
      end
    end
  }
end

function calculate_order(dir)
  dlg = dlg_base(dir)
  local sel = app.sprite.selection
  -- first check if only one row is selected
  if sel.bounds.height ~= 1 then
    dlg:label{text="Select a single row"}
  else
    local rows = {}
    local b = sel.bounds
    local ranges = {
      left  = {b.width - 1, -1},
      right = {0          ,  1}
    }
    local range = ranges[dir]
    local offset, mul = table.unpack(range)

    local last_color = nil
    local pix_count = 0

    for i=0, b.width-1, 1 do
      local x = offset + i*mul + b.x
      local col = app.image:getPixel(
        x - app.cel.position.x,
        b.y - app.cel.position.y
      )

      if last_color ~= col then
        if pix_count > 0 then
          local count = pix_count
          rows[i-1] = count
          add_color(last_color, i - 1, count)
        end
        last_color = col
        pix_count = 1
      else
        pix_count = pix_count + 1
      end
    end

    if pix_count > 0 then
      rows[b.width]=pix_count
      add_color(last_color, b.width, pix_count)
    end
    neulo_data.rows=rows
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

function calc_colors()
  local sel = app.sprite.selection
  local b = sel.bounds
  local colours = {}
  for i=0, b.width-1, 1 do
    for j=0, b.height-1, 1 do
      local col = app.image:getPixel(
        b.x - app.cel.position.x + i,
        b.y - app.cel.position.y + j
      )
      if colours[col] == nil then
        colours[col] = 0
      end
      colours[col] = colours[col] + 1
    end
  end
  for k,v in pairs(colours) do
    neulo_dlg:shades {
      id = "col"..k,
      label= (g_per_stitch * v) .. " g ("..v..")",
      colors = {k},
    }
  end
end
