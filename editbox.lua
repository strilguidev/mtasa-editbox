local screenW, screenH = guiGetScreenSize();

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

Main = { }

function Main:construction()
    self.cache = { }
    self.selected = false

    self.events = {
        __render__ = function()
            return self:render()
        end,

        __inserttext__ = function(character)
            return self:character(character)
        end,

        __clickKey__ =  function(b, s)
            return self:clickKey(b, s)
        end,

        __onClick__ = function(b, s)
            return self:click(b, s)
        end
    }

    addEventHandler('onClientRender', root, self.events['__render__'])
    addEventHandler('onClientClick', root, self.events['__onClick__'])
    addEventHandler('onClientCharacter', root, self.events['__inserttext__'])
    addEventHandler('onClientKey', root, self.events['__clickKey__'])

    return self;
end;

function Main:create(id, pos, defaultText, color, maxCharacter, password, number, alingX, alingY, font)
    if (not self.cache) then self.cache = {} end;

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

    return self.cache[id];
end;

function Main:render()
    for _, v in pairs(self.cache) do
        if (v.visible) then 
            dxDrawText(
                (v.text == '' and v.defaultText or 
                (v.password and string.gsub(v.text, '.', '*') or v.text)),
                v.pos[1], v.pos[2], v.pos[3], v.pos[4], 
                (v.selected and tocolor(v.color['selected'][1], v.color['selected'][2], v.color['selected'][3], v.color['selected'][4]) or 
                tocolor(v.color['default'][1], v.color['default'][2], v.color['default'][3], v.color['default'][4])), 
                1, v.font, 
                v.alingX, v.alingY, true, false, true
            );
    
            if (v.selected and #v.text >= 1) then 
                dxDrawLine(
                    v.startLine, 
                    v.pos[2] + (v.pos[4] / 4), 
                    v.startLine, 
                    v.pos[2] + (v.pos[4] / 1.4), 
                    tocolor(255, 255, 255), 1.3, true
                );
            end;
            
            if (v.selectedText) then 
                dxDrawRectangle(
                    v.alingX == 'left' and v.pos[1] or (v.pos[1] + (v.pos[3] / 2) - (v.textWidth / 2)), 
                    v.pos[2], v.textWidth, 
                    v.pos[4], 
                    tocolor(0, 100, 255, 30), true
                );
            end;
        end
    end;
end;

function Main:click(b, s)
    if (b == 'left' and s == 'down') then
        for i, v in pairs(self.cache) do
            if isCursorOnElement(v.pos[1], v.pos[2], v.pos[3], v.pos[4]) then
                if (self.selected) then 
                    self.cache[self.selected].selected = false;
                    self.cache[self.selected].selectedText = false;
                end;
                
                v.selected = true;
                self.selected = v.id;

                return true;
            else
                v.selected = false;
                v.selectedText = false;
                self.selected = false;
            end;

        end;
    end;
end;

function Main:character(character)
    if (not self.selected) then return false end ;
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

function Main:clickKey(button, state)
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

function Main:setAttribute(id, attribute, value) 
    if (not self.cache[id]) then return false end;
    if (not self.cache[id][attribute]) then return end;

    self.cache[id][attribute] = value;
    return self.cache[id];
end

function Main:get(id)
    if (not self.cache[id]) then return false end;

    return self.cache[id];
end;

function Main:getAll()
    return self.cache;
end;

function Main:delete(id)
    if (not self.cache[id]) then return false end;

    self.cache[id] = nil;
    return true;
end;

function Main:deleteAll()
    if (not self.cache) then return false end;

    self.cache = {};
    self.selected = false;
    return true;
end;

--// Exports
function createEditBox(id, pos, defaultText, color, maxCharacter, password, number, alingX, alingY, font)
    return Main:create(id, pos, defaultText, color, maxCharacter, password, number, alingX, alingY, font);
end;

function getEditBox(id)
    return Main:get(id);
end;

function deleteEditBox(id) 
    return Main:delete(id);
end;

function deleteAllEditBox(id) 
    return Main:deleteAll();
end;

function editBoxSetAttribute(id, attribute, value) 
    return Main:setAttribute(id, attribute, value);
end;

function getAllEditBox()
    return Main:getAll();
end;

Main:construction();
