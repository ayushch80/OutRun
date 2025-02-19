# OutRun 🚀🚀🚀

OutRun is a lightweight project initialization tool designed to streamline setting up new projects with essential configurations. 🎯✨🔥

## Features ⚡
- Displays a unique ASCII art banner
- Provides a command-line interface with useful commands
- Checks for required system dependencies
- Supports project initialization with customizable settings
- Generates a structured `out.run` configuration file

## Installation 🛠️
Ensure you have the required dependencies installed:

```sh
sudo apt install cloudflared yq npm node -y
```

Then, clone the repository:

```sh
git clone <repo-url>
cd outrun
chmod +x src/outrun.sh
```

## Usage 🏃‍♂️
Run the script with the following commands:

```sh
./src/outrun.sh <command> [options]
```

### Available Commands 🎯
- `help`      - Show available commands
- `version`   - Display the current OutRun version
- `init [path]` - Initialize an OutRun project (default: current directory)

### Example Usage 🏗️
```sh
./src/outrun.sh init my-project
```

## Configuration ⚙️
The `init` command generates an `out.run` file with project settings:

```yaml
OUTRUN_VERSION: "1.0.0"
proj: "my-project"
root: "./"
manager: "npm"
port: "3000"
cmd:
    build: "npm run build"
    start: "npm run start"
```

## License 📄
This project is licensed under the MIT License. 

## Contributing 🤝
Feel free to fork the repository, create a new branch, and submit a pull request! 🎨

