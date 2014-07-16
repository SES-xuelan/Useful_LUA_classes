display.setStatusBar(display.HiddenStatusBar)
widget=require"widget"
log=require"log"
discrete_storage=require"discrete_storage"

discrete_storage.init(10,20)
discrete_storage.set_value("hint",12)

local enterscn = widget.newButton{
    width = 150,
    height = 100,
    left = 500,
    top = 500,
    label = "TOUCH",
    font = native.systemFont,
    fontSize = 40,
    onEvent = function(event)
        if "ended" == event.phase then
            discrete_storage.value_add("hint",5)
            local a= discrete_storage.get_value("hint")
            log.debug("get_value",a)
        end
    end
}
