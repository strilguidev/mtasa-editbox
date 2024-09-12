local screen = Vector2(guiGetScreenSize());

local numbersKeys = {
    ["0"] = true, ["1"] = true, ["2"] = true, ["3"] = true, ["4"] = true,
    ["5"] = true, ["6"] = true, ["7"] = true, ["8"] = true, ["9"] = true
};

local textKeys = {
    ["a"] = true, ["b"] = true, ["c"] = true, ["d"] = true, ["e"] = true, ["f"] = true, ["g"] = true, ["h"] = true, ["i"] = true, ["j"] = true, 
    ["k"] = true, ["l"] = true, ["m"] = true, ["n"] = true, ["o"] = true, ["p"] = true, ["q"] = true, ["r"] = true, ["s"] = true, ["t"] = true,
    ["u"] = true, ["v"] = true, ["w"] = true, ["x"] = true, ["y"] = true, ["z"] = true, ["A"] = true, ["B"] = true, ["C"] = true, ["D"] = true,
    ["E"] = true, ["F"] = true, ["G"] = true, ["H"] = true, ["I"] = true, ["J"] = true, ["K"] = true, ["L"] = true, ["M"] = true, ["N"] = true,
    ["O"] = true, ["P"] = true, ["Q"] = true, ["R"] = true, ["S"] = true, ["T"] = true, ["U"] = true, ["V"] = true, ["W"] = true, ["X"] = true,
    ["Y"] = true, ["Z"] = true, [" "] = false, [","] = false, ["."] = false, ["ç"] = false, ["é"] = false, ["á"] = false, ["õ"] = false, ["ã"] = false,
    ["?"] = false, ["$"] = false, ["#"] = false, ["&"] = false, ["@"] = false, ["+"] = false, ["="] = false, ["("] = false, [")"] = false, ["%"] = false
};

Editbox = { };

function Editbox:construction()
    self.cache = {};
    self.selected = false;
    self.button = false;
    self.events = false;
    
    return self;
end;

