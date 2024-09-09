# mtasa-editbox
Lib which allows you to create custom dx editbox.

## Functions
``create``
##### Create a new instance and a editbox.
```lua
createEditBox(id, pos, defaultText, color, maxCharacter, password, number, alingX, alingY, font)
```
##### Exemple:
```lua
createEditBox('user', {10, 10, 120, 50}, 'Type something...', {default = {255, 255, 255, 25}, selected = {255, 255, 255, 255}}, 25, false, false, 'center', 'center', 'default')
```

``draw``
##### To render an editbox on the screen (it must be inside an onClientRender).
```lua
drawEditBox(id)
```
##### Exemple:
```lua
-- Always create the editbox outside of the render
createEditBox('user', {10, 10, 120, 50}, 'Type something...', {default = {255, 255, 255, 25}, selected = {255, 255, 255, 255}}, 25, false, false, 'center', 'center', 'default')

addEventHandler('onClientRender', root, function()
  drawEditBox('user');
end);
```

``delete``
##### Delete the instance.
```lua
deleteEditBox(id)
```
##### Exemple:
```lua
deleteEditBox('user')
```

``deleteAll``
##### This function delete all instance.
```lua
deleteAllEditBox()
```

``setAttribute``
##### This function set new attributes in editbox.
```lua
editBoxSetAttribute(id, attributes, value)
```
#### exemple:
```lua
editBoxSetAttribute('user', 'pos', {30, 10, 120, 50});
```

# License
#### You can use this lib in all your projects. Feel free to edit aswell!
