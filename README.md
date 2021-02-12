<img src="icon.png" width="100" alt="Icon"/>

#  Rendeer
A template renderer for CasparCG HTML Templates

## Table of contents
- [Usage](#usage)
  - [AMCP](#amcp)
  - [Configuration](#configuration)
- [License](#license)

## Usage

### AMCP
This app implements parts of the AMCP protocol from CasparCG.  
See the full documentation [here](https://github.com/CasparCG/help/wiki/AMCP-Protocol).

| Command | Description |
| --- | --- |
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

| Command | Description | Default|
| --- | --- | --- |
| `url` | The initial url to open | *none* |
| `width` | The renderer-width of the viewport, this does not affect the size of the actual window | `1920` |
| `height` | The renderer-height of the viewport, this does not affect the size of the actual window | `1080` |
| `amcp-port` | A port number on which to listen for AMCP | `5000` |


## License
MIT