function Editbox:draw(id)
    local editbox = self.cache[id];
    if (not editbox) then return false end;
    
    local x, y, w, h = editbox.pos[1], editbox.pos[2], editbox.pos[3], editbox.pos[4];
    
    dxDrawText(
        (editbox.text == '' and editbox.defaultText or 
        (editbox.password and string.gsub(editbox.text, '.', '*') or editbox.text)),
        x, y, w, h, 
        (editbox.selected and tocolor(editbox.color['selected'][1], editbox.color['selected'][2], editbox.color['selected'][3], editbox.color['selected'][4]) or 
        tocolor(editbox.color['default'][1], editbox.color['default'][2], editbox.color['default'][3], editbox.color['default'][4])), 
        1, editbox.font, 
        editbox.alingX, editbox.alingY, false, false, true
    );

    if (self.selected and (self.selected == editbox.id) and #editbox.text >= 1) then 
        dxDrawLine(
            editbox.startLine, 
            y + (h / 4), 
            editbox.startLine, 
            y + (h / 1.4), 
            tocolor(255, 255, 255, math.abs (math.sin (getTickCount () / 700) * 255)), 1.3, true
        );
    end;

    if (editbox.selectedText) then 
        dxDrawRectangle(
            editbox.alingX == 'left' and x or (x + (w / 2) - (editbox.textWidth / 2)), 
            y, editbox.textWidth, 
            h, 
            tocolor(0, 100, 255, 30), true
        );
    end;

    if (isCursorOnElement(x, y, w, h)) then 
        self.button = editbox;
    elseif (not self.button) then 
        self.button = false;
    end;
end;

function Editbox:create(id, pos, defaultText, color, maxCharacter, password, number, alingX, alingY, font)
    if (self.cache[id]) then return false end;
    
    self.cache[id] = {
        id = id,
        text = '',
        defaultText = defaultText,
        pos = pos,
        color = color,
        maxCharacter = maxCharacter,
        password = password,
        number = number,
        alingX = alingX or 'center',
        alingY = alingY or 'center',
        font = font or 'default',
        selected = false,
        selectedText = false,
        visible = false,
        startLine = 0,
        textWidth = 0
    };
    
    if (not self.events) then 
        addEventHandler('onClientClick', root, function(...) return Editbox:onClick(...) end);
        addEventHandler('onClientCharacter', root, function(...) return Editbox:insertCharacter(...) end);
        addEventHandler('onClientKey', root, function(...) return Editbox:clickKey(...) end);
        
        self.events = true;
    end;
    
    return self.cache[id];
end;

function Editbox:onClick(b, s)
    if (b == 'left' and s == 'down') then
        if (self.button and isCursorOnElement(self.button.pos[1], self.button.pos[2], self.button.pos[3], self.button.pos[4])) then 
            if (self.selected and self.button['id'] ~= self.selected) then 
                self.cache[self.selected].selected = false;
                self.cache[self.selected].selectedText = false;
            end
            
            self.selected = self.button.id;
            self.cache[self.selected].selected = true;
            return true;
        elseif (self.selected) then 
            self.cache[self.selected].selected = false;
            self.cache[self.selected].selectedText = false;
            self.selected = false;
        end;
    end;
end;

function Editbox:insertCharacter(character)
    if (not self.selected) then return false end;
    local self = self.cache[self.selected];
    
    if (self) then 
        if (character == ' ') then return false end;
        
        local textLength = #self.text;
        if (textLength >= self.maxCharacter) then return false end;
        
        textLength = textLength + 1;
        
        if (self.number) then 
            if (numbersKeys[character]) then 
                self.text = utf8.insert(self.text, textLength, character);
            end;
            
            return true;
        end;
        
        if (textKeys[character]) then 
            self.text = utf8.insert(self.text, textLength, character);
        end;
        
        self.textWidth = dxGetTextWidth((self.password and string.gsub(self.text, '.', '*') or self.text), 1, self.font);
        if (self.alingX == 'left') then 
            self.startLine = self.pos[1] + (self.textWidth + 2);
        elseif (self.alingX == 'center') then 
            self.startLine = self.pos[1] + ((self.pos[3] / 2) + (self.textWidth / 2));
        end;
        
        return true;
    end;
end;

function Editbox:clickKey(button, state)
    if (not self.selected) then return false end;
    
    if (not state) then return false end
    local self = self.cache[self.selected];
    if (not self) then return false end;
    
    local action = getKeyState('lctrl');
    if (button == 'a' and action) then 
        if (#self.text >= 1) then 
            self.selectedText = not self.selectedText;
        end;
    elseif (button == 'backspace') then
        if (self.selectedText) then 
            self.text = '';
            self.selectedText = false;
            return true;
        end;
        
        self.text = utf8.remove(self.text, -1, -1);
        
        self.textWidth = dxGetTextWidth((self.password and string.gsub(self.text, '.', '*') or self.text), 1, self.font);
        if (self.alingX == 'left') then 
            self.startLine = self.pos[1] + (self.textWidth + 2);
        elseif (self.alingX == 'center') then 
            self.startLine = self.pos[1] + ((self.pos[3] / 2) + (self.textWidth / 2));
        end;
    end
    
    return true;
end;

function Editbox:setAttribute(id, attribute, value) 
    if (not self.cache[id]) then return false end;
    if (not self.cache[id][attribute]) then return false end;
    
    self.cache[id][attribute] = value;
    return self.cache[id];
end

function Editbox:get(id) 
    if (not self.cache[id]) then return false end;
    
    return self.cache[id];
end

function Editbox:getAll()
    return self.cache;
end

function Editbox:delete(id)
    if (not self.cache[id]) then return false end;
    
    self.cache[id] = nil;
    return true;
end;

function Editbox:deleteAll()
    if (not self.cache) then return false end;
    
    self.cache = {};
    self.selected = false;
    return true;
end;

--// Exports
function createEditBox(id, pos, defaultText, color, maxCharacter, password, number, alingX, alingY, font)
    return Editbox:create(id, pos, defaultText, color, maxCharacter, password, number, alingX, alingY, font);
end;

function getEditBox(id)
    return Editbox:get(id);
end;

function drawEditBox(id)
    return Editbox:draw(id);
end;

function deleteEditBox(id) 
    return Editbox:delete(id);
end;

function deleteAllEditBox(id) 
    return Editbox:deleteAll();
end;

function editBoxSetAttribute(id, attribute, value) 
    return Editbox:setAttribute(id, attribute, value);
end;

function getAllEditBox()
    return Editbox:getAll();
end;

Editbox:construction();

--// Utils
isCursorOnElement = function (absX, absY, width, height)
    if (not isCursorShowing ( )) then
        return false
    end;
    
    local mx, my = getCursorPosition ( );
    local cursorx, cursory = mx * screen.x, my * screen.y;
    if (cursorx > absX and cursorx < absX + width and cursory > absY and cursory < absY + height) then
        return true
    else
        return false
    end
end
