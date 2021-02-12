#  Rendeer
A template renderer for CasparCG HTML Templates

## Usage
The app listens for AMCP commands on port 5000 by default.

### Compatible commands
[Full documentation](https://github.com/CasparCG/help/wiki/AMCP-Protocol)

| Command | Description |
| --- | --- |
| `CG ADD` | Load a template |
| `CG PLAY` | Play a template |
| `CG STOP` | Stop a template |
| `CG UPDATE` | Send data to a template without encouraging a specific action |
| `CLEAR` | Clear the current viewport |

### Configuration
Additional runtime arguments can be added when opening the app using the terminal.

**Example**
```
open -a Rendeer --args --url https://example.com --width 1280 --height 720 --amcp-port 5250
```

| Flag | Description | Default |
| --- | --- | --- |
| `url` | The initial url to open | *none* |
| `width` | The renderer-width of the viewport, this does not affect the size of the actual window | `1920` |
| `height` | The renderer-height of the viewport, this does not affect the size of the actual window | `1080` |
| `amcp-port` | A port number on which to listen for AMCP | `5000` |


## License
MIT.
