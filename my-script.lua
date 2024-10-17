
local i = 3
local neulo_dlg = Dialog("Knitting order")

function show_neulo()
  neulo_dlg:show { wait = false, autoscrollbars = true, }
end

function init(plugin)
  neulo_dlg
    -- :button {
    --   id ="refresh",
    --   text="refresh",
    --   onclick = function()
    --     local id = "c" .. i
    --     local ii = i
    --     neulo_dlg:shades{
    --       id=id,
    --       label="[ ] " .. ii,
    --       mode="sort",
    --       colors={Color{r=100,g=i*4,b=0}},
    --       onclick=function()
            
    --         neulo_dlg:modify{
    --           id=id,
    --           label="[X] " .. ii
    --         }
    --       end
    --     }
    --     -- to refresh the dialog
    --     neulo_dlg:modify{title="Neulo"}
    --     i = i + 1
    --   end
    -- }
    :button {
      id = "left",
      text = "<-",
      onclick = function()
        neulo_dlg:modify {
          id = "left",
          text = "[<-]"
        }
        neulo_dlg:modify {
          id = "right",
          text = "->"
        }
      end
    }
    :button {
      id = "right",
      text = "[->]",
      onclick = function()
        neulo_dlg:modify {
          id = "left",
          text = "<-"
        }
        neulo_dlg:modify {
          id = "right",
          text = "[->]"
        }
      end
    }
    
  show_neulo()

  plugin:newCommand {
    id = "neulo",
    title = "Show knitting order",
    group = "select_simple",
    onclick = function()
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
