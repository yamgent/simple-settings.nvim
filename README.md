# simple-settings.nvim

## Usage

### Install plugin

Using lazy.nvim

```lua
    {
        'yamgent/simple-settings.nvim',
        config = function()
            local simple_settings = require('simple-settings')

            simple_settings.setup()
            simple_settings.read_config({
                age = 10,
                name = "John"
            })
        end
    },
```

### Read settings

```lua
    {
        '...',
        dependencies = { 'yamgent/simple-settings.nvim' },
        config = function()
            local simple_settings = require('simple-settings')

            local age = simple_settings.get_field("age")
            local name = simple_settings.get_field("name")

            -- use
            vim.print(name .. " is " .. tostring(age))
        end
    },
```

### Customize project settings

Store the JSON in `~/.config/simple-settings/settings.json`

```json
{
    "~/git/my-project": {
        "name": "My name",
        "age": 20
    },
    "~/test/": {
        "age": 5
    }
}
```
